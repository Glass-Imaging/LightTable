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

class NavigatorModel: ObservableObject {
    @Published private(set) var root:Folder? = nil
    // Directly accessed by FolderTreeNavigator
    @Published var selection = Set<Folder>()
    @Published var expandedItems = Set<Folder>()

    private var historyBack:[URL] = []
    private var historyForward:[URL] = []

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
        if let root = root {
            return root.url != rootPath
        }
        return false
    }

    func update(url: URL?) {
        if let root = root {
            historyBack.append(root.url)
        }
        // The only place where Folder objects are ever created
        root = url != nil ? Folder(url: url!) : nil
        selection = []
    }

    func enclosingFolder() {
        if let root = root {
            update(url: parentFolder(url: root.url))
            selection = [root]
        }
    }

    func selectedFolder() {
        if let selection = selection.first {
            update(url: selection.url)
        }
    }

    func back() {
        if (!historyBack.isEmpty) {
            let item = historyBack.remove(at: historyBack.count - 1)
            if let root = root {
                historyForward.append(root.url)
            }
            update(url: item)
        }
    }

    func forward() {
        if (!historyForward.isEmpty) {
            let item = historyForward.remove(at: historyForward.count - 1)
            if let root = root {
                historyBack.append(root.url)
            }
            update(url: item)
        }
    }

    func resetWith(storedRoot:String?, storedSelection:[String]?) {
        // Restore root folder
        guard let storedRoot = storedRoot else {
            return
        }

        let url = URL(fileURLWithPath: storedRoot)
        if !resourceIsReachable(url: url) {
            return
        }
        update(url: url)

        // Restore navigator selection
        var newSelection = Set<Folder>()
        var newExpandedItems = Set<Folder>()

        if let storedSelection = storedSelection {
            if let root = root {
                for item in storedSelection.map({ URL(fileURLWithPath: $0) }) {
                    var currentFolder = root
                    if resourceIsReachable(url: item) && item.starts(with: currentFolder.url) {
                        while (currentFolder.url != item) {
                            if let match = currentFolder.children?.first(where: { item.starts(with: $0.url) }) {
                                currentFolder = match
                                if currentFolder.url == item {
                                    newSelection.insert(match)
                                } else {
                                    newExpandedItems.insert(match)
                                }
                            }
                        }
                    }
                }
            }
        }
        selection = newSelection
        expandedItems = newExpandedItems
    }
}
