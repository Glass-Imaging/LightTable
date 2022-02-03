//
//  ImageLoder.swift
//  PhotoBrowser
//
//  Created by Fabio Riccardi on 1/30/22.
//

import Combine
import SwiftUI

/// Observable object responsible to load an image to be used by SwiftUI views
class ImageLoader: ObservableObject {
    // LRU Cache for images, minimizes flashing redraws in the browser, cache up to 100 NSImage renderings
    static var lruCache:LRUCache<URL> = LRUCache<URL>(10)

    var didChange = PassthroughSubject<NSImage, Never>()
    var data = NSImage() {
        didSet {
            didChange.send(data)
        }
    }

    /// Load an image at the given URL
    /// - Parameter url: The image URL
    func load(url: URL) {
        loadImage(fromURL: url)
    }

    /// Load an image from a given string
    /// - Parameter urlString: The string representing the image URL
    func load(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        load(url: url)
    }

    private func loadImage(fromURL url:URL) {
        let cachedData = ImageLoader.lruCache.get(url)
        if (cachedData != nil) {
            DispatchQueue.main.async {
                self.data = (cachedData! as? NSImage)!
            }
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            // TODO: NSImage appears to be quite slow at this, run it on the loader thread
            let image = NSImage(data: data)

            DispatchQueue.main.async {
                ImageLoader.lruCache.set(url, val: image!)
                self.data = image!
            }
        }
        task.resume()
    }
}
