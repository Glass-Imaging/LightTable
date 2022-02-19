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

class ImageBrowserModel: ObservableObject {
    @Published var directories:[URL] = []
    @Published var files:[[URL]] = []
    @Published var selection:[URL] = []

    // Multipe Image View layout (Horizontal/Vertical/Grid)
    @Published var imageViewLayout:ImageListLayout = .Horizontal

    // Image View Orientation
    @Published var orientation:Image.Orientation = .up

    // Keyboard movement computed location with multiple selections
    @Published var nextLocation:URL? = nil

    // Single Image view selection for ImageListView
    @Published var imageViewSelection = -1

    // Fullscreen view presentation
    @Published var fullScreen = false

    // View magnification factor: 0 -> scale to fit, 1x, 2x, 3x, ...
    @Published var viewScaleFactor:CGFloat = 0

    // User dragging action
    @Published var viewOffset = CGPoint.zero
    @Published var viewOffsetInteractive = CGPoint.zero

    @Published var thumbnailSize:CGFloat = 150

    @Published var viewInfoItems:Int = 3

    @Published var useMasterOrientation = false
    @Published var masterOrientation:Image.Orientation = .up

    func fileIndex(file: URL) -> (Int, Int) {
        for listing in files {
            if let index = listing.firstIndex(of: file) {
                return (index, listing.count)
            }
        }
        return (0, 0)
    }

    func resetInteractiveState() {
        imageViewSelection = -1
        // fullScreen = false
        viewScaleFactor = 0
        viewOffset = CGPoint.zero
        viewOffsetInteractive = CGPoint.zero
    }

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

    func processKey(key: KeyEquivalent) {
        nextLocation = processKey(key: key)
        resetInteractiveState()
    }

    let orderByFileIndex = { (a:(Int, Int), b:(Int, Int)) in // selection index, file index
        return a.1 < b.1
    }

    // TODO: This code needs simplification
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
            var directoryStep:[Int] = []
            var globalMin = Int.max
            var globalMax = Int.min

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
                let min = indices.min(by: orderByFileIndex)
                let max = indices.max(by: orderByFileIndex)
                let step = max!.1 - min!.1 + 1
                directoryStep.append(step)

                if (min!.1 < globalMin) {
                    globalMin = min!.1
                }
                if (max!.1 > globalMax) {
                    globalMax = max!.1
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
                    if (directoryMax[d] >= files[d].count - directoryStep[d]) {
                        // never mind, we can't advance
                        return nil
                    }
                } else {
                    if (directoryMin[d] < directoryStep[d]) {
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
                    selection[index.0] = files[d][index.1 + (key == .rightArrow ? directoryStep[d] : -directoryStep[d])]
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
                return files[directoryWithMax][directoryMax[directoryWithMax] + directoryStep[directoryWithMax]]
            } else {
                var globalMin:Int = Int.max
                var directoryWithMin:Int = 0
                for d in 0 ..< directories.count {
                    if (directoryMin[d] < globalMin) {
                        globalMin = directoryMin[d]
                        directoryWithMin = d
                    }
                }
                return files[directoryWithMin][directoryMin[directoryWithMin] - directoryStep[directoryWithMin]]
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

    func switchViewInfoItems() {
        viewInfoItems = viewInfoItems == 0 ? 3 : viewInfoItems - 1
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
