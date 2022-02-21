//
//  ImageBrowserView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

struct ImageBrowserView: View {
    @Binding var model:ImageBrowserModel

    // Height of the ThumbnailScrollerPanel, modified by the PaneDivider
    @State var scrollViewHeight:CGFloat = 200

    let backgroundColor = Color(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0)
    let dividerColor = Color(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0)

    let minPaneSize:CGFloat = 200

    var body: some View {
        GeometryReader { geometry in
            VSplitView {
                VStack {
                    ImageListView(model: $model)
                        .frame(maxWidth: .infinity, minHeight: minPaneSize, maxHeight: .infinity)

                    ZStack {
                        Rectangle()
                            .foregroundColor(dividerColor)
                        HStack {
                            Spacer()

                            ThumbnailSizeSlider(value: $model.thumbnailSize)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(height: 20)
                }
                .layoutPriority(1)

                ThumbnailScrollView(model: $model)
                    .frame(maxWidth: .infinity, minHeight: minPaneSize, maxHeight: .infinity)
                    .background(backgroundColor)
            }
        }
        .onChange(of: model.files) { _ in
            model.imageViewSelection(char: "`")
        }
        .onChange(of: model.selection) { _ in
            model.imageViewSelection(char: "`")
        }
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedBrowserModel) private var model: ImageBrowserModel?

        var body: some Commands {

            CommandGroup(after: .sidebar) {

                Group {
                    CommandButton(label: "Rotate Left", key: "[") {
                        model?.rotateLeft()
                    }
                    CommandButton(label: "Rotate Right", key: "]") {
                        model?.rotateRight()
                    }

                    CommandButton(label: "Uniform Orientation", key: "O") {
                        model?.togglaMasterOrientation()
                    }

                    CommandButton(label: "Toggle Layout", key: "L") {
                        model?.switchLayout()
                    }

                    CommandButton(label: "Toggle Image View Data", key: "V") {
                        model?.switchViewInfoItems()
                    }
                }

                Divider()

                Group {
                    CommandButton(label: "Zoom Out", key: "-", modifiers: .command) {
                        model?.zoomOut()
                    }
                    CommandButton(label: "Zoom In", key: "=", modifiers: .command) {
                        model?.zoomIn()
                    }
                    CommandButton(label: "Zoom To Fit", key: "=") {
                        model?.zoomToFit()
                    }
                }

                Divider()

                Group {
                    CommandButton(label: "Move Left", key: .leftArrow) {
                        model?.processKey(key: .leftArrow)
                    }
                    CommandButton(label: "Move Right", key: .rightArrow) {
                        model?.processKey(key: .rightArrow)
                    }
                }

                Divider()

                Menu("View Selection") {
                    let zero = Character("0")
                    ForEach(1...9, id: \.self) { index in
                        let c = Character(UnicodeScalar(Int(zero.asciiValue!) + index)!)
                        CommandButton(label: "View " + String(c), key: KeyEquivalent(c)) {
                            model?.imageViewSelection(char: c)
                        }
                    }
                    CommandButton(label: "View 10", key: "0") {
                        model?.imageViewSelection(char: "0")
                    }
                    CommandButton(label: "Show All", key: "`") {
                        model?.imageViewSelection(char: "`")
                    }
                }
                .disabled(model == nil)

                Divider()

                CommandButton(label: (model != nil && model!.fullScreen ? "Exit " : "Enter ") + "Full Screen Preview", key: "F") {
                    model?.toggleFullscreen()
                }
                .disabled(model == nil)

                Divider()
            }
        }
    }
}
