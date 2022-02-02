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
        .background(model.selection == file ? Color.blue : nil)
    }
}

struct ImageBrowser: View {
    @State var model:ImageBrowserModel

    @State var detailImageViewModel = DetailImageViewModel()
    @State var scrollViewHeight:CGFloat = 200

    @State var commandKeyDown = false

    var body: some View {
        VSplitView {
            DetailImageView(viewModel: detailImageViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                                }
                                model.updateSelection(selection: file)
                            }
                            .focusedSceneValue(\.focusedModel, $model)
                        }
                    }
                    .background(KeyEventHandling(keyAction: { char in
                        // model.processKey(key: KeyEquivalent(char))
                    }, modifiersAction: { modifierFlags in
                        print("Modifiers", modifierFlags, NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.control)

                        if (modifierFlags.contains(.command)) {
                            print("in business!")
                            commandKeyDown = true
                        } else {
                            commandKeyDown = false
                        }
                    }))
                }
            }
            .frame(maxWidth: .infinity, minHeight: scrollViewHeight, maxHeight: scrollViewHeight)
        }
        .onReceive(model.$files) { value in
            model.selection = nil
        }
        .onReceive(model.$selection) { newFile in
            if (newFile != nil) {
                detailImageViewModel.showImage(atURL: newFile!)
            } else {
                detailImageViewModel.hideImage()
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
