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

struct ScaleFactorIndicator: View {
    @ObservedObject var viewState:ImageViewState

    var body: some View {
        Text(viewState.viewScaleFactor == 0 ? "Fit" : "\(Int(viewState.viewScaleFactor))X")
            .foregroundColor(viewState.viewScaleFactor > 0 ? Color.blue : Color.gray)
            .frame(width: 25)
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray).opacity(0.1)
            )
    }
}

struct OrientationIconView: View {
    @ObservedObject var viewState:ImageViewState

    var body: some View {
        let orientation = viewState.orientation

        let orientationIconName =
            orientation == .right ? "person.fill.turn.right" :
            orientation == .left ? "person.fill.turn.left" :
            orientation == .down ? "person.fill.turn.down" : "person.fill"

        Image(systemName: orientationIconName)
            .foregroundColor(orientation == .up ? Color.gray : Color.blue)
            .font(Font.system(size: 14))
            .frame(width: 20, height: 20)
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray).opacity(0.1)
            )
    }
}

struct ImageInfoPicker: View {
    @ObservedObject var viewState:ImageViewState

    var body: some View {
        Picker("Image Info Level", selection: $viewState.viewInfoItems) {
            Image(systemName: "bubble.left")
            .help("No Info")
            .tag(0)

            Image(systemName: "ellipsis.bubble")
            .help("File Name")
            .tag(1)

            Image(systemName: "captions.bubble")
            .help("File Name and Path")
            .tag(2)

            Image(systemName: "text.bubble")
            .help("Full Info")
            .tag(3)
        }
        .pickerStyle(.menu)
    }
}

struct ToggleButton<State>: View where State : ObservableObject {
    let labelOn:String
    let labelOff:String

    @ObservedObject var viewState:State
    let field: KeyPath<State, Bool>

    var body: some View {
        Toggle(isOn: Binding<Bool>(
            get: { self.viewState[keyPath: field] },
            set: {
                if let field = field as? ReferenceWritableKeyPath<State, Bool> {
                    self.viewState[keyPath: field] = $0
                }
            })) {
                Image(systemName: self.viewState[keyPath: field] ? labelOn : labelOff)
            }
            .foregroundColor(self.viewState[keyPath: field] ? .blue : .gray)
            .toggleStyle(.button)
    }
}

extension ImageListView {
    @ToolbarContentBuilder func ImageViewToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            HStack {
                Button(action: {
                    viewModel.zoomOut()
                }) {
                    Image(systemName: "minus.magnifyingglass")
                    .help("Zoom Out")
                }
                Button(action: {
                    viewModel.zoomIn()
                }) {
                    Image(systemName: "plus.magnifyingglass")
                    .help("Zoom In")
                }
                Button(action: {
                    viewModel.zoomToFit()
                }) {
                    Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                    .help("Zoom To Fit")
                }

                ScaleFactorIndicator(viewState: viewModel.imageViewState)

                Divider()
            }}

        ToolbarItemGroup(placement: .automatic) {
            HStack {
                Button(action: {
                    viewModel.rotateLeft()
                }) {
                    Image(systemName: "rotate.left")
                    .help("Rotate Left")
                }
                Button(action: {
                    viewModel.rotateRight()
                }) {
                    Image(systemName: "rotate.right")
                    .help("Rotate Right")
                }

                OrientationIconView(viewState: viewModel.imageViewState)

                Divider()

                ToggleButton(labelOn: "location.north.fill", labelOff: "location.slash.fill",
                             viewState: viewModel.imageViewState, field: \.useMasterOrientation)
                    .frame(width: 20)

                Divider()
            }
        }

        ToolbarItemGroup(placement: .automatic) {
            HStack {
                ToggleButton(labelOn: "info.circle.fill", labelOff: "info.circle",
                             viewState: viewModel.imageViewState, field: \.showEXIFMetadata)
                    .frame(width: 20)

                ImageInfoPicker(viewState: viewModel.imageViewState)

                Divider()

                Button(action: {
                    viewModel.resetImageViewSelection()
                }, label: {
                    let caption = viewModel.imageViewSelection >= 0 ? "\(viewModel.imageViewSelection + 1)" : "—"
                    Image(systemName: "viewfinder")
                        .help("View Selection")
                    Text(caption)
                        .frame(width: 12)
                }).foregroundColor(viewModel.imageViewSelection >= 0 ? .blue : .gray)

                Picker("View Arrangement", selection: $viewModel.imageViewLayout) {
                    Image(systemName: "rectangle.split.3x1")
                        .help("Horizontal")
                        .tag(ImageListLayout.Horizontal)

                    Image(systemName: "rectangle.split.1x2")
                        .help("Vertical")
                        .tag(ImageListLayout.Vertical)

                    Image(systemName: "rectangle.split.3x3")
                        .help("Grid")
                        .tag(ImageListLayout.Grid)
                }
                .pickerStyle(.inline)

                Divider()

                Toggle(isOn: $viewModel.fullScreen, label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .help("Full Screen View")
                })
                .foregroundColor(viewModel.fullScreen ? .blue : .gray)
                .toggleStyle(.button)
            }
        }
    }
}
