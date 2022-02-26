//
//  CGImageWithMetadata.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/17/22.
//

import Foundation

class CGImageWithMetadata {
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
}
