//
//  ImageBrowserModel.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

class ImageBrowserModel: ObservableObject {
    @Published var directories:[URL] = []
    @Published var files:[[URL]] = []
    @Published var selection:[URL] = []

    func setDirectories(directories: [URL]) {
        // Check removed directories
        for d in self.directories {
            if (!directories.contains(d)) {
                print("removing directory", d)
                removeDirectory(directory: d)
            }
        }
        // Check for added directories
        for d in directories {
            if (!self.directories.contains(d)) {
                print("adding directory", d)
                addDirectory(directory: d)
            }
        }
    }

    func addDirectory(directory: URL) {
        if (!directories.contains(directory)) {
            let fileListing = imageFileListingAt(url: directory)
            directories.append(directory)
            files.append(fileListing)
        }
    }

    func removeDirectory(directory: URL) {
        guard let index = directories.firstIndex(of: directory) else {
            return
        }

        // Remove selections
        for file in files[index] {
            guard let fileIndex = selection.firstIndex(of: file) else {
                continue
            }
            selection.remove(at: fileIndex)
        }

        // Remove files
        files.remove(at: index)

        // Remove the directory entry
        directories.remove(at: index)
    }

    func reset() {
        directories = []
        files = []
        selection = []
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
            guard let index = files[0].firstIndex(of: file) else {
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
            guard let index = files[0].firstIndex(of: file) else {
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
            guard let index = files[0].firstIndex(of: file) else {
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
                result.append(files[0][i])
            }
        }
        return result
    }

    func processKey(key: KeyEquivalent) -> URL? {
        if (key == .rightArrow || key == .leftArrow) {
            if (files.isEmpty) {
                return nil
            }
            if (selection.isEmpty && !files.isEmpty) {
                updateSelection(file: files[0][0])
                return selection[0]
            }
            if (key == .rightArrow) {
                if selection.count > 1 {
                    var indices = selectionIndices()
                    let min = indices.min()
                    let max = indices.max()
                    let step = max! - min! + 1

                    if (indices.max()! < files.count - step) {
                        for i in 0 ..< indices.count {
                            indices[i] += step
                        }
                        selection = indicesToFiles(indices: indices)
                    }
                    return files[0][indices.max()!]
                } else {
                    let index = selectionIndices().max()!
                    updateSelection(file: files[0][index < files.count - 1  ? index + 1 : index])
                    return selection[0]
                }
            } else if (key == .leftArrow) {
                if selection.count > 1 {
                    var indices = selectionIndices()
                    let min = indices.min()
                    let max = indices.max()
                    let step = max! - min! + 1

                    if (indices.min()! >= step) {
                        for i in 0 ..< indices.count {
                            indices[i] -= step
                        }
                        selection = indicesToFiles(indices: indices)
                    }
                    return files[0][indices.min()!]
                } else {
                    let index = selectionIndices().min()!
                    updateSelection(file: files[0][index > 0 ? index - 1 : index])
                    return selection[0]
                }
            }
        }
        return nil
    }
}
