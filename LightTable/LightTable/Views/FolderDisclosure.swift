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
        let children = folderListingAt(url:url)

        if (children.isEmpty) {
            Label(url.lastPathComponent, systemImage: "folder")
        } else {
            DisclosureGroup(isExpanded: $expanded, content: {
                ForEach(children, id: \.self) { item in
                    FolderDisclosure(url: item, selection: _selection)
                }
            }, label: {
                Label(url.lastPathComponent, systemImage: "folder.fill")
            })
        }
    }
}
