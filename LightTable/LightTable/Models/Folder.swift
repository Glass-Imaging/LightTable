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
    var id:URL { url }
    private(set) var hasImages = false
    private(set) var timeStamp = Date()

    func checkFolderModificationDate() {
        let folderModificationDate = LightTable.timeStamp(url: url)
        if folderModificationDate != timeStamp {
            cachedChildren = nil
            cachedFiles = nil
        }
    }

    var children: [Folder]? {
        checkFolderModificationDate()

        if let cachedChildren = cachedChildren {
            return cachedChildren.isEmpty ? nil : cachedChildren
        }

        cachedChildren = []
        let listing = folderListingAt(url: url, hasImages: &hasImages)
        for url in listing {
            cachedChildren!.append(Folder(url: url))
        }
        timeStamp = LightTable.timeStamp(url: url)
        return cachedChildren!.isEmpty ? nil : cachedChildren!
    }
    private var cachedChildren: [Folder]? = nil

    var files: [URL] {
        checkFolderModificationDate()

        if let cachedFiles = cachedFiles {
            return cachedFiles
        }

        cachedFiles = []
        let listing = imageFileListingAt(url: url)
        for url in listing {
            cachedFiles!.append(url)
        }
        timeStamp = LightTable.timeStamp(url: url)
        return cachedFiles!
    }
    private var cachedFiles: [URL]? = nil

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
