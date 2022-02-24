//
//  Folder.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/21/22.
//

import Foundation

class Folder: Equatable, Hashable {
    let url: URL
    var hasImages = false

    private var cachedChildren: [Folder]? = nil
    lazy var children: [Folder] = {
        if let cachedChildren = cachedChildren {
            return cachedChildren
        }

        cachedChildren = []
        let listing = folderListingAt(url: url, hasImages: &hasImages)
        for url in listing {
            cachedChildren!.append(Folder(url: url))
        }
        return cachedChildren!
    }()

    private var cachedFiles: [URL]? = nil
    lazy var files: [URL] = {
        if let cachedFiles = cachedFiles {
            return cachedFiles
        }

        cachedFiles = []
        let listing = imageFileListingAt(url: url)
        for url in listing {
            cachedFiles!.append(url)
        }
        return cachedFiles!
    }()

    init(url: URL) {
        self.url = url
    }

    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
