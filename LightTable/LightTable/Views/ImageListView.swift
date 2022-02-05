//
//  ImageListView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/4/22.
//

import SwiftUI

struct ImageListView: View {
    @ObservedObject var model:ImageBrowserModel

    // If imageFilter > 0 only show the image indicated by imageFilter
    @Binding var imageFilter:Int

    var body: some View {
        HStack {
            if (model.selection.count == 0) {
                Text("Make a selection.")
                    .padding(100)
            } else {
                if (imageFilter >= 0 && imageFilter < model.selection.count) {
                    ImageView(withURL: model.selection[imageFilter])
                } else {
                    ForEach(model.selection, id: \.self) { file in
                        ImageView(withURL: file)
                            .id(file)
                    }
                }
            }
        }
    }
}

