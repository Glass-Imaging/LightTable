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

    func gridLayout(count:Int) -> [GridItem] {
        let gridItem = GridItem(.flexible())
        var gridItemLayout:[GridItem] = []
        for _ in 0 ..< count {
            gridItemLayout.append(gridItem)
        }
        return gridItemLayout
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
            if (model.selection.count == 0) {
                Text("Make a selection.")
            } else {
                if (model.imageViewSelection >= 0 && model.imageViewSelection < model.selection.count) {
                    ImageView(url: model.selection[model.imageViewSelection], model: model, index: model.imageViewSelection)
                } else {
                    let gridConstraints = gridSizeConstraints(count: model.selection.count, layout: model.imageViewLayout)
                    GeometryReader { geometry in
                        let gridItemLayout:[GridItem] = gridLayout(count: Int(gridConstraints.width))
                        LazyVGrid(columns: gridItemLayout) {
                            let items = min(model.selection.count, 16)
                            ForEach(0 ..< items, id: \.self) { index in
                                let file = model.selection[index]
                                ImageView(url: file, model: model, index: index)
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
