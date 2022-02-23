//
//  ImageBrowserModel.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

extension KeyEquivalent: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.character == rhs.character
    }
}

struct ImageBrowserModel {
    private(set) var directories:[URL] = []
    private(set) var files:[[URL]] = []
    /* private(set) */ var selection:[URL] = []

    // Keyboard movement computed location with multiple selections
    private(set) var nextLocation:URL? = nil

    func fileIndex(file: URL) -> (Int, Int) {
        for listing in files {
            if let index = listing.firstIndex(of: file) {
                return (index, listing.count)
            }
        }
        return (0, 0)
    }

    mutating func setDirectories(directories: [URL]) {
        // Check removed directories
        for d in self.directories {
            if (!directories.contains(d)) {
                removeDirectory(directory: d)
            }
        }
        // Check for added directories
        for d in directories {
            if (!self.directories.contains(d)) {
                addDirectory(directory: d)
            }
        }
    }

    mutating func addDirectory(directory: URL) {
        if (!directories.contains(directory)) {
            let fileListing = imageFileListingAt(url: directory)
            directories.append(directory)
            files.append(fileListing)

            // resetImageViewSelection()
        }
    }

    mutating func removeDirectory(directory: URL) {
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

    mutating func reset() {
        directories = []
        files = []
        selection = []
    }

    func isSelcted(file: URL) -> Bool {
        return selection.contains(file)
    }

    mutating func updateSelection(file: URL) {
        // don't update the selection gratuitously
        if (!(selection.count == 1 && selection[0] == file)) {
            selection = [file]
            nextLocation = file
        }
    }

    mutating func addToSelection(file: URL) {
        guard let index = selection.firstIndex(of: file) else {
            selection.append(file)
            nextLocation = file
            return
        }
        // If the file is already in the selection, remove it
        selection.remove(at: index)
        if nextLocation == file {
            nextLocation = nil
        }
    }

    mutating func removeFromSelection(file: URL) {
        guard let index = selection.firstIndex(of: file) else {
            return
        }
        selection.remove(at: index)
        if nextLocation == file {
            nextLocation = nil
        }
    }

    func selectionIndices(directory:Int) -> [(Int, Int)] { // selection index, file index
        var result:[(Int, Int)] = []
        if (directory < directories.count) {
            for i in 0..<selection.count {
                let file = selection[i]
                guard let index = files[directory].firstIndex(of: file) else {
                    // This should not happen...
                    continue
                }
                result.append((i, index))
            }
        }
        return result
    }

    func minSelectionIndex() -> Int {
        var indices:[(Int, Int)] = []

        for d in 0 ..< directories.count {
            indices.append(contentsOf: selectionIndices(directory: d))
        }
        return indices.min(by: orderByFileIndex)!.0
    }

    func maxSelectionIndex() -> Int {
        var indices:[(Int, Int)] = []

        for d in 0 ..< directories.count {
            indices.append(contentsOf: selectionIndices(directory: d))
        }
        return indices.max(by: orderByFileIndex)!.0
    }

    mutating func processKey(key: KeyEquivalent) {
        nextLocation = processKey(key: key)
    }

    let orderByFileIndex = { (a:(Int, Int), b:(Int, Int)) in // selection index, file index
        return a.1 < b.1
    }

    private mutating func processKey(key: KeyEquivalent) -> URL? {
        if (key == .rightArrow || key == .leftArrow) {
            if (files.isEmpty || files[0].isEmpty) {
                return nil
            }
            if (selection.isEmpty && !files[0].isEmpty) {
                updateSelection(file: files[0][0])
                return selection[0]
            }
            if selection.isEmpty {
                return nil
            }

            var steps:[Int] = []
            for d in 0 ..< directories.count {
                let indices = selectionIndices(directory: d)

                if (indices.isEmpty) {
                    // Never used, just to keep the size of steps in sync with that of directories
                    steps.append(-1)
                    continue
                }

                let min = indices.min(by: orderByFileIndex)
                let max = indices.max(by: orderByFileIndex)
                let step = max!.1 - min!.1 + 1

                if (key == .rightArrow) {
                    if (max!.1 >= files[d].count - step) {
                        // never mind, we can't advance
                        NSSound.beep()
                        return nil
                    }
                } else {
                    if (min!.1 < step) {
                        // never mind, we can't advance
                        NSSound.beep()
                        return nil
                    }
                }

                steps.append(step)
            }

            // Step sizes are compatible with all selections, modify selections in place
            for d in 0 ..< directories.count {
                let indices = selectionIndices(directory: d)

                if (indices.isEmpty) {
                    continue
                }

                for i in 0 ..< indices.count {
                    let index = indices[i]
                    selection[index.0] = files[d][index.1 + (key == .rightArrow ? steps[d] : -steps[d])]
                }
            }

            if (key == .leftArrow) {
                return selection[minSelectionIndex()]
            } else {
                return selection[maxSelectionIndex()]
            }
        }
        return nil
    }
}
