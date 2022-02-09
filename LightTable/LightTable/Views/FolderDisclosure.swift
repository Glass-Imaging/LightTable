//
//  FolderDisclosure.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import SwiftUI

struct FolderDisclosure: View {
    @State var url:URL
    @Binding var selection:Set<URL>
    @State var expanded = false

    var body: some View {
        var hasImages = false
        let children = folderListingAt(url: url, hasImages: &hasImages)

        if (children.isEmpty) {
            Label(url.lastPathComponent, systemImage: hasImages ? "folder.fill" : "folder")
        } else {
            DisclosureGroup(isExpanded: $expanded, content: {
                ForEach(children, id: \.self) { item in
                    FolderDisclosure(url: item, selection: _selection)
                }
            }, label: {
                Label(url.lastPathComponent, systemImage: hasImages ? "plus.rectangle.on.folder.fill" : "folder.fill")
            })
        }
    }
}
