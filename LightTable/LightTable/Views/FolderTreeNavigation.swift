//
//  FolderTreeNavigation.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/9/22.
//

import SwiftUI

struct FolderTreeNavigation: View {
    @StateObject var navigatorModel = NavigatorModel()

    var body: some View {
        HStack {
            if let root = navigatorModel.root {
                Spacer(minLength: 10)

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

                Spacer()

                let parents = parentFoldersList(url: root)
                Menu(content: {
                    ForEach(parents, id: \.self) { item in
                        Button(action: {
                            navigatorModel.update(url: item)
                        }, label: {
                            Label(item.lastPathComponent, systemImage: "folder.fill")
                        })
                    }
                }, label: {
                    Label(root.lastPathComponent, systemImage: "list.bullet.indent")
                        .font(.largeTitle)
                        .imageScale(.large)
                })
                .menuStyle(.borderlessButton)

                Spacer(minLength: 10)
            }
        }
    }
}
