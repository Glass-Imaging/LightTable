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

private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?
        .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct LightTableView: View {
    @State var navigatorModel = NavigatorModel()
    @State var browserModel = ImageBrowserModel()
    @State var viewModel = ImageViewModel()

    let backgroundColor = Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)

    var body: some View {
        let browserActive = !browserModel.folders.isEmpty

        VStack {
            if viewModel.fullScreen {
                ImageListView(browserModel: $browserModel, viewModel: $viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
                    .toolbar {
                        LightTableToolbar()
                    }
            } else {
                NavigationView {
                    FolderTreeNavigator(navigatorModel: $navigatorModel)
                        .frame(minWidth: 250)
                        .toolbar {
                            ToolbarItem(placement: .automatic) {
                                Button(action: toggleSidebar) {
                                    Image(systemName: "sidebar.left")
                                    .help("Toggle Sidebar")
                                }
                            }
                        }
                        .onChange(of: navigatorModel.selection) { newSelection in
                            browserModel.setFolders(folders: newSelection)
                            viewModel.resetImageViewSelection()
                        }
                        .onChange(of: navigatorModel.root) { _ in
                            // Reset image browser state
                            browserModel.reset()
                            viewModel.resetImageViewSelection()
                        }

                    if (browserActive) {
                        ImageBrowserView(browserModel: $browserModel, viewModel: $viewModel)
                            .toolbar {
                                LightTableToolbar()
                            }
                    }
                }
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .onDrop(of: ["public.file-url"], delegate: self)
            }
        }
        .focusedSceneValue(\.focusedNavigatorModel, $navigatorModel)
        .focusedSceneValue(\.focusedBrowserModel, $browserModel)
        .focusedSceneValue(\.focusedViewModel, $viewModel)
        .background(backgroundColor)
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedNavigatorModel) var navigatorModel: NavigatorModel?

        var body: some Commands {
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Open...") {
                    var listing:[URL] = []
                    if let selectedDirectory = NSOpenPanelDirectoryListing(files: &listing) {
                        navigatorModel?.update(folder: Folder(url: selectedDirectory))
                    }
                }
                .keyboardShortcut("O", modifiers: .command)
                .disabled(navigatorModel == nil)
            }

            CommandMenu("Go") {
                CommandButton(label: "Back", key: "[", modifiers: [.command]) {
                    navigatorModel?.back()
                }.disabled(navigatorModel == nil || !navigatorModel!.hasBackHistory())

                CommandButton(label: "Forward", key: "]", modifiers: [.command]) {
                    navigatorModel?.forward()
                }.disabled(navigatorModel == nil || !navigatorModel!.hasForwardHistory())

                CommandButton(label: "Enclosing Folder", key: .upArrow, modifiers: [.command]) {
                    navigatorModel?.enclosingFolder()
                }.disabled(navigatorModel == nil)

                CommandButton(label: "Selected Folder", key: .downArrow, modifiers: [.command]) {
                    navigatorModel?.selectedFolder()
                }.disabled(navigatorModel == nil || !navigatorModel!.hasSelection())
            }
        }
    }
}

extension LightTableView:DropDelegate {
    @MainActor
    func performDrop(info: DropInfo) -> Bool {
        DropUtils.urlFromDropInfo(info) { url in
            if let url = url {
                DispatchQueue.main.async {
                    navigatorModel.update(folder: Folder(url: url))
                }
            }
        }
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LightTableView()
    }
}
