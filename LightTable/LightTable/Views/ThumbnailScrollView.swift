//
//  ThumbnailScrollView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/4/22.
//

import SwiftUI

struct ThumbnailGrid: View {
    @Binding var browserModel:ImageBrowserModel
    @Binding var thumbnailSize:CGFloat

    @State private var scrollViewOffset = CGPoint.zero

    let folderDetailColor = Color(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0 ..< browserModel.directories.count, id: \.self) { directoryIndex in
                if (!browserModel.files[directoryIndex].isEmpty) {
                    let folderName = browserModel.directories[directoryIndex].lastPathComponent
                    let folderListing = browserModel.files[directoryIndex]

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
        // Keep track of the ScrollView position
        .readingScrollView(from: "scroll", into: $scrollViewOffset)
    }
}

struct ThumbnailScrollView: View {
    @Binding var browserModel:ImageBrowserModel
    @Binding var thumbnailSize:CGFloat

    var body: some View {
        if (browserModel.files.count == 0 || browserModel.files[0].count == 0) {
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
                    .onChange(of: browserModel.files) { newFiles in
                        if (newFiles.count == 1 && !newFiles[0].isEmpty) {
                            DispatchQueue.main.async {
                                scroller.scrollTo(newFiles[0][0])
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
