//
//  FolderTreeNavigation.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import SwiftUI

struct FolderTreeHeader: View {
    @Binding var navigatorModel:NavigatorModel

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

                Text(root.url.lastPathComponent)
                    .bold()
                    .font(.title2)

                Spacer()

                // "Custom Style" Menu Button with large icon B]
                let parents = parentFoldersList(url: root.url)
                Menu(content: {
                    ForEach(parents, id: \.self) { item in
                        Button(action: {
                            navigatorModel.update(folder: Folder(url: item))
                        }, label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                Text(item.lastPathComponent)
                            }
                        })
                    }
                }, label: {
                    Text("")
                })
                    .frame(width: 40)
                    .background(
                        Image(systemName: "list.bullet.indent")
                            .font(.title2)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    )
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.visible)
                    .fixedSize()
            }
        }
    }
}
