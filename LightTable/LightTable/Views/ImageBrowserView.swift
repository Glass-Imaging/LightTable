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

    static func commandButton(model: ImageBrowserModel?, label:String, key: KeyEquivalent, modifiers: EventModifiers = [], action: @escaping (_ model: ImageBrowserModel) -> Void) -> some View {
        return Button {
            if let model = model {
                action(model)
            }
        } label: {
            Text(label)
        }
        .keyboardShortcut(key, modifiers: modifiers)
        .disabled(model == nil)
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedBrowserModel) private var model: ImageBrowserModel?

        var body: some Commands {
            CommandMenu("Navigation") {
                commandButton(model: model, label: "Move Left", key: .leftArrow, action: { model in
                    model.nextLocation = model.processKey(key: .leftArrow)
                })
                commandButton(model: model, label: "Move Right", key: .rightArrow, action: { model in
                    model.nextLocation = model.processKey(key: .rightArrow)
                })

                Divider()

                commandButton(model: model, label: "Rotate Left", key: "[", action: { model in
                    model.rotateLeft()
                })
                commandButton(model: model, label: "Rotate Right", key: "]", action: { model in
                    model.rotateRight()
                })

                commandButton(model: model, label: "Toggle Layout", key: "L", action: { model in
                    model.switchLayout()
                })

                Divider()

                Menu("View Selection") {
                    let zero = Character("0")
                    ForEach(1...9, id: \.self) { index in
                        let c = Character(UnicodeScalar(Int(zero.asciiValue!) + index)!)
                        commandButton(model: model, label: "View " + String(c), key: KeyEquivalent(c), action: { model in
                            model.imageViewSelection(char: c)
                        })
                    }
                    commandButton(model: model, label: "View 10", key: "0", action: { model in
                        model.imageViewSelection(char: "0")
                    })
                    commandButton(model: model, label: "Show All", key: "`", action: { model in
                        model.imageViewSelection = -1
                    })
                }
                .disabled(model == nil)
            }
        }
    }
}
