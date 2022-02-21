//
//  FolderTreeList.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/18/22.
//

import SwiftUI

class FileEntry: Identifiable {
    let url:URL

    lazy var id:URL = {
        url
    }()

    var hasImages = false

    var cachedChildren:[FileEntry]? = nil
    lazy var children: [FileEntry]? = {
        if (cachedChildren == nil) {
            cachedChildren = FileEntry.fileListing(listing: folderListingAt(url: url, hasImages: &hasImages))
        }
        return cachedChildren!.isEmpty ? nil : cachedChildren!
    }()

    static func fileListing(listing: [URL]) -> [FileEntry]? {
        var result:[FileEntry] = []
        for f in listing {
            result.append(FileEntry(url: f))
        }
        return result
    }

    init(url:URL) {
        self.url = url
    }
}

struct FolderTreeList: View {
    @Binding var navigatorModel:NavigatorModel
    @Binding var selection:Set<URL>

    var body: some View {
        List(FileEntry.fileListing(listing: navigatorModel.children)!,
             children: \.children,
             selection: $selection) { item in
            Label(item.url.lastPathComponent, systemImage: item.hasImages ? "folder.fill" : "folder")
                .gesture(TapGesture(count: 2).onEnded {
                    DispatchQueue.main.async {
                        if (item.children != nil) {
                            navigatorModel.update(url: item.url)
                        }
                    }
                })
                .gesture(TapGesture(count: 1).modifiers(.command).onEnded {
                    navigatorModel.multiSelection.insert(item.url)
                })
                .gesture(TapGesture(count: 1).modifiers(.shift).onEnded {
                    navigatorModel.multiSelection.insert(item.url)
                })
                .gesture(TapGesture(count: 1).onEnded {
                    navigatorModel.multiSelection = [item.url]
                })
        }
        .listStyle(.inset)
    }
}


