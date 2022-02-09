//
//  ImageListView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/4/22.
//

import SwiftUI

enum ImageListLayout {
    case Horizontal
    case Vertical
    case Grid
}

struct ImageListView: View {
    @ObservedObject var model:ImageBrowserModel

    @Binding var orientation:Image.Orientation

    // If imageFilter > 0 only show the image indicated by imageFilter
    @Binding var imageFilter:Int

    @Binding var layout:ImageListLayout

    func gridLayout(count:Int) -> [GridItem] {
        let gridItem = GridItem(.flexible())
        var gridItemLayout:[GridItem] = [gridItem]

        if (count > 2) {
            gridItemLayout.append(gridItem)
        }
        if (count > 6) {
            gridItemLayout.append(gridItem)
        }
        if (count > 12) {
            gridItemLayout.append(gridItem)
        }
        return gridItemLayout
    }

    func gridSizeConstraints(count:Int) -> CGSize {
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

    var body: some View {
        HStack {
            if (model.selection.count == 0) {
                Text("Make a selection.")
                    .padding(100)
            } else {
                if (imageFilter >= 0 && imageFilter < model.selection.count) {
                    ImageView(withURL: model.selection[imageFilter], orientation: _orientation)
                } else {
                    let count = min(model.selection.count, 16)

                    switch (layout) {
                    case .Horizontal:
                        ForEach(0 ..< count, id: \.self) { index in
                            let file = model.selection[index]
                            ImageView(withURL: file, orientation: _orientation)
                                .id(file)
                        }
                    case .Vertical:
                        VStack {
                            ForEach(0 ..< count, id: \.self) { index in
                                let file = model.selection[index]
                                ImageView(withURL: file, orientation: _orientation)
                                    .id(file)
                            }
                        }
                    case .Grid:
                        let gridConstraints = gridSizeConstraints(count: model.selection.count)
                        GeometryReader { geometry in
                            VStack {
                                let gridItemLayout:[GridItem] = gridLayout(count: model.selection.count)
                                LazyHGrid(rows: gridItemLayout) {
                                    ForEach(0 ..< count, id: \.self) { index in
                                        let file = model.selection[index]
                                        ImageView(withURL: file, orientation: _orientation)
                                            .id(file)
                                    }.frame(width: geometry.size.width / gridConstraints.width,
                                            height: geometry.size.height / gridConstraints.height)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

