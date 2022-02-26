//
//  ImageLoder.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/30/22.
//

import Combine
import SwiftUI

class ImageLoader: ObservableObject {
    static let lruCache:NSCache<NSString, CGImageWithMetadata> = {
        let cache = NSCache<NSString, CGImageWithMetadata>()
        cache.countLimit = 20
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

    func load(url: URL) {
        loadImage(fromURL: url)
    }

    private func loadImage(fromURL url:URL) {
        let timeStamp = timeStamp(url: url)

        if let cachedData = ImageLoader.lruCache.object(forKey: NSString(string: url.path)) {
            if (cachedData.date == timeStamp) {
                DispatchQueue.main.async {
                    self.imageWithMetadata = cachedData
                }
                return
            }
        }

        if let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
            if let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) {
                let cgImageProperties = CGImageSourceCopyPropertiesAtIndex(cgImageSource, 0, nil)

                DispatchQueue.main.async {
                    let newImageWithMetadata = CGImageWithMetadata(url: url, date: timeStamp, image: cgImage, metadata: cgImageProperties!)
                    ImageLoader.lruCache.setObject(newImageWithMetadata, forKey: NSString(string: url.path))
                    self.imageWithMetadata = newImageWithMetadata
                }
                return
            }
        }
        print("Problems reading image file:", url)
    }
}
