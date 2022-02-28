//
//  ImageLoder.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/30/22.
//

import SwiftUI

func CreateCGImage(_ cgImageSource: CGImageSource) -> CGImage? {
    if let imageType = CGImageSourceGetType(cgImageSource) as String? {
        if imageType == "public.jpeg" || imageType == "public.heic" {
            return CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil)
        } else {
            let options = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: max(10 * 1024, 10 * 1024)
            ] as CFDictionary
            return CGImageSourceCreateThumbnailAtIndex(cgImageSource, 0, options)
        }
    }
    return nil
}

class ImageLoader: ObservableObject {
    static let lruCache:NSCache<NSString, ImageWithMetadata> = {
        let cache = NSCache<NSString, ImageWithMetadata>()
        cache.countLimit = 20
        return cache
    }()

    @Published var imageWithMetadata:ImageWithMetadata? = nil

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

        DispatchQueue.global(qos: .userInitiated).async {
            if let cgImageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
                if let cgImage = CreateCGImage(cgImageSource) {
                    let cgImageProperties = CGImageSourceCopyPropertiesAtIndex(cgImageSource, 0, nil) ?? NSDictionary() as CFDictionary

                    DispatchQueue.main.async {
                        let newImageWithMetadata = ImageWithMetadata(url: url, date: timeStamp, image: cgImage, metadata: cgImageProperties)
                        ImageLoader.lruCache.setObject(newImageWithMetadata, forKey: NSString(string: url.path))
                        self.imageWithMetadata = newImageWithMetadata
                    }
                    return
                }
            }
            print("Problems reading image file:", url)
        }
    }
}
