//
//  NavigatorModel.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import SwiftUI

struct NavigatorModel: Equatable, Hashable {
    var root:URL? = nil
    var children:[URL] = []

    var selection = Set<URL>()

    var historyBack:[URL] = []
    var historyForward:[URL] = []

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
        return root != rootPath
    }

    mutating func update(url: URL) {
        if let root = root {
            historyBack.append(root)
        }
        root = url
        children = folderListingAt(url: url)
    }

    mutating func update(url: URL, listing: [URL]) {
        if let root = root {
            historyBack.append(root)
        }
        root = url
        children = listing
    }

    mutating func enclosingFolder() {
        if let root = root {
            let previousRoot = root
            update(url: parentFolder(url: root))
            // TODO: Selection gets lost...
            selection = [previousRoot]
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
                historyForward.append(root)
            }
            root = item
            children = folderListingAt(url: item)
        }
    }

    mutating func forward() {
        if (!historyForward.isEmpty) {
            let item = historyForward.remove(at: historyForward.count - 1)
            if let root = root {
                historyBack.append(root)
            }
            root = item
            children = folderListingAt(url: item)
        }
    }
}
