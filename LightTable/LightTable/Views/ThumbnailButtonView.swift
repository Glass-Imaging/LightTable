//
//  ThumbnailButtonView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/7/22.
//

import SwiftUI

struct ThumbnailButtonView: View {
    let file:URL
    @Binding var selection:[URL]
    @Binding var thumbnailSize:CGFloat
    let action: (_ modifiers: EventModifiers) -> Void

    var body: some View {
        Button(action: {
            // Single Click
            action([])
        }) {
            let selected = selection.contains(file)

            VStack {
                ThumbnailView(withURL: file)
                    .border(selected ? Color.accentColor : Color.clear, width: 2)
                Text(file.lastPathComponent)
                    .lineLimit(1)
                    .font(.caption)
                    .background(selected ? Color.accentColor : nil)
                    .cornerRadius(3)
                    .frame(width: thumbnailSize, height: 20)
            }
            .frame(width: thumbnailSize, height: thumbnailSize + 20)
            // Double Click: reveal the file in Finder
            .gesture(TapGesture(count: 2).onEnded {
                action([])
                NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: "")
            })
            // Command-Click Multiple Selection
            .gesture(TapGesture().modifiers(.command).onEnded {
                action(.command)
            })
        }
        .buttonStyle(PlainButtonStyle())
    }
}
