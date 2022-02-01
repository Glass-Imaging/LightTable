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
    static var lruCache:LRUCache<URL> = LRUCache<URL>(1000)

    /// Tries to load a thumbnail for a given URL
    /// - Parameters:
    ///   - url: URL of the image
    ///   - maxSize: maximum size (width/height) aspect ratio preserved
    func loadThumbnail(url: URL, maxSize: Int) {
        let cachedData = ThumbnailLoader.lruCache.get(url)
        if (cachedData != nil) {
            image = (cachedData! as? NSImage)!
            return
        }

        let size = CGSize(width: maxSize, height: maxSize)
        let scale = 1.0
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                       size: size,
                                                       scale: scale,
                                                       representationTypes: .all)
            
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            guard let nsImage = thumbnail?.nsImage else {
                if let error = error {
                    print("error while generating thumbnail \(error.localizedDescription)")
                }
                return
            }
            DispatchQueue.main.async {
                ThumbnailLoader.lruCache.set(url, val: nsImage)
                self.image = nsImage
            }
        }
    }
}
