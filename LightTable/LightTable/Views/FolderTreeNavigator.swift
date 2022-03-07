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

                List(root.children!, id:\.self, selection: $navigatorModel.selection) { folder in
                    RecursiveView(item: folder, id:\.self, children: \.children, expandedItems: $navigatorModel.expandedItems) { folder in
                        Label(folder.url.lastPathComponent, systemImage: folder.hasImages ? "folder.fill" : "folder")
                        .if(folder.children != nil, transform: { view in
                            view.gesture(TapGesture(count: 2).onEnded {
                                navigatorModel.update(folder: folder)
                            })
                            .gesture(TapGesture(count: 1).modifiers([.shift]).onEnded {
                                navigatorModel.selection.insert(folder)
                            })
                            .gesture(TapGesture(count: 1).modifiers([.command]).onEnded {
                                navigatorModel.selection.insert(folder)
                            })
                            .gesture(TapGesture(count: 1).onEnded {
                                navigatorModel.selection = [folder]
                            })
                        })
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
