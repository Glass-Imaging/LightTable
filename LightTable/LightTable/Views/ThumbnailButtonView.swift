//
//  ThumbnailButtonView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/7/22.
//

import SwiftUI

struct ThumbnailButtonView: View {
    var file:URL
    @ObservedObject var model:ImageBrowserModel
    var action: (_ modifiers: EventModifiers) -> Void

    // let thumbnailSize:CGFloat = 150

    var body: some View {
        Button(action: {
            action([])
        }) {
            let selected = model.selection.contains(file)

            VStack {
                ThumbnailView(withURL: file)
                    .border(selected ? Color.accentColor : Color.clear, width: 2)
                Text(file.lastPathComponent)
                    .lineLimit(1)
                    .font(.caption)
                    .background(selected ? Color.accentColor : nil)
                    .cornerRadius(3)
                    .frame(width: model.thumbnailSize, height: 20)
            }
            .frame(width: model.thumbnailSize, height: model.thumbnailSize + 20)
            // Command-Click Multiple Selection
            .gesture(TapGesture().modifiers(.command).onEnded {
                action(.command)
            })

        }
        .buttonStyle(PlainButtonStyle())
    }
}

