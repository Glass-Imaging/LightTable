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

    // Multipe Image View layout (Horizontal/Vertical/Grid)
    var imageViewLayout:ImageListLayout = .Horizontal

    mutating func switchLayout() {
        switch (imageViewLayout) {
        case .Horizontal:
            imageViewLayout = .Vertical
        case .Vertical:
            imageViewLayout = .Grid
        case .Grid:
            imageViewLayout = .Horizontal
        }
    }

    // Image View Orientation
    private(set) var orientation:Image.Orientation = .up

    mutating func rotateLeft() {
        orientation = LightTable.rotateLeft(value: orientation)
    }

    mutating func rotateRight() {
        orientation = LightTable.rotateRight(value: orientation)
    }

    // Keyboard movement computed location with multiple selections
    private(set) var nextLocation:URL? = nil

    // Single Image view selection for ImageListView
    private(set) var imageViewSelection = -1

    mutating func imageViewSelection(char:Character) {
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

    mutating func resetImageViewSelection() {
        imageViewSelection = -1
    }

    // Fullscreen view presentation
    var fullScreen = false

    mutating func toggleFullscreen() {
        fullScreen = !fullScreen
    }

    // View magnification factor: 0 -> scale to fit, 1x, 2x, 3x, ...
    private(set) var viewScaleFactor:CGFloat = 0

    mutating func zoomIn() {
        viewScaleFactor += 1
    }

    mutating func zoomOut() {
        if (viewScaleFactor > 0) {
            viewScaleFactor -= 1
        }
    }

    mutating func zoomToFit() {
        viewScaleFactor = 0
    }

    // User dragging action
    var viewOffset = CGPoint.zero
    var viewOffsetInteractive = CGPoint.zero

    var thumbnailSize:CGFloat = 150

    /* private(set) */ var viewInfoItems:Int = 3

    private(set) var useMasterOrientation = false

    mutating func togglaMasterOrientation() {
        useMasterOrientation = !useMasterOrientation
    }

    private(set) var masterOrientation:Image.Orientation = .up

    mutating func setMasterOrientation(orientation:Image.Orientation) {
        masterOrientation = orientation
    }

    func fileIndex(file: URL) -> (Int, Int) {
        for listing in files {
            if let index = listing.firstIndex(of: file) {
                return (index, listing.count)
            }
        }
        return (0, 0)
    }

    mutating func resetInteractiveState() {
        resetImageViewSelection()
        // fullScreen = false
        viewScaleFactor = 0
        viewOffset = CGPoint.zero
        viewOffsetInteractive = CGPoint.zero
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

            resetImageViewSelection()
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

        resetImageViewSelection()
    }

    mutating func reset() {
        directories = []
        files = []
        selection = []

        resetImageViewSelection()
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
        resetInteractiveState()
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

    mutating func switchViewInfoItems() {
        viewInfoItems = viewInfoItems == 0 ? 3 : viewInfoItems - 1
    }
}
