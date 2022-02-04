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

func folderListingAt(url:URL) -> [URL] {
    return fileListingAt(url: url) { entry in
        return entry.hasDirectoryPath
    }
}

func imageFileListingAt(url:URL) -> [URL] {
    return fileListingAt(url: url) { entry in
        let file_extension = entry.pathExtension.lowercased()
        return file_extension == "jpg" || file_extension == "jpeg" || file_extension == "png"
    }
}

func fileListingAt(url:URL, filter:(_ entry:URL) -> Bool) -> [URL] {
    let manager = FileManager.default
    do {
        var entries:[URL] = []
        let directoryContent = try manager.contentsOfDirectory(at: url,
                                                    includingPropertiesForKeys: nil,
                                                    options: .skipsSubdirectoryDescendants)
        for entry in directoryContent {
            if filter(entry) {
                entries.append(entry)
            }
        }
        // Sort images alphabetically
        return entries.sorted { a, b in
            return a.lastPathComponent < b.lastPathComponent
        }
    } catch {
        return []
    }
}
