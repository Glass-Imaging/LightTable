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

struct NavigatorModel {
    // Directly accessed by FolderTreeNavigator
    /* private(set) */ var root:Folder? = nil
    /* private(set) */ var selection = Set<Folder>()

    private(set) var historyBack:[URL] = []
    private(set) var historyForward:[URL] = []

    func hasBackHistory() -> Bool {
        !historyBack.isEmpty
    }

    func hasForwardHistory() -> Bool {
        !historyForward.isEmpty
    }

    func hasSelection() -> Bool {
        !selection.isEmpty
    }

    func hasParentFolder() -> Bool {
        let rootPath = URL(string: "file:///")
        return root != nil && root!.url != rootPath
    }

    mutating func update(folder: Folder) {
        if let root = root {
            historyBack.append(root.url)
        }
        root = folder
        selection = []
    }

    mutating func enclosingFolder() {
        if let root = root {
            update(folder: Folder(url: parentFolder(url: root.url)))
            selection = [root]
        }
    }

    mutating func selectedFolder() {
        if let selection = selection.first {
            update(folder: selection)
        }
    }

    mutating func back() {
        if (!historyBack.isEmpty) {
            let item = historyBack.remove(at: historyBack.count - 1)
            if let root = root {
                historyForward.append(root.url)
            }
            root = Folder(url: item)
        }
    }

    mutating func forward() {
        if (!historyForward.isEmpty) {
            let item = historyForward.remove(at: historyForward.count - 1)
            if let root = root {
                historyBack.append(root.url)
            }
            root = Folder(url: item)
        }
    }
}
