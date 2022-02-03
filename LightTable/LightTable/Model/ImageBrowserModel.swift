//
//  FileListing.swift
//  PhotoBrowser
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

class ImageBrowserModel: ObservableObject {
    @Published var files:[URL] = []
    @Published var selection:[URL] = []

    func setFiles(files: [URL]) {
        self.files = files
        selection = []
    }

    func getSelection() -> URL? {
        if (selection.isEmpty) {
            return nil
        } else {
            return selection[0]
        }
    }

    func isSelcted(file: URL) -> Bool {
        return selection.contains(file)
    }

    func updateSelection(file: URL) {
        // don't update the selection gratuitously
        if (!(selection.count == 1 && selection[0] == file)) {
            selection = [file]
        }
    }

    func addToSelection(file: URL) {
        guard let index = selection.firstIndex(of: file) else {
            selection.append(file)
            return
        }
        selection.remove(at: index)
    }

    func removeFromSelection(file: URL) {
        guard let index = selection.firstIndex(of: file) else {
            return
        }
        selection.remove(at: index)
    }

    func processKey(key: KeyEquivalent) {
        if (key == .rightArrow || key == .leftArrow) {
            if (files.isEmpty) {
                return
            }
            if (selection.isEmpty) {
                updateSelection(file: files[0])
                return
            }
            guard let index = files.firstIndex(of: selection[0]) else {
                // This should not happen...
                return
            }
            if (key == .rightArrow && index < files.count - 1) {
                updateSelection(file: files[index + 1])
            } else if (key == .leftArrow && index > 0) {
                updateSelection(file: files[index - 1])
            }
        }
    }
}
