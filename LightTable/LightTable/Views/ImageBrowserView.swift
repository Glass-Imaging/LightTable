//
//  ImageBrowserView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

struct ImageBrowserView: View {
    @ObservedObject var model:ImageBrowserModel

    // Height of the ThumbnailScrollerPanel, modified by the PaneDivider
    @State var scrollViewHeight:CGFloat = 200

    // @State var thumbnailSize:CGFloat = 150

    let backgroundColor = Color(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0)
    let dividerColor = Color(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0)

    let minPaneSize:CGFloat = 200

    var body: some View {
        let thumbnailSizeBinding = Binding<CGFloat>(
            get: { model.thumbnailSize },
            set: { val in model.thumbnailSize = val }
        )

        GeometryReader { geometry in
            VSplitView {
                VStack {
                    ImageListView(model: model)
                        .frame(maxWidth: .infinity, minHeight: minPaneSize, maxHeight: .infinity)

                    ZStack {
                        Rectangle()
                            .foregroundColor(dividerColor)
                        HStack {
                            Spacer()

                            ThumbnailSizeSlider(value: thumbnailSizeBinding)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(height: 20)
                }
                .layoutPriority(1)

                ThumbnailScrollView(model: model)
                    .frame(maxWidth: .infinity, minHeight: minPaneSize, maxHeight: .infinity)
                    .background(backgroundColor)
            }
        }
        .onReceive(model.$files) { _ in
            model.imageViewSelection = -1
        }
        .onReceive(model.$selection) { _ in
            model.imageViewSelection = -1
        }
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedBrowserModel) private var model: ImageBrowserModel?

        var body: some Commands {

            CommandGroup(after: .sidebar) {

                Group {
                    CommandButton(model: model, label: "Rotate Left", key: "[") { model in
                        model.orientation = rotateLeft(value: model.orientation)
                    }
                    CommandButton(model: model, label: "Rotate Right", key: "]") { model in
                        model.orientation = rotateRight(value: model.orientation)
                    }

                    CommandButton(model: model, label: "Uniform Orientation", key: "O") { model in
                        model.useMasterOrientation = !model.useMasterOrientation
                    }

                    CommandButton(model: model, label: "Toggle Layout", key: "L") { model in
                        model.switchLayout()
                    }

                    CommandButton(model: model, label: "Toggle Image View Data", key: "V") { model in
                        model.switchViewInfoItems()
                    }
                }

                Divider()

                Group {
                    CommandButton(model: model, label: "Zoom In", key: "=", modifiers: .command) { model in
                        model.viewScaleFactor += 1
                    }
                    CommandButton(model: model, label: "Zoom Out", key: "-", modifiers: .command) { model in
                        if (model.viewScaleFactor > 0) {
                            model.viewScaleFactor -= 1
                        }
                    }
                    CommandButton(model: model, label: "Zoom To Fit", key: "=") { model in
                        model.viewScaleFactor = 0
                    }
                }

                Divider()

                Group {
                    CommandButton(model: model, label: "Move Left", key: .leftArrow) { model in
                        model.processKey(key: .leftArrow)
                    }
                    CommandButton(model: model, label: "Move Right", key: .rightArrow) { model in
                        model.processKey(key: .rightArrow)
                    }
                }

                Divider()

                Menu("View Selection") {
                    let zero = Character("0")
                    ForEach(1...9, id: \.self) { index in
                        let c = Character(UnicodeScalar(Int(zero.asciiValue!) + index)!)
                        CommandButton(model: model, label: "View " + String(c), key: KeyEquivalent(c)) { model in
                            model.imageViewSelection(char: c)
                        }
                    }
                    CommandButton(model: model, label: "View 10", key: "0") { model in
                        model.imageViewSelection(char: "0")
                    }
                    CommandButton(model: model, label: "Show All", key: "`") { model in
                        model.imageViewSelection = -1
                    }
                }
                .disabled(model == nil)

                Divider()

                CommandButton(model: model, label: (model != nil && model!.fullScreen ? "Exit " : "Enter ") + "Full Screen Preview", key: "F") { model in
                    model.fullScreen = !model.fullScreen
                }
                .disabled(model == nil)

                Divider()
            }
        }
    }
}
