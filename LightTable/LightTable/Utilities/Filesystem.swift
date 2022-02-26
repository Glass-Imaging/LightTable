//
//  Filesystem.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/3/22.
//

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

func isImage(file:URL) -> Bool {
    let imageFileExtensions = ["jpg", "jpeg", "png", "heic", "heif", "dng", "cr3", "arw"]
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
