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

    func lowestSelectionIndex() -> Int {
        var lowestIndex = files.count - 1
        for file in selection {
            guard let index = files.firstIndex(of: file) else {
                // This should not happen...
                continue
            }
            if index < lowestIndex {
                lowestIndex = index
            }
        }
        return lowestIndex
    }

    func largestSelectionIndex() -> Int {
        var largestIndex = 0
        for file in selection {
            guard let index = files.firstIndex(of: file) else {
                // This should not happen...
                continue
            }
            if index > largestIndex {
                largestIndex = index
            }
        }
        return largestIndex
    }

    func selectionIndices() -> [Int] {
        var result:[Int] = []
        for file in selection {
            guard let index = files.firstIndex(of: file) else {
                // This should not happen...
                continue
            }
            result.append(index)
        }
        return result
    }

    func indicesToFiles(indices:[Int]) -> [URL] {
        var result:[URL] = []
        for i in indices {
            if i < files.count {
                result.append(files[i])
            }
        }
        return result
    }

    func processKey(key: KeyEquivalent) {
        if (key == .rightArrow || key == .leftArrow) {
            if (files.isEmpty) {
                return
            }
            if (selection.isEmpty && !files.isEmpty) {
                updateSelection(file: files[0])
                return
            }
            if (key == .rightArrow) {
                if selection.count > 1 {
                    var indices = selectionIndices()
                    if (indices.max()! < files.count - 1) {
                        for i in 0 ..< indices.count {
                            indices[i] += 1
                        }
                        selection = indicesToFiles(indices: indices)
                    }
                } else {
                    let index = largestSelectionIndex()
                    updateSelection(file: files[index < files.count - 1  ? index + 1 : index])
                }
            } else if (key == .leftArrow) {
                if selection.count > 1 {
                    var indices = selectionIndices()
                    if (indices.min()! > 0) {
                        for i in 0 ..< indices.count {
                            indices[i] -= 1
                        }
                        selection = indicesToFiles(indices: indices)
                    }
                } else {
                    let index = lowestSelectionIndex()
                    updateSelection(file: files[index > 0 ? index - 1 : index])
                }
            }
        }
    }
}
