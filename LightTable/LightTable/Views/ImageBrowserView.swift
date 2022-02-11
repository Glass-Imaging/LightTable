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

    let minPaneSize:CGFloat = 200

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ImageListView(model: model)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                PaneDivider { offset in
                    DispatchQueue.main.async {
                        scrollViewHeight = max(min(scrollViewHeight - offset, geometry.size.height - minPaneSize), minPaneSize)
                    }
                }
                ThumbnailScrollView(model: model)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: max(scrollViewHeight, 0))
                    .background(.regularMaterial)
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
                    commandButton(model: model, label: "Rotate Left", key: "[") { model in
                        model.rotateLeft()
                    }
                    commandButton(model: model, label: "Rotate Right", key: "]") { model in
                        model.rotateRight()
                    }

                    commandButton(model: model, label: "Toggle Layout", key: "L") { model in
                        model.switchLayout()
                    }
                }

                Divider()

                Group {
                    commandButton(model: model, label: "Move Left", key: .leftArrow) { model in
                        model.processKey(key: .leftArrow)
                    }
                    commandButton(model: model, label: "Move Right", key: .rightArrow) { model in
                        model.processKey(key: .rightArrow)
                    }
                }

                Divider()

                Menu("View Selection") {
                    let zero = Character("0")
                    ForEach(1...9, id: \.self) { index in
                        let c = Character(UnicodeScalar(Int(zero.asciiValue!) + index)!)
                        commandButton(model: model, label: "View " + String(c), key: KeyEquivalent(c)) { model in
                            model.imageViewSelection(char: c)
                        }
                    }
                    commandButton(model: model, label: "View 10", key: "0") { model in
                        model.imageViewSelection(char: "0")
                    }
                    commandButton(model: model, label: "Show All", key: "`") { model in
                        model.imageViewSelection = -1
                    }
                }
                .disabled(model == nil)

                Divider()

                commandButton(model: model, label: (model != nil && model!.fullScreen ? "Exit " : "Enter ") + "Full Screen Preview", key: "F") { model in
                    model.fullScreen = !model.fullScreen
                }
                .disabled(model == nil)

                Divider()
            }
        }
    }
}
