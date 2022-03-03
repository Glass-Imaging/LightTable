// Copyright (c) 2022 Glass Imaging Inc.
// Author: Fabio Riccardi <fabio@glass-imaging.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

struct ImageBrowserView: View {
    @Binding var browserModel:ImageBrowserModel
    @Binding var viewModel:ImageViewModel
    @State var thumbnailSize:CGFloat = 150

    let backgroundColor = Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)
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

                            ThumbnailSizeSlider(value: $thumbnailSize)
                                .padding(.trailing, 10)
                                .help("Thumbnail Size")
                        }
                    }
                    .frame(height: 20)
                }
                .layoutPriority(1)

                ThumbnailScrollView(browserModel: $browserModel, thumbnailSize: $thumbnailSize)
                    .frame(maxWidth: .infinity, minHeight: minPaneSize, maxHeight: .infinity)
                    .background(backgroundColor)
            }
        }
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedBrowserModel) private var browserModel: ImageBrowserModel?
        @FocusedBinding(\.focusedViewModel) private var viewModel: ImageViewModel?

        @State var viewSelection:Int = -1

        var body: some Commands {
            CommandGroup(after: .sidebar) {
                Group {
                    CommandButton(label: "Rotate Left", key: "[") {
                        viewModel?.rotateLeft()
                    }
                    CommandButton(label: "Rotate Right", key: "]") {
                        viewModel?.rotateRight()
                    }

                    CommandButton(label: "Switch Layout", key: "L") {
                        viewModel?.switchLayout()
                    }

                    if let viewModel = viewModel {
                        ToggleMenuButton(label: "Uniform Orientation", key: "O", viewState: viewModel.imageViewState, field: \.useMasterOrientation)
                    }

                    CommandButton(label: "Toggle Image View Data", key: "V") {
                        viewModel?.switchViewInfoItems()
                    }

                    if let viewModel = viewModel {
                        ToggleMenuButton(label: "Show Exif Metadata", key: "I", viewState: viewModel.imageViewState, field: \.showEXIFMetadata)
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

                if let viewSelection = viewModel?.imageViewSelection {
                    let selectionCount = browserModel!.selection.count
                    Menu("View Selection") {
                        let zero = Character("0")
                        ForEach(0...9, id: \.self) { index in
                            let c = Character(UnicodeScalar(Int(zero.asciiValue!) + index + 1)!)

                            CommandToggle(label: "View \(index + 1)", key: index < 9 ? KeyEquivalent(c) : "0", isOn: Binding<Bool>(
                                get: { viewSelection == index },
                                set: {
                                    if $0 {
                                        viewModel?.imageViewSelection(char: index < 9 ? c : zero, selection: browserModel!.selection)
                                    }
                                }
                            )).disabled(index >= selectionCount)
                        }
                        CommandToggle(label: "Show All", key: "`", isOn: Binding<Bool>(
                            get: { viewSelection == -1 },
                            set: {
                                if $0 {
                                    viewModel?.resetImageViewSelection()
                                }
                            }
                        ))
                    }
                    .disabled(browserModel == nil)
                }

                Divider()

                CommandToggle(label: "Full Screen Preview", key: "F",
                              isOn: Binding<Bool>(
                                get: { viewModel?.fullScreen ?? false },
                                set: { viewModel?.fullScreen = $0 }))

                Divider()
            }
        }
    }
}

struct ToggleMenuButton<State>: View where State : ObservableObject {
    let label:String
    let key: KeyEquivalent
    let modifiers: EventModifiers = []

    @ObservedObject var viewState:State
    let field: KeyPath<State, Bool>

    var body: some View {
        CommandToggle(label: label, key: key, modifiers: modifiers, isOn: Binding<Bool>(
            get: { self.viewState[keyPath: field] },
            set: {
                if let keyPath = field as? ReferenceWritableKeyPath<State, Bool> {
                    self.viewState[keyPath: keyPath] = $0
                }
            }
        ))
    }
}
