//
//  FileListing.swift
//  PhotoBrowser
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

class ImageBrowserModel: ObservableObject {
    @Published var files:[URL] = []
    @Published var selection:URL? = nil

    func updateSelection(selection: URL) {
        if (self.selection != selection) {
            self.selection = selection
        }
    }

    func processKey(key: KeyEquivalent) {
        if (key == .rightArrow || key == .leftArrow) {
            if (files.isEmpty) {
                return
            }
            guard let currentSelection = selection else {
                updateSelection(selection: files[0])
                return
            }
            guard let index = files.firstIndex(of: currentSelection) else {
                return
            }
            if (key == .rightArrow && index < files.count - 1) {
                updateSelection(selection: files[index + 1])
            } else if (key == .leftArrow && index > 0) {
                updateSelection(selection: files[index - 1])
            }
        }
    }
}
