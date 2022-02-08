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
            ScrollViewReader { scroller in
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    VStack(alignment: .leading) {
                        ForEach(model.files, id: \.self) { listing in
                            VStack(alignment: .leading) {
                                LazyHStack(alignment: .bottom, spacing: 8) {
                                    ForEach(listing, id: \.self) { file in
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
                }
                .onReceive(model.$files) { newFiles in
                    if (model.files.isEmpty && !newFiles.isEmpty) {
                        DispatchQueue.main.async {
                            scroller.scrollTo(newFiles[0][0])
                        }
                    }
                }
                .onReceive(model.$selection) { selection in
                    if (!selection.isEmpty) {
                        DispatchQueue.main.async {
                            if (nextLocation != nil) {
                                scroller.scrollTo(nextLocation)
                            }
                        }
                    }
                }
            }
        }
    }
}