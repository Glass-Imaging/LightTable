//
//  ThumbnailView.swift
//  LightTable
//
//  Created by Gualtiero Frigerio on 23/08/21.
//

import SwiftUI

struct ThumbnailView: View {
    @ObservedObject var thumbnailLoader = ThumbnailLoader()

    let maxThumbnailSize = CGFloat(200)

    init(withURL url: URL) {
        thumbnailLoader.loadThumbnail(url: url, maxSize: maxThumbnailSize)
    }
    
    var body: some View {
        if (thumbnailLoader.image.isValid) {
            Image(nsImage: thumbnailLoader.image)
                .interpolation(.high)
                .antialiased(true)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFit()
                .font(Font.system(size: maxThumbnailSize))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.secondary)
        }
    }
}

fileprivate let testURL = URL(string: "")!

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(withURL: testURL)
    }
}
