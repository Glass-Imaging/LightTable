//
//  FolderTreeNavigator.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/10/22.
//

import SwiftUI

struct FolderTreeDisclosure: View {
    let url:URL
    @Binding var selection:Set<URL>
    @State var expanded = false
    let doubleTapAction:(_ entry:URL) -> Void

    var body: some View {
        var hasImages = false
        let children = folderListingAt(url: url, hasImages: &hasImages)

        if children.isEmpty {
            Label(url.lastPathComponent, systemImage: hasImages ? "folder.fill" : "folder")
        } else {
            DisclosureGroup(isExpanded: $expanded, content: {
                if expanded {
                    ForEach(children, id: \.self) { item in
                        FolderTreeDisclosure(url: item, selection: _selection, doubleTapAction: doubleTapAction)
                    }
                }
            }, label: {
                Label(url.lastPathComponent, systemImage: hasImages ? "folder.fill" : "folder")
                    .gesture(TapGesture(count: 2).onEnded {
                        doubleTapAction(url)
                    })
                    .gesture(TapGesture(count: 1).modifiers([.shift]).onEnded {
                        selection.insert(url)
                    })
                    .gesture(TapGesture(count: 1).modifiers([.command]).onEnded {
                        selection.insert(url)
                    })
                    .gesture(TapGesture(count: 1).onEnded {
                        selection = [url]
                    })
            })
        }
    }
}

struct FolderTreeNavigator: View {
    @Binding var navigatorModel:NavigatorModel

    @FocusState private var navigatorIsFocused: Bool

    var body: some View {
        if (navigatorModel.children.count == 0) {
            Text("Drop a folder here.")
        } else {
            VStack(alignment: .leading) {
                Divider()

                FolderTreeHeader(navigatorModel: $navigatorModel)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))

                Divider()

                List(navigatorModel.children, id:\.self, selection: $navigatorModel.selection) { folder in
                    FolderTreeDisclosure(url: folder, selection: $navigatorModel.selection) { url in
                        navigatorModel.update(url: url)
                    }
                }
                .focused($navigatorIsFocused)
                .onAppear {
                    navigatorIsFocused = true
                }
            }
        }
    }
}
