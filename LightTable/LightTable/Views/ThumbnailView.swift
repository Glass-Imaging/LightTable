// Copyright (c) 2022 Glass Imaging Inc.
// Author: Fabio Riccardi <fabio@glass-imaging.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
