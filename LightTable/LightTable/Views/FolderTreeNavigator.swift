//
//  FolderTreeNavigator.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/10/22.
//

import SwiftUI

struct FolderTreeDisclosure: View {
    let folder:Folder
    @Binding var selection:Set<Folder>
    @State var expanded = false
    let doubleTapAction:(_ folder: Folder) -> Void

    var body: some View {
        if folder.children.isEmpty {
            Label(folder.url.lastPathComponent, systemImage: folder.hasImages ? "folder.fill" : "folder")
        } else {
            DisclosureGroup(isExpanded: $expanded, content: {
                if expanded {
                    ForEach(folder.children, id: \.self) { item in
                        FolderTreeDisclosure(folder: item, selection: _selection, doubleTapAction: doubleTapAction)
                    }
                }
            }, label: {
                Label(folder.url.lastPathComponent, systemImage: folder.hasImages ? "folder.fill" : "folder")
                    .gesture(TapGesture(count: 2).onEnded {
                        doubleTapAction(folder)
                    })
                    .gesture(TapGesture(count: 1).modifiers([.shift]).onEnded {
                        selection.insert(folder)
                    })
                    .gesture(TapGesture(count: 1).modifiers([.command]).onEnded {
                        selection.insert(folder)
                    })
                    .gesture(TapGesture(count: 1).onEnded {
                        selection = [folder]
                    })
            })
        }
    }
}

struct FolderTreeNavigator: View {
    @Binding var navigatorModel:NavigatorModel

    @FocusState private var navigatorIsFocused: Bool

    var body: some View {
        if let root = navigatorModel.root {
            VStack(alignment: .leading) {
                Divider()

                FolderTreeHeader(navigatorModel: $navigatorModel)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))

                Divider()

                List(root.children, id:\.self, selection: $navigatorModel.selection) { folder in
                    FolderTreeDisclosure(folder: folder, selection: $navigatorModel.selection) { folder in
                        navigatorModel.update(folder: folder)
                    }
                }
                .focused($navigatorIsFocused)
                .onAppear {
                    navigatorIsFocused = true
                }
            }
        } else {
            Text("Drop a folder here.")
        }
    }
}
