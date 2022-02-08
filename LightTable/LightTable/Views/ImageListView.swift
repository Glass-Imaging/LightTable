//
//  ImageListView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/4/22.
//

import SwiftUI

struct ImageListView: View {
    @ObservedObject var model:ImageBrowserModel

    @Binding var orientation:Image.Orientation

    // If imageFilter > 0 only show the image indicated by imageFilter
    @Binding var imageFilter:Int

    var body: some View {
        HStack {
            if (model.selection.count == 0) {
                Text("Make a selection.")
                    .padding(100)
            } else {
                if (imageFilter >= 0 && imageFilter < model.selection.count) {
                    ImageView(withURL: model.selection[imageFilter], orientation: _orientation)
                } else {
                    ForEach(model.selection, id: \.self) { file in
                        ImageView(withURL: file, orientation: _orientation)
                            .id(file)
                    }
                }
            }
        }
    }
}

