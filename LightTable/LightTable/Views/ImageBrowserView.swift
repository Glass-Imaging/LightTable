//
//  ImageBrowserView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

struct ImageBrowserView: View {
    @ObservedObject var model:ImageBrowserModel

    // Single view selection for ImageListView
    @State var imageViewFilter = -1

    @State var imageViewLayout:ImageListLayout = .Horizontal

    // Keyboard modifier flags for multiple selection
    @State var modifierFlags:NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: 0)

    // Keyboard movement computed location with multiple selections
    @State var nextLocation:URL? = nil

    // Height of the ThumbnailScrollerPanel, modified by the PaneDivider
    @State var scrollViewHeight:CGFloat = 200

    @State var orientation:Image.Orientation = .up

    let minPaneSize:CGFloat = 200

    func rotateRight() -> Image.Orientation {
        switch orientation {
        case Image.Orientation.up:
            return Image.Orientation.right
        case Image.Orientation.right:
            return Image.Orientation.down
        case Image.Orientation.down:
            return Image.Orientation.left
        case Image.Orientation.left:
            return Image.Orientation.up
        default:
            return orientation
        }
    }

    func rotateLeft() -> Image.Orientation {
        switch orientation {
        case Image.Orientation.up:
            return Image.Orientation.left
        case Image.Orientation.right:
            return Image.Orientation.up
        case Image.Orientation.down:
            return Image.Orientation.right
        case Image.Orientation.left:
            return Image.Orientation.down
        default:
            return orientation
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ImageListView(model: model, orientation: $orientation, imageFilter: $imageViewFilter, layout: $imageViewLayout)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                PaneDivider { offset in
                    DispatchQueue.main.async {
                        scrollViewHeight = max(min(scrollViewHeight - offset, geometry.size.height - minPaneSize), minPaneSize)
                    }
                }

                ThumbnailScrollView(model: model, modifierFlags: $modifierFlags, nextLocation: $nextLocation)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: max(scrollViewHeight, 0))
                    .background(KeyEventHandling(keyAction: { char in
                        if (char >= "0" && char <= "9") {
                            // Single image selection mode
                            let zero = Character("0")
                            let index = char == zero ? 9 : (char.wholeNumberValue! - zero.wholeNumberValue!) - 1;
                            if (model.selection.count > 0 && model.selection.count > index) {
                                imageViewFilter = index
                            }
                        } else if (KeyEquivalent(char) == .escape) {
                            // Exit single image selection mode
                            imageViewFilter = -1
                        } else if (KeyEquivalent(char) == .leftArrow || KeyEquivalent(char) == .rightArrow) {
                            // Keyboard navigation
                            nextLocation = model.processKey(key: KeyEquivalent(char))
                            imageViewFilter = -1
                        } else if (char == "]") {
                            orientation = rotateRight()
                        } else if (char == "[") {
                            orientation = rotateLeft()
                        } else if (char == "l" || char == "L") {
                            switch (imageViewLayout) {
                            case .Horizontal:
                                imageViewLayout = .Vertical
                            case .Vertical:
                                imageViewLayout = .Grid
                            case .Grid:
                                imageViewLayout = .Horizontal
                            }
                        }
                    }, modifiersAction: { flags in
                        modifierFlags = flags
                    }))
                    .background(.regularMaterial)
            }
        }
        .onReceive(model.$files) { _ in
            imageViewFilter = -1
        }
        .onReceive(model.$selection) { _ in
            imageViewFilter = -1
        }
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedBrowserModel) private var model: ImageBrowserModel?

        var body: some Commands {
            CommandMenu("Navigation") {
                Button {
                    _ = model?.processKey(key: .leftArrow)
                } label: {
                    Text("Move Left")
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                .disabled(model == nil)

                Button {
                    _ = model?.processKey(key: .rightArrow)
                } label: {
                    Text("Move Right")
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                .disabled(model == nil)
            }
        }
    }
}
