//
//  ImageLoder.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/30/22.
//

import Combine
import SwiftUI

/// Observable object responsible to load an image to be used by SwiftUI views
class ImageLoader: ObservableObject {
    // LRU Cache for images, minimizes flashing redraws in the browser, cache up to 100 NSData renderings
    static var lruCache:LRUCache<URL> = LRUCache<URL>(10)

    var didChange = PassthroughSubject<NSData, Never>()
    var data = NSData() {
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
                self.data = (cachedData! as? NSData)!
            }
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            // TODO: NSImage appears to be quite slow at this, run it on the loader thread
            // let image = NSImage(dataIgnoringOrientation: data)

            let nsData = NSData(data: data)
//            let source = CGImageSourceCreateWithData(data as CFData, nil)!
//            let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)!
//            print(metadata)

            DispatchQueue.main.async {
                ImageLoader.lruCache.set(url, val: nsData)
                self.data = nsData
            }
        }
        task.resume()
    }
}
