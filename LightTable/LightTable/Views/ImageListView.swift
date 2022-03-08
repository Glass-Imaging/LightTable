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

enum ImageListLayout {
    case Horizontal
    case Vertical
    case Grid
}

struct ImageListView: View {
    @Binding var browserModel:ImageBrowserModel
    @ObservedObject var viewModel:ImageViewModel

    // Used by toolbar
    @Environment(\.controlActiveState) var windowState: ControlActiveState

    init(browserModel:Binding<ImageBrowserModel>, viewModel:ImageViewModel) {
        self._browserModel = browserModel
        self.viewModel = viewModel
    }

    func gridSizeConstraints(count:Int, layout: ImageListLayout) -> CGSize {
        switch layout {
        case .Horizontal:
            return CGSize(width: count, height: 1)
        case .Vertical:
            return CGSize(width: 1, height: count)
        case .Grid:
            if (count == 1) {
                return CGSize(width: 1, height: 1)
            } else if (count == 2) {
                return CGSize(width: 2, height:1)
            } else if (count >= 3 && count <= 4) {
                return CGSize(width: 2, height:2)
            } else if (count >= 5 && count <= 6) {
                return CGSize(width: 3, height:2)
            } else if (count >= 7 && count <= 9) {
                return CGSize(width: 3, height:3)
            } else if (count >= 10 && count <= 12) {
                return CGSize(width: 4, height:3)
            } else /* if (count >= 13) */ {
                return CGSize(width: 4, height:4)
            }
        }
    }

    var body: some View {
        HStack {
            if (browserModel.selection.count == 0) {
                Text("Make a selection.")
            } else {
                if (viewModel.imageViewSelection >= 0 && viewModel.imageViewSelection < browserModel.selection.count) {
                    let file = browserModel.selection[viewModel.imageViewSelection]
                    ImageView(url: file, fileIndex: browserModel.fileIndex(file: file), index: viewModel.imageViewSelection)
                } else {
                    let gridConstraints = gridSizeConstraints(count: browserModel.selection.count, layout: viewModel.imageViewLayout)
                    GeometryReader { geometry in
                        let gridItemLayout = [GridItem](repeating: GridItem(.flexible(), spacing: 8), count: Int(gridConstraints.width))

                        LazyVGrid(columns: gridItemLayout, spacing: 4) {
                            let items = min(browserModel.selection.count, 16)
                            ForEach(0 ..< items, id: \.self) { index in
                                let file = browserModel.selection[index]
                                ImageView(url: file, fileIndex: browserModel.fileIndex(file: file), index: index)
                                    .id(file)
                            }.frame(width: geometry.size.width / gridConstraints.width,
                                    height: geometry.size.height / gridConstraints.height)
                        }
                    }
                }
            }
        }
        .toolbar {
            ImageViewToolbar()
        }
    }
}
