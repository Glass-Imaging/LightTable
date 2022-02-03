//
//  Filesystem.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/3/22.
//

import SwiftUI

func NSOpenPanelDirectoryListing(files:inout[Folder]) -> URL? {
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

func fileListingAt(url:URL) -> [URL] {
    let manager = FileManager.default
    do {
        var entries:[URL] = []
        let items = try manager.contentsOfDirectory(at: url,
                                                    includingPropertiesForKeys: nil,
                                                    options: .skipsSubdirectoryDescendants)
        for item in items {
            let file_extension = item.pathExtension.lowercased()
            if (file_extension == "jpg" || file_extension == "jpeg" || file_extension == "png") {
                entries.append(item)
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

func folderListingAt(url:URL) -> [Folder] {
    let manager = FileManager.default
    do {
        var entries:[Folder] = []
        let items = try manager.contentsOfDirectory(at: url,
                                                    includingPropertiesForKeys: nil,
                                                    options: .skipsSubdirectoryDescendants)
        for item in items {
            if (item.hasDirectoryPath) {
                entries.append(Folder(url: item))
            }
        }
        // Sort folders alphabetically
        return entries.sorted { a, b in
            return a.url().lastPathComponent < b.url().lastPathComponent
        }
    } catch {
        return []
    }
}

