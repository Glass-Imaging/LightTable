//
//  ImageBrowser.swift
//  PhotoBrowser
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

struct ThumbnailButtonView: View {
    var file:URL
    @ObservedObject var model:ImageBrowserModel
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                ThumbnailView(withURL: file, maxSize: 200)
                Text(file.lastPathComponent)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(model.selection.contains(file) ? Color.blue : nil)
    }
}

struct ImageBrowser: View {
    @ObservedObject var model:ImageBrowserModel

    @State var scrollViewHeight:CGFloat = 200
    @State var modifierFlags:NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: 0)

    @State var selectImage = -1
    @State var nextLocation:URL? = nil

    var body: some View {
        // We need a binding for .focusedSceneValue, although model as @ObservedObject is read only...
        let modelBinding = Binding<ImageBrowserModel>(
            get: { model },
            set: { val in }
        )

        VSplitView {
            HStack {
                if (model.selection.count == 0) {
                    Text("Make a selection.")
                        .padding(100)
                } else {
                    if (selectImage >= 0 && selectImage < model.selection.count) {
                        ImageView(withURL: model.selection[selectImage])
                    } else {
                        ForEach(model.selection, id: \.self) { file in
                            ImageView(withURL: file)
                                .id(file)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ScrollViewReader { scroller in
                ScrollView(.horizontal, showsIndicators: true) {
                    if (model.files.count == 0) {
                        Text("Select a folder with images")
                            .padding(100)
                    } else {
                        LazyHStack(alignment: .bottom) {
                            ForEach(model.files, id: \.self) { file in
                                ThumbnailButtonView(file: file, model: model) {
                                    // Handle Command-Click mouse actions
                                    if (modifierFlags.contains(.command)) {
                                        model.addToSelection(file: file)
                                    } else {
                                        model.updateSelection(file: file)
                                    }
                                    print(model.selection)
                                }
                                .id(file)
                                .focusedSceneValue(\.focusedBrowserModel, modelBinding)
                            }
                        }
                        .background(KeyEventHandling(keyAction: { char in
                            if (char >= "0" && char <= "9") {
                                // Single image selection mode
                                let zero = Character("0")
                                let index = char == zero ? 9 : (char.wholeNumberValue! - zero.wholeNumberValue!) - 1;
                                if (model.selection.count > 0 && model.selection.count > index) {
                                    selectImage = index
                                }
                            } else if (KeyEquivalent(char) == .escape) {
                                // Exit single image selection mode
                                selectImage = -1
                            } else if (KeyEquivalent(char) == .leftArrow || KeyEquivalent(char) == .rightArrow) {
                                // Keyboard navigation
                                nextLocation = model.processKey(key: KeyEquivalent(char))
                                selectImage = -1
                            }
                        }, modifiersAction: { flags in
                            modifierFlags = flags
                        }))
                    }
                }
                .onReceive(model.$files) { newFiles in
                    model.selection = []
                    selectImage = -1

                    if (newFiles.count > 0) {
                        // Wait for the ScrollView to stabilize
                        DispatchQueue.main.async {
                            scroller.scrollTo(newFiles[0])
                        }
                    }
                }
                .onReceive(model.$selection) { selection in
                    selectImage = -1

                    if (!selection.isEmpty) {
                        DispatchQueue.main.async {
                            scroller.scrollTo(nextLocation != nil ? nextLocation : selection[selection.count-1])
                            nextLocation = nil
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: scrollViewHeight)
            }
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
