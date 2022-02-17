//
//  ThumbnailLoader.swift
//  ThumbnailLoader
//
//  Created by Gualtiero Frigerio on 23/08/21.
//

import AppKit
import QuickLookThumbnailing

/// Wrapper for QLThumbnailGenerator
/// the class is ObservableObject and has a @Published var so
/// a view can observe it and load a thumbnail as soon as it is ready
class ThumbnailLoader: ObservableObject {
    @Published var image = NSImage()

    // LRU Cache for thumbnails, avoids flashing redraws in the browser, cache up to 1000 thumbnails
    static let lruCache:NSCache<NSString, NSImage> = {
        let cache = NSCache<NSString, NSImage>()
        cache.countLimit = 1000
        return cache
    }()

    /// Tries to load a thumbnail for a given URL
    /// - Parameters:
    ///   - url: URL of the image
    ///   - maxSize: maximum size (width/height) aspect ratio preserved
    func loadThumbnail(url: URL, maxSize: CGFloat) {
        if let cachedData = ThumbnailLoader.lruCache.object(forKey: NSString(string: url.path)) {
            image = cachedData
            return
        }

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
                ThumbnailLoader.lruCache.setObject(nsImage, forKey: NSString(string: url.path))
                self.image = nsImage
            }
        }
    }
}
