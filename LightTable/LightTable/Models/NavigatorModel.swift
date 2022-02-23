//
//  NavigatorModel.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import Foundation

struct NavigatorModel: Equatable, Hashable {
    // Directly accessed by FolderTreeNavigator
    /* private(set) */ var root:Folder? = nil
    /* private(set) */ var selection = Set<URL>()

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

    mutating func update(url: URL) {
        if let root = root {
            historyBack.append(root.url)
        }
        root = Folder(url: url)
    }

    mutating func enclosingFolder() {
        if let root = root {
            update(url: parentFolder(url: root.url))
            // TODO: Selection gets lost...
            selection = [root.url]
        }
    }

    mutating func selectedFolder() {
        if let selection = selection.first {
            update(url: selection)
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
