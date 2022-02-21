//
//  ThumbnailScrollView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/4/22.
//

import SwiftUI

struct ThumbnailGrid: View {
    @Binding var model:ImageBrowserModel

    @State private var scrollViewOffset = CGPoint.zero

    let folderDetailColor = Color(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0 ..< model.directories.count, id: \.self) { directoryIndex in
                if (!model.files[directoryIndex].isEmpty) {
                    let folderName = model.directories[directoryIndex].lastPathComponent
                    let folderListing = model.files[directoryIndex]

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
                                ThumbnailButtonView(file: file, selection: $model.selection, thumbnailSize: $model.thumbnailSize) { modifier in
                                    // Handle Command-Click mouse actions
                                    if (modifier.contains(.command)) {
                                        model.addToSelection(file: file)
                                    } else {
                                        model.updateSelection(file: file)
                                    }
                                }
                                .id(file)
                                .focusedSceneValue(\.focusedBrowserModel, $model)
                            }
                        }
                        // TODO: Kludge, LazyHStack tends to grow vertically, so we need to constrain it
                        .frame(maxHeight: model.thumbnailSize + 20)
                    }
                }
            }
            Spacer()
        }
        // Keep track of the ScrollView position
        .readingScrollView(from: "scroll", into: $scrollViewOffset)
    }
}

struct ThumbnailScrollView: View {
    @Binding var model:ImageBrowserModel

    var body: some View {
        if (model.files.count == 0 || model.files[0].count == 0) {
            Text("Select a folder with images")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            GeometryReader { geometry in
                ScrollViewReader { scroller in
                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        ThumbnailGrid(model: $model)
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    }
                    .coordinateSpace(name: "scroll")
                    .onChange(of: model.files) { newFiles in
                        if (newFiles.count == 1 && !newFiles[0].isEmpty) {
                            DispatchQueue.main.async {
                                scroller.scrollTo(newFiles[0][0])
                            }
                        }
                    }
                    .onChange(of: model.selection) { selection in
                        if (!selection.isEmpty) {
                            if (model.nextLocation != nil) {
                                DispatchQueue.main.async {
                                    withAnimation(.linear) {
                                        scroller.scrollTo(model.nextLocation)
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
