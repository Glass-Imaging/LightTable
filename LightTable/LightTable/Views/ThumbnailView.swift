//
//  ThumbnailView.swift
//  LightTable
//
//  Created by Gualtiero Frigerio on 23/08/21.
//

import SwiftUI

struct ThumbnailView: View {
    @ObservedObject var thumbnailLoader = ThumbnailLoader()
    
    init(withURL url: URL, maxSize: Int) {
        thumbnailLoader.loadThumbnail(url: url, maxSize: maxSize)
    }
    
    var body: some View {
        Image(nsImage: thumbnailLoader.image)
            .frame(width: 200, height: 200)
    }
}

fileprivate let testURL = URL(string: "")!

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(withURL: testURL, maxSize: 200)
    }
}
