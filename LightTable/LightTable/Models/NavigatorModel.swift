//
//  NavigatorModel.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import SwiftUI

class NavigatorModel: ObservableObject {
    @Published var root:URL? = nil
    @Published var children:[URL] = []

    @Published var historyBack:[URL] = []
    @Published var historyForward:[URL] = []

    func update(url: URL) {
        if (root != nil) {
            historyBack.append(root!)
        }
        root = url
        children = folderListingAt(url: url)
    }

    func back() {
        if (!historyBack.isEmpty) {
            let item = historyBack.remove(at: historyBack.count - 1)
            if (root != nil) {
                historyForward.append(root!)
            }
            root = item
            children = folderListingAt(url: item)
        }
    }

    func forward() {
        if (!historyForward.isEmpty) {
            let item = historyForward.remove(at: historyForward.count - 1)
            if (root != nil) {
                historyBack.append(root!)
            }
            root = item
            children = folderListingAt(url: item)
        }
    }
}
