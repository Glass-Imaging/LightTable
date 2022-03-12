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
    @ObservedObject var navigatorModel:NavigatorModel

    @FocusState private var navigatorIsFocused: Bool

    @Environment(\.controlActiveState) var windowState: ControlActiveState

    var body: some View {
        if let root = navigatorModel.root {
            VStack(alignment: .leading) {
                Divider()

                FolderTreeHeader(navigatorModel: navigatorModel)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .opacity(windowState == .inactive ? 0.7 : 1.0)

                Divider()

                ScrollViewReader { proxy in
                    if let children = root.children {
                        List(children, id:\.self, selection: $navigatorModel.selection) { folder in
                            RecursiveView(item: folder, id:\.self, children: \.children, expandedItems: $navigatorModel.expandedItems) { folder in
                                Label(folder.url.lastPathComponent, systemImage: folder.hasImages ? "folder.fill" : "folder")
                                .if(folder.children != nil, transform: { view in
                                    view.gesture(TapGesture(count: 2).onEnded {
                                        navigatorModel.update(url: folder.url)
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
                        .onChange(of: navigatorModel.expandedItems, perform: { [expandedItems = navigatorModel.expandedItems] newExpandedItems in
                            // Remove folder selections in collapsed disclosures
                            if expandedItems.count > newExpandedItems.count {
                                for removed in expandedItems.symmetricDifference(newExpandedItems) {
                                    for item in navigatorModel.selection {
                                        if item.url != removed.url && item.url.starts(with: removed.url) {
                                            navigatorModel.selection.remove(item)
                                        }
                                    }
                                }
                            }
                        })
                        .focused($navigatorIsFocused)
                        .onAppear {
                            navigatorIsFocused = true

                            if let selectionFirst = navigatorModel.selection.first {
                                // Make sure that some of the selection is visible
                                DispatchQueue.main.async {
                                    proxy.scrollTo(selectionFirst)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            Text("Drop a folder here")
        }
    }
}
