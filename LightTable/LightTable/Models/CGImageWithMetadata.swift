//
//  CGImageWithMetadata.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/17/22.
//

import Foundation

class CGImageWithMetadata {
    let url:URL
    let image:CGImage
    let metadata:CFDictionary

    init(url:URL, image:CGImage, metadata:CFDictionary) {
        self.url = url
        self.image = image
        self.metadata = metadata
    }
}
