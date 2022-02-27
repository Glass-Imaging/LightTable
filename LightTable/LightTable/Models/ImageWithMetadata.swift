//
//  CGImageWithMetadata.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/17/22.
//

import Foundation

class ImageWithMetadata: Equatable {
    let url:URL
    let date:Date
    let image:CGImage
    let metadata:CFDictionary

    init(url:URL, date:Date, image:CGImage, metadata:CFDictionary) {
        self.url = url
        self.date = date
        self.image = image
        self.metadata = metadata
    }

    static func == (lhs: ImageWithMetadata, rhs: ImageWithMetadata) -> Bool {
        return lhs.url == rhs.url && lhs.date == rhs.date
    }
}
