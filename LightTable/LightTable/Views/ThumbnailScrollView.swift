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

        ScrollViewReader { scroller in
            ScrollView(.horizontal, showsIndicators: true) {
                if (model.files.count == 0) {
                    Text("Select a folder with images")
                        .padding(100)
                } else {
                    LazyHStack(alignment: .bottom) {
                        ForEach(model.files, id: \.self) { file in
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
                    DispatchQueue.main.async {
                        scroller.scrollTo(nextLocation != nil ? nextLocation : selection[selection.count-1])
                        nextLocation = nil
                    }
                }
            }
        }
    }
}
