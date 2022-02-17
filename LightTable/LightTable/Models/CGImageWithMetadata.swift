//
//  CGImageWithMetadata.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/17/22.
//

import Foundation

class CGImageWithMetadata {
    let image:CGImage
    let metadata:CFDictionary

    init(image:CGImage, metadata:CFDictionary) {
        self.image = image
        self.metadata = metadata
    }
}
