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

struct ThumbnailGrid: View {
    @Binding var browserModel:ImageBrowserModel
    @Binding var thumbnailSize:CGFloat

    @State private var scrollViewOffset = CGPoint.zero

    let folderDetailColor = Color(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(browserModel.folders) { folder in
                if (!folder.files.isEmpty) {
                    let folderName = folder.url.lastPathComponent
                    let folderListing = folder.files

                    Section(header: ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(folderDetailColor)
                            .frame(height: 20)
                        Text("\(folderName) - \(folderListing.count) images")
                            .offset(x: max(scrollViewOffset.x, 0) + 3)
                            .animation(.easeIn, value: scrollViewOffset)
                    }) {
                        LazyHStack(alignment: .top) {
                            ForEach(folderListing, id: \.self) { file in
                                ThumbnailButtonView(file: file, selection: $browserModel.selection, thumbnailSize: $thumbnailSize) { modifier in
                                    // Handle Command-Click mouse actions
                                    if (modifier.contains(.command)) {
                                        browserModel.addToSelection(file: file)
                                    } else {
                                        browserModel.updateSelection(file: file)
                                    }
                                }
                                .id(file)
                            }
                        }
                        // TODO: Kludge, LazyHStack tends to grow vertically, so we need to constrain it
                        .frame(maxHeight: thumbnailSize + 20)
                    }
                }
            }
            Spacer()
        }
        // Keep track of the ScrollView position to update the folder name offset
        .readingScrollView(from: "scroll", into: $scrollViewOffset)
    }
}

struct ThumbnailScrollView: View {
    @Binding var browserModel:ImageBrowserModel
    @Binding var thumbnailSize:CGFloat

    var body: some View {
        if (browserModel.folders.count == 0 || browserModel.folders[0].files.count == 0) {
            Text("Select a folder with images")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            GeometryReader { geometry in
                ScrollViewReader { scroller in
                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        ThumbnailGrid(browserModel: $browserModel, thumbnailSize: $thumbnailSize)
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    }
                    .coordinateSpace(name: "scroll")
                    .onChange(of: browserModel.folders) { newFiles in
                        if (newFiles.count == 1 && !newFiles[0].files.isEmpty) {
                            DispatchQueue.main.async {
                                scroller.scrollTo(newFiles[0].files[0])
                            }
                        }
                    }
                    .onChange(of: browserModel.selection) { selection in
                        if (!selection.isEmpty) {
                            if (browserModel.nextLocation != nil) {
                                DispatchQueue.main.async {
                                    withAnimation(.linear) {
                                        scroller.scrollTo(browserModel.nextLocation)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
