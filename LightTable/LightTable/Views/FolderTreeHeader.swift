//
//  FolderTreeNavigation.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import SwiftUI

struct FolderTreeHeader: View {
    @StateObject var navigatorModel = NavigatorModel()

    var body: some View {
        HStack {
            if let root = navigatorModel.root {
                Button {
                    navigatorModel.back()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)

                Button {
                    navigatorModel.forward()
                } label: {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)

                Text(root.lastPathComponent)
                    .bold()
                    .font(.title2)

                Spacer()

                let parents = parentFoldersList(url: root)
                Menu(content: {
                    ForEach(parents, id: \.self) { item in
                        Button(action: {
                            navigatorModel.update(url: item)
                        }, label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                Text(item.lastPathComponent)
                            }
                        })
                    }
                }, label: {
                    Image(systemName: "list.bullet.indent")
                        .font(.title2)
                })
                .menuStyle(.borderlessButton)
                .menuIndicator(.visible)
                .fixedSize()
            }
        }
    }
}
