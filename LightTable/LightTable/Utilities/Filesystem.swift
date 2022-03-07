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

func NSOpenPanelDirectoryListing(files:inout[URL]) -> URL? {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false

    if panel.runModal() == .OK && panel.url != nil {
        files = folderListingAt(url:panel.url!)
        return panel.url
    }
    return nil
}

private let imageFileExtensions = ["jpg", "jpeg", "png", "tif", "tiff", "heic", "heif", "dng", "cr3", "arw", "crw", "cr2", "raf"]

func isImage(file:URL) -> Bool {
    let fileExtension = file.pathExtension.lowercased()
    return imageFileExtensions.contains(fileExtension)
}

func folderListingAt(url:URL) -> [URL] {
    var hasImages = false
    return folderListingAt(url: url, hasImages: &hasImages)
}

func folderListingAt(url:URL, hasImages: inout Bool) -> [URL] {
    return fileListingAt(url: url) { entry in
        if (!hasImages && isImage(file: entry)) {
            hasImages = true
        }
        return entry.hasDirectoryPath
    }
}

func imageFileListingAt(url:URL) -> [URL] {
    return fileListingAt(url: url) { entry in
        return isImage(file:entry)
    }
}

func parentFoldersList(url: URL) -> [URL] {
    let rootPath = URL(string: "file:///")
    var parents:[URL] = []
    if (url != rootPath && url.hasDirectoryPath) {
        var current = url
        repeat {
            parents.append(current)
            current = current.deletingLastPathComponent()
        } while(current != rootPath)
    }
    return parents
}

func parentFolder(url: URL) -> URL {
    let rootPath = URL(string: "file:///")
    if url != rootPath {
        let parent = url.deletingLastPathComponent()
        return parent
    }
    return url
}

func resourceIsReachable(url: URL) -> Bool {
    do {
        if try url.checkResourceIsReachable() {
            return true
        }
    } catch {
        print("checkResourceIsReachable failed: \(error)")
    }
    return false
}

func fileListingAt(url:URL, filter:(_ entry:URL) -> Bool) -> [URL] {
    let manager = FileManager.default
    do {
        var entries:[URL] = []
        let directoryContent = try manager.contentsOfDirectory(at: url,
                                                               includingPropertiesForKeys: nil,
                                                               options: .skipsSubdirectoryDescendants)
        for entry in directoryContent {
            if !entry.lastPathComponent.starts(with: ".") && filter(entry) {
                entries.append(entry)
            }
        }
        // Sort images alphabetically
        return entries.sorted {
            $0.lastPathComponent < $1.lastPathComponent
        }
    } catch {
        return []
    }
}

func timeStamp(url: URL) -> Date {
    return (try? FileManager.default.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date ?? Date()
}
