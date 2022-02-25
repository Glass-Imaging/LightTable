//
//  NavigatorModel.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

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
