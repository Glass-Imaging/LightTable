// Copyright (c) 2022 Glass Imaging Inc.
// Author: Fabio Riccardi <fabio@glass-imaging.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
