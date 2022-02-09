//
//  ThumbnailView.swift
//  LightTable
//
//  Created by Gualtiero Frigerio on 23/08/21.
//

import SwiftUI

struct ThumbnailView: View {
    @ObservedObject var thumbnailLoader = ThumbnailLoader()

    private var size: CGFloat

    init(withURL url: URL, size: CGFloat) {
        self.size = size
        thumbnailLoader.loadThumbnail(url: url, maxSize: size)
    }
    
    var body: some View {
        if (thumbnailLoader.image.isValid) {
            Image(nsImage: thumbnailLoader.image)
        } else {
            Image(systemName: "photo")
                .font(Font.system(size: 100))
        }
    }
}

fileprivate let testURL = URL(string: "")!

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(withURL: testURL, size: 150)
    }
}
