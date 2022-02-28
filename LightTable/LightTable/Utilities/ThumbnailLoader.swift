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

import AppKit
import QuickLookThumbnailing

class CachedThumbnail {
    let date:Date
    let image:NSImage

    init(date:Date, image:NSImage) {
        self.date = date
        self.image = image
    }
}

/// Wrapper for QLThumbnailGenerator
/// the class is ObservableObject and has a @Published var so
/// a view can observe it and load a thumbnail as soon as it is ready
class ThumbnailLoader: ObservableObject {
    @Published var image = NSImage()

    // LRU Cache for thumbnails, avoids flashing redraws in the browser, cache up to 1000 thumbnails
    static let lruCache:NSCache<NSString, CachedThumbnail> = {
        let cache = NSCache<NSString, CachedThumbnail>()
        cache.countLimit = 1000
        return cache
    }()

    /// Tries to load a thumbnail for a given URL
    /// - Parameters:
    ///   - url: URL of the image
    ///   - maxSize: maximum size (width/height) aspect ratio preserved
    func loadThumbnail(url: URL, maxSize: CGFloat) {
        let timeStamp = timeStamp(url: url)

        if let cachedData = ThumbnailLoader.lruCache.object(forKey: NSString(string: url.path)) {
            if (cachedData.date == timeStamp) {
                image = cachedData.image
                return
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let size = CGSize(width: maxSize, height: maxSize)
            let scale = 3.0 // High resolution thumbnail
            let request = QLThumbnailGenerator.Request(fileAt: url,
                                                       size: size,
                                                       scale: scale,
                                                       representationTypes: [.thumbnail])

            let generator = QLThumbnailGenerator.shared
            generator.generateRepresentations(for: request) { (thumbnail, type, error) in
                guard let nsImage = thumbnail?.nsImage else {
                    if let error = error {
                        print("error while generating thumbnail \(error.localizedDescription)")
                    }
                    return
                }
                DispatchQueue.main.async {
                    ThumbnailLoader.lruCache.setObject(CachedThumbnail(date: timeStamp, image: nsImage), forKey: NSString(string: url.path))
                    self.image = nsImage
                }
            }
        }
    }
}
