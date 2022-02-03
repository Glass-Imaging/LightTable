//
//  ImageBrowser.swift
//  PhotoBrowser
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: { }
        }
        .buttonStyle(PlainButtonStyle())
        .background(configuration.isOn ? Color.blue : nil)
    }
}

struct Thumbnail: View {
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
                                Thumbnail(file: file, model: model) {
                                    if (modifierFlags.contains(.command)) {
                                        print("Command-Click! :D")
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
                            if (char >= "1" && char <= "9") {
                                let index = (char.wholeNumberValue! - Character("0").wholeNumberValue!) - 1;
                                print("image number", index, model.selection.count)

                                if (model.selection.count > 0 && model.selection.count > index) {
                                    selectImage = index
                                }
                            } else if (KeyEquivalent(char) == .escape) {
                                print("reset image number")
                                selectImage = -1
                            } else if (KeyEquivalent(char) == .leftArrow || KeyEquivalent(char) == .rightArrow) {
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
