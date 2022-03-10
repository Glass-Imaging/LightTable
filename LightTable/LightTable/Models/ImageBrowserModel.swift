// Copyright (c) 2022 Glass Imaging Inc.
// Author: Fabio Riccardi <fabio@glass-imaging.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

extension KeyEquivalent: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.character == rhs.character
    }
}

class ImageBrowserModel: ObservableObject {
    @Published private(set) var folders:[Folder] = []

    // Accessed directly by the browser selection
    @Published var selection:[URL] = []

    // Keyboard movement computed location with multiple selections
    @Published private(set) var nextLocation:URL? = nil

    func fileIndex(file: URL) -> (Int, Int) {
        for folder in folders {
            if let index = folder.files.firstIndex(of: file) {
                return (index, folder.files.count)
            }
        }
        return (0, 0)
    }

    func setFolders(folders: Set<Folder>) {
        // Check removed folders
        for folder in self.folders {
            if (!folders.contains(folder)) {
                for file in folder.files {
                    if let index = selection.firstIndex(of: file) {
                        selection.remove(at: index)
                    }
                }
            }
        }
        self.folders.removeAll(where: { !folders.contains($0) })

        // Check for added folders
        for d in folders {
            if (!self.folders.contains(d)) {
                self.folders.append(d)
            }
        }
    }

    func reset() {
        folders = []
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

    func selectionIndices(folder:Int) -> [(Int, Int)] { // selection index, file index
        var result:[(Int, Int)] = []
        if (folder < folders.count) {
            for i in 0 ..< selection.count {
                let file = selection[i]
                guard let index = folders[folder].files.firstIndex(of: file) else {
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

        for f in 0 ..< folders.count {
            indices.append(contentsOf: selectionIndices(folder: f))
        }
        return indices.min(by: orderByFileIndex)!.0
    }

    func maxSelectionIndex() -> Int {
        var indices:[(Int, Int)] = []

        for f in 0 ..< folders.count {
            indices.append(contentsOf: selectionIndices(folder: f))
        }
        return indices.max(by: orderByFileIndex)!.0
    }

    func processKey(key: KeyEquivalent) {
        nextLocation = processKey(key: key)
    }

    let orderByFileIndex = { (a:(Int, Int), b:(Int, Int)) in // selection index, file index
        return a.1 < b.1
    }

    private func processKey(key: KeyEquivalent) -> URL? {
        if (key == .rightArrow || key == .leftArrow) {
            if (folders.isEmpty || folders[0].files.isEmpty) {
                return nil
            }
            if (selection.isEmpty && !folders[0].files.isEmpty) {
                updateSelection(file: folders[0].files[0])
                return selection[0]
            }
            if selection.isEmpty {
                return nil
            }

            var steps:[Int] = []
            for f in 0 ..< folders.count {
                let indices = selectionIndices(folder: f)

                if (indices.isEmpty) {
                    // Never used, just to keep the size of steps in sync with that of folders
                    steps.append(-1)
                    continue
                }

                let min = indices.min(by: orderByFileIndex)
                let max = indices.max(by: orderByFileIndex)
                let step = max!.1 - min!.1 + 1

                if (key == .rightArrow) {
                    if (max!.1 >= folders[f].files.count - step) {
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
            for f in 0 ..< folders.count {
                let indices = selectionIndices(folder: f)

                if (indices.isEmpty) {
                    continue
                }

                for i in 0 ..< indices.count {
                    let index = indices[i]
                    selection[index.0] = folders[f].files[index.1 + (key == .rightArrow ? steps[f] : -steps[f])]
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
