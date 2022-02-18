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
    static let lruCache:NSCache<NSString, CGImageWithMetadata> = {
        let cache = NSCache<NSString, CGImageWithMetadata>()
        cache.countLimit = 10
        return cache
    }()

    var didChange = PassthroughSubject<CGImageWithMetadata, Never>()
    var imageWithMetadata:CGImageWithMetadata? = nil {
        didSet {
            if let imageWithMetadata = imageWithMetadata {
                didChange.send(imageWithMetadata)
            }
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
        if let cachedData = ImageLoader.lruCache.object(forKey: NSString(string: url.path)) {
            DispatchQueue.main.async {
                self.imageWithMetadata = cachedData
            }
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        if let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil) {
                            if let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) {
                                let cgImageProperties = CGImageSourceCopyPropertiesAtIndex(cgImageSource, 0, nil)

                                DispatchQueue.main.async {
                                    let newImageWithMetadata = CGImageWithMetadata(image: cgImage, metadata: cgImageProperties!)
                                    ImageLoader.lruCache.setObject(newImageWithMetadata, forKey: NSString(string: url.path))
                                    self.imageWithMetadata = newImageWithMetadata
                                }
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
}
