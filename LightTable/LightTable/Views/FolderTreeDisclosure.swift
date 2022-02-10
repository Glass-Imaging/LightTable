//
//  FolderDisclosure.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import SwiftUI

struct FolderTreeDisclosure: View {
    @State var url:URL
    @Binding var selection:Set<URL>
    @State var expanded = false
    var doubleTapAction:(_ entry:URL) -> Void

    var body: some View {
        var hasImages = false
        let children = folderListingAt(url: url, hasImages: &hasImages)

        if (children.isEmpty) {
            Label(url.lastPathComponent, systemImage: hasImages ? "folder.fill" : "folder")
        } else {
            DisclosureGroup(isExpanded: $expanded, content: {
                if (expanded) {
                    ForEach(children, id: \.self) { item in
                        FolderTreeDisclosure(url: item, selection: _selection, doubleTapAction: doubleTapAction)
                    }
                }
            }, label: {
                VStack {
                    Label(url.lastPathComponent, systemImage: hasImages ? "plus.rectangle.on.folder.fill" : "folder.fill")
                }
                // Breaks the List single click selection
                // .onTapGesture(count: 2) {
                //     doubleTapAction(url)
                // }
            })
        }
    }
}
