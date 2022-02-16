//
//  FilesOutlineView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import SwiftUI

// Usage Pattern
//
//    ScrollView {
//        OutlineGroup(FileItem(url: navigatorModel.parentFolder!, level: 0), children: \.children) { item in
//            FilesOutlineView(item: item, selection: $multiSelection)
//        }
//        .offset(x: 10)
//    }

// TODO: Make this a class
struct FileItem: Hashable, Identifiable, CustomStringConvertible {
    var id: URL { url }
    var url: URL
    var level:Int
    var children: [FileItem]? {
        return getChildren(folders: folderListingAt(url:url), level: level + 1)
    }
    var description: String {
        switch children {
        case nil:
            return " 􀈗 \(url.lastPathComponent)"
        case .some(let children):
            return children.isEmpty ? " 􀈕 \(url.lastPathComponent)" : " 􀈖 \(url.lastPathComponent)"
        }
    }

    func getChildren(folders: [URL], level: Int) -> [FileItem] {
        var result:[FileItem] = []
        for folder in folders {
            result.append(FileItem(url: folder, level: level))
        }
        return result
    }
}

struct FilesOutlineView: View {
    var item:FileItem
    @Binding var selection:Set<URL>
    @State var selected = false

    var body: some View {
        Button {
            if (selection.contains(item.url)) {
                selection.remove(item.url)
                selected = false
            } else {
                selection.insert(item.url)
                selected = true
            }
        } label: {
            HStack {
                Text("\(item.description)")
                    .background(selection.contains(item.url) ? Color.blue : Color.clear)
                    .offset(x: 10 * CGFloat(item.level))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
