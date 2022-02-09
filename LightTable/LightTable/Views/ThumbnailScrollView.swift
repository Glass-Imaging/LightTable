//
//  ThumbnailScrollView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/4/22.
//

import SwiftUI

struct ThumbnailScrollView: View {
    @ObservedObject var model:ImageBrowserModel

    @Binding var modifierFlags:NSEvent.ModifierFlags
    @Binding var nextLocation:URL?

    @State private var scrollViewOffset = CGFloat.zero

    var body: some View {
        // We need a binding for .focusedSceneValue, although model as @ObservedObject is read only...
        let modelBinding = Binding<ImageBrowserModel>(
            get: { model },
            set: { val in }
        )

        if (model.files.count == 0) {
            Text("Select a folder with images")
                .padding(100)
                .frame(height: 200)
        } else {
            GeometryReader { geometry in
                ScrollViewReader { scroller in
                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        VStack(alignment: .leading) {
                            Spacer()

                            ForEach(0 ..< model.directories.count, id: \.self) { directoryIndex in
                                VStack(alignment: .leading) {
                                    // Directory name label
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .foregroundColor(Color.black)
                                            .frame(height: 20)

                                        Text(model.directories[directoryIndex].lastPathComponent)
                                            .offset(x: max(scrollViewOffset, 0) + 3, y: 0)
                                            .animation(.easeIn, value: scrollViewOffset)
                                    }

                                    LazyHStack(alignment: .bottom, spacing: 8) {
                                        ForEach(model.files[directoryIndex], id: \.self) { file in
                                            ThumbnailButtonView(file: file, model: model) {
                                                // Handle Command-Click mouse actions
                                                if (modifierFlags.contains(.command)) {
                                                    model.addToSelection(file: file)
                                                } else {
                                                    model.updateSelection(file: file)
                                                }
                                            }
                                            .id(file)
                                            .focusedSceneValue(\.focusedBrowserModel, modelBinding)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(minWidth: geometry.size.width, alignment: .leading)
                        // Keep track of the ScrollView position
                        .readingScrollView(from: "scroll", into: $scrollViewOffset)
                    }
                    .frame(maxHeight: 200 * CGFloat(model.directories.count))
                    .coordinateSpace(name: "scroll")
                    .onReceive(model.$files) { newFiles in
                        if (!newFiles.isEmpty && !newFiles[0].isEmpty) {
                            DispatchQueue.main.async {
                                scroller.scrollTo(newFiles[0][0])
                            }
                        }
                    }
                    .onReceive(model.$selection) { selection in
                        if (!selection.isEmpty) {
                            if (nextLocation != nil) {
                                DispatchQueue.main.async {
                                    withAnimation(.linear) {
                                        scroller.scrollTo(nextLocation)
                                    }
                                }
                                nextLocation = nil
                            }
                        }
                    }
                }
            }
        }
    }
}
