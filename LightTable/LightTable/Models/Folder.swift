// Copyright (c) 2022 Glass Imaging Inc.
// Author: Fabio Riccardi <fabio@glass-imaging.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

class Folder: Equatable, Hashable, Identifiable {
    let url: URL
    var hasImages = false
    var id:URL { url }

    private var cachedChildren: [Folder]? = nil
    lazy var children: [Folder]? = {
        if let cachedChildren = cachedChildren {
            return cachedChildren.isEmpty ? nil : cachedChildren
        }

        cachedChildren = []
        let listing = folderListingAt(url: url, hasImages: &hasImages)
        for url in listing {
            cachedChildren!.append(Folder(url: url))
        }
        return cachedChildren!.isEmpty ? nil : cachedChildren!
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
