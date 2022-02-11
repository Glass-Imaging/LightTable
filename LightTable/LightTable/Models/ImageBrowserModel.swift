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

    // Single Image view selection for ImageListView
    @Published var imageViewSelection = -1

    // Multipe Image View layout (Horizontal/Vertical/Grid)
    @Published var imageViewLayout:ImageListLayout = .Horizontal

    // Image View Orientation
    @Published var orientation:Image.Orientation = .up

    // Keyboard movement computed location with multiple selections
    @Published var nextLocation:URL? = nil

    @Published var fullScreen = false

    @Published var viewScaleFactor:CGFloat = 0

    @Published var viewOffset:CGPoint = CGPoint.zero

    func setDirectories(directories: [URL]) {
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
            nextLocation = file
        }
    }

    func addToSelection(file: URL) {
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

    func removeFromSelection(file: URL) {
        guard let index = selection.firstIndex(of: file) else {
            return
        }
        selection.remove(at: index)
        if nextLocation == file {
            nextLocation = nil
        }
    }

    func lowestSelectionIndex(directory:Int) -> Int {
        if (directory < directories.count) {
            var lowestIndex = files[directory].count - 1
            for file in selection {
                guard let index = files[directory].firstIndex(of: file) else {
                    // This should not happen...
                    continue
                }
                if index < lowestIndex {
                    lowestIndex = index
                }
            }
            return lowestIndex
        }
        return -1
    }

    func largestSelectionIndex(directory:Int) -> Int {
        if (directory < directories.count) {
            var largestIndex = 0
            for file in selection {
                guard let index = files[directory].firstIndex(of: file) else {
                    // This should not happen...
                    continue
                }
                if index > largestIndex {
                    largestIndex = index
                }
            }
            return largestIndex
        }
        return -1
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

    func indicesToFiles(directory:Int, indices:[Int]) -> [URL] {
        var result:[URL] = []
        if (directory < directories.count) {
            for i in indices {
                if i < files[directory].count {
                    result.append(files[directory][i])
                }
            }
        }
        return result
    }

    let sortTuple = { (a:(Int, Int), b:(Int, Int)) in // selection index, file index
        return a.1 < b.1
    }

    func processKey(key: KeyEquivalent) {
        nextLocation = processKey(key: key)
    }

    private func processKey(key: KeyEquivalent) -> URL? {
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

            var directoryIndices:[[(Int, Int)]] = []  // selection index, file index
            var directoryMax:[Int] = []
            var directoryMin:[Int] = []
            var selectionStep = 0

            for d in 0 ..< directories.count {
                if (files[d].isEmpty) {
                    directoryMax.append(-1)
                    directoryMin.append(-1)
                    directoryIndices.append([])
                    continue
                }
                let indices = selectionIndices(directory: d)
                if (indices.isEmpty) {
                    directoryMax.append(-1)
                    directoryMin.append(-1)
                    directoryIndices.append([])
                    continue
                }
                let min = indices.min(by: sortTuple)
                let max = indices.max(by: sortTuple)
                let step = max!.1 - min!.1 + 1

                if (step > selectionStep) {
                    selectionStep = step
                }

                directoryMax.append(max!.1)
                directoryMin.append(min!.1)
                directoryIndices.append(indices)
            }

            // See if the step size is compatible for all directories
            for d in 0 ..< directories.count {
                if (directoryIndices[d].isEmpty) {
                    continue
                }

                if (key == .rightArrow) {
                    if (directoryMax[d] >= files[d].count - selectionStep) {
                        // never mind, we can't advance
                        return nil
                    }
                } else {
                    if (directoryMin[d] < selectionStep) {
                        // never mind, we can't advance
                        return nil
                    }
                }
            }

            // Step sizes are compatible with all selections, modify selections in place
            for d in 0 ..< directories.count {
                if (directoryIndices[d].isEmpty) {
                    continue
                }
                for i in 0 ..< directoryIndices[d].count {
                    let index = directoryIndices[d][i]
                    selection[index.0] = files[d][index.1 + (key == .rightArrow ? selectionStep : -selectionStep)]
                }
            }

            if (key == .rightArrow) {
                var globalMax:Int = 0
                var directoryWithMax:Int = 0
                for d in 0 ..< directories.count {
                    if (directoryMax[d] > globalMax) {
                        globalMax = directoryMax[d]
                        directoryWithMax = d
                    }
                }

                if (globalMax >= 0) {
                    return files[directoryWithMax][globalMax + selectionStep]
                }
            } else {
                var globalMin:Int = Int.max
                var directoryWithMin:Int = 0
                for d in 0 ..< directories.count {
                    if (directoryMin[d] < globalMin) {
                        globalMin = directoryMin[d]
                        directoryWithMin = d
                    }
                }

                if (globalMin >= 0) {
                    let result = files[directoryWithMin][globalMin - selectionStep]
                    return result
                }
            }
        }
        return nil
    }

    func switchLayout() {
        switch (imageViewLayout) {
        case .Horizontal:
            imageViewLayout = .Vertical
        case .Vertical:
            imageViewLayout = .Grid
        case .Grid:
            imageViewLayout = .Horizontal
        }
    }

    func rotateRight() {
        switch orientation {
        case Image.Orientation.up:
            orientation = Image.Orientation.right
        case Image.Orientation.right:
            orientation = Image.Orientation.down
        case Image.Orientation.down:
            orientation = Image.Orientation.left
        case Image.Orientation.left:
            orientation = Image.Orientation.up
        default:
            print("Unexpected orientation: ", orientation)
        }
    }

    func rotateLeft() {
        switch orientation {
        case Image.Orientation.up:
            orientation = Image.Orientation.left
        case Image.Orientation.right:
            orientation = Image.Orientation.up
        case Image.Orientation.down:
            orientation = Image.Orientation.right
        case Image.Orientation.left:
            orientation = Image.Orientation.down
        default:
            print("Unexpected orientation: ", orientation)
        }
    }

    func imageViewSelection(char:Character) {
        if (char >= "0" && char <= "9") {
            // Single image selection mode
            let zero = Character("0")
            let index = char == zero ? 9 : (char.wholeNumberValue! - zero.wholeNumberValue!) - 1;
            if (selection.count > 0 && selection.count > index) {
                imageViewSelection = index
            }
        } else if (KeyEquivalent(char) == "`") {
            // Exit single image selection mode
            imageViewSelection = -1
        }
    }
}
