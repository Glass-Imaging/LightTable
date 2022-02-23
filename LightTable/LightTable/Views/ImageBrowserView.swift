//
//  ImageBrowserView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

struct ImageBrowserView: View {
    @Binding var browserModel:ImageBrowserModel
    @Binding var viewModel:ImageViewModel

    // Height of the ThumbnailScrollerPanel, modified by the PaneDivider
    @State var scrollViewHeight:CGFloat = 200

    let backgroundColor = Color(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0)
    let dividerColor = Color(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0)

    let minPaneSize:CGFloat = 200

    var body: some View {
        GeometryReader { geometry in
            VSplitView {
                VStack {
                    ImageListView(browserModel: $browserModel, viewModel: $viewModel)
                        .frame(maxWidth: .infinity, minHeight: minPaneSize, maxHeight: .infinity)

                    ZStack {
                        Rectangle()
                            .foregroundColor(dividerColor)
                        HStack {
                            Spacer()

                            ThumbnailSizeSlider(value: $viewModel.thumbnailSize)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(height: 20)
                }
                .layoutPriority(1)

                ThumbnailScrollView(browserModel: $browserModel, thumbnailSize: $viewModel.thumbnailSize)
                    .frame(maxWidth: .infinity, minHeight: minPaneSize, maxHeight: .infinity)
                    .background(backgroundColor)
            }
        }
    }

    struct ViewCommands: Commands {

        var body: some Commands {
            CommandGroup(after: .sidebar) {
                Group {
                }
            }
        }
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedBrowserModel) private var browserModel: ImageBrowserModel?
        @FocusedBinding(\.focusedViewModel) private var viewModel: ImageViewModel?

        var body: some Commands {

            CommandGroup(after: .sidebar) {

                Group {
                    CommandButton(label: "Rotate Left", key: "[") {
                        viewModel?.rotateLeft()
                    }
                    CommandButton(label: "Rotate Right", key: "]") {
                        viewModel?.rotateRight()
                    }

                    CommandButton(label: "Toggle Layout", key: "L") {
                        viewModel?.switchLayout()
                    }
                    CommandButton(label: "Uniform Orientation", key: "O") {
                        viewModel?.togglaMasterOrientation()
                    }

                    CommandButton(label: "Toggle Image View Data", key: "V") {
                        viewModel?.switchViewInfoItems()
                    }
                }

                Divider()

                Group {
                    CommandButton(label: "Zoom In", key: "=", modifiers: .command) {
                        viewModel?.zoomIn()
                    }
                    CommandButton(label: "Zoom Out", key: "-", modifiers: .command) {
                        viewModel?.zoomOut()
                    }
                    CommandButton(label: "Zoom To Fit", key: "=") {
                        viewModel?.zoomToFit()
                    }
                }

                Divider()

                Group {
                    CommandButton(label: "Move Left", key: .leftArrow) {
                        browserModel?.processKey(key: .leftArrow)
                        viewModel?.resetInteractiveState()
                    }
                    CommandButton(label: "Move Right", key: .rightArrow) {
                        browserModel?.processKey(key: .rightArrow)
                        viewModel?.resetInteractiveState()
                    }
                }

                Divider()

                Menu("View Selection") {
                    let zero = Character("0")
                    ForEach(1...9, id: \.self) { index in
                        let c = Character(UnicodeScalar(Int(zero.asciiValue!) + index)!)
                        CommandButton(label: "View " + String(c), key: KeyEquivalent(c)) {
                            viewModel?.imageViewSelection(char: c, selection: browserModel!.selection)
                        }
                    }
                    CommandButton(label: "View 10", key: "0") {
                        viewModel?.imageViewSelection(char: "0", selection: browserModel!.selection)
                    }
                    CommandButton(label: "Show All", key: "`") {
                        viewModel?.resetImageViewSelection()
                    }
                }
                .disabled(browserModel == nil)

                Divider()

                CommandButton(label: (viewModel != nil && viewModel!.fullScreen ? "Exit " : "Enter ") + "Full Screen Preview", key: "F") {
                    viewModel?.toggleFullscreen()
                }
                .disabled(browserModel == nil)

                Divider()
            }
        }
    }
}
