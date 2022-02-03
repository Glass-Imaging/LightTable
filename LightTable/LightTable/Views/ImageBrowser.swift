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
    @State var commandKeyDown = false

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
                    ForEach(model.selection, id: \.self) { file in
                        ImageView(withURL: file)
                            .id(file)
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
                                    if (commandKeyDown) {
                                        print("Command-Click! :D")
                                        model.addToSelection(file: file)
                                    } else {
                                        model.updateSelection(file: file)
                                    }
                                    print(model.selection)
                                }
                                .id(file)
                                .focusedSceneValue(\.focusedModel, modelBinding)
                            }
                        }
                        .background(KeyEventHandling(keyAction: { char in
                            // model.processKey(key: KeyEquivalent(char))
                        }, modifiersAction: { modifierFlags in
                            print("Modifiers", modifierFlags, NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.control)

                            if (modifierFlags.contains(.command)) {
                                commandKeyDown = true
                            } else {
                                commandKeyDown = false
                            }
                        }))
                    }
                }
                .onReceive(model.$files) { newFiles in
                    model.selection = []

                    if (newFiles.count > 0) {
                        // Wait for the ScrollView to stabilize
                        DispatchQueue.main.async {
                            scroller.scrollTo(newFiles[0])
                        }
                    }
                }
                .onReceive(model.$selection) { selection in
                    if (!selection.isEmpty) {
                        scroller.scrollTo(selection[0])
                    }
                }
                .frame(maxWidth: .infinity, minHeight: scrollViewHeight, maxHeight: scrollViewHeight)
            }
        }
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedModel) private var model: ImageBrowserModel?

        var body: some Commands {
            CommandMenu("Navigation") {
                Button {
                    model?.processKey(key: .leftArrow)
                } label: {
                    Text("Move Left")
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                .disabled(model == nil)

                Button {
                    model?.processKey(key: .rightArrow)
                } label: {
                    Text("Move Right")
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                .disabled(model == nil)
            }
        }
    }
}

extension FocusedValues {
    var focusedModel: Binding<ImageBrowserModel>? {
        get { self[FocusedImagerowserModelKey.self] }
        set { self[FocusedImagerowserModelKey.self] = newValue }
    }

    private struct FocusedImagerowserModelKey: FocusedValueKey {
        typealias Value = Binding<ImageBrowserModel>
    }
}
