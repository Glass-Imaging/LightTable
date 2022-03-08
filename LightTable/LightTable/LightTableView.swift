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
    @StateObject var viewModel = ImageViewModel()
    @State var navigatorModel = NavigatorModel()
    @State var browserModel = ImageBrowserModel()

    @AppStorage("navigatorModel.root") private var navigatorModelRoot:String?
    @AppStorage("navigatorModel.selection") private var navigatorModelSelection:[String]?
    @AppStorage("browserModel.selection") private var browserModelSelection:[String]?

    let backgroundColor = Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)

    func restoreNavigatorState() {
        if navigatorModel.root == nil {
            var restoredRoot:URL? = nil

            // Restore root folder
            if let navigatorModelRoot = navigatorModelRoot {
                let url = URL(fileURLWithPath: navigatorModelRoot)
                if resourceIsReachable(url: url) {
                    restoredRoot = url
                    DispatchQueue.main.async {
                        navigatorModel.update(url: url)
                    }
                }
            }

            // Restore selection
            var navigatorSelection = Set<URL>()
            if let navigatorModelSelection = navigatorModelSelection {
                if let root = restoredRoot {
                    let savedSelection = navigatorModelSelection.map({ URL(fileURLWithPath: $0) })

                    var expandedItems = Set<URL>()

                    for item in savedSelection {
                        if item.path.starts(with: root.path) && resourceIsReachable(url: item) {
                            // If the selection is in a sub folder, add the path to the navigatorModel.expandedItems
                            var parent = parentFolder(url: item)
                            while (parent.path != root.path) {
                                expandedItems.insert(parent)
                                parent = parentFolder(url: parent)
                            }
                            navigatorSelection.insert(item)
                        }
                    }
                    DispatchQueue.main.async {
                        navigatorModel.selection = navigatorSelection
                        navigatorModel.expandedItems = expandedItems
                    }
                }
            }

            if let browserModelSelection = browserModelSelection {
                let restoredSelection = browserModelSelection.map({ URL(fileURLWithPath: $0) })
                var trimmedSelection:[URL] = []

                // Validate selection entries
                for item in restoredSelection {
                    if resourceIsReachable(url: item) && navigatorSelection.contains(parentFolder(url: item)) {
                        trimmedSelection.append(item)
                    }
                }

                DispatchQueue.main.async {
                    browserModel.selection = trimmedSelection
                }
            }
        }
    }

    var body: some View {
        let browserActive = !browserModel.folders.isEmpty

        VStack {
            if viewModel.fullScreen {
                ImageListView(browserModel: $browserModel, viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
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
                        .onChange(of: navigatorModel.root) { [previousRoot = navigatorModel.root] newRoot in
                            if previousRoot != nil {
                                // Reset image browser state
                                browserModel.reset()
                                viewModel.resetImageViewSelection()
                            }

                            navigatorModelRoot = navigatorModel.root?.path
                        }
                        .onChange(of: navigatorModel.selection) { selection in
                            browserModel.setFolders(folders: Set(selection.map({ Folder(url: $0) })))
                            viewModel.resetImageViewSelection()

                            navigatorModelSelection = selection.map({ $0.path })
                        }

                    if (browserActive) {
                        ImageBrowserView(browserModel: $browserModel, viewModel: viewModel)
                    }
                }
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .onDrop(of: ["public.file-url"], delegate: self)
                .onAppear {
                    restoreNavigatorState()
                }
            }
        }
        .onChange(of: browserModel.selection) { selection in
            browserModelSelection = selection.map({ $0.path })
        }
        // Set imageViewState @EnvironmentObject for ImageView
        .environmentObject(viewModel.imageViewState)
        .focusedSceneValue(\.focusedViewModel, Binding<ImageViewModel>.constant(viewModel))
        .focusedSceneValue(\.focusedNavigatorModel, $navigatorModel)
        .focusedSceneValue(\.focusedBrowserModel, $browserModel)
        .background(backgroundColor)
    }

    struct BrowserCommands: Commands {
        @FocusedBinding(\.focusedNavigatorModel) var navigatorModel: NavigatorModel?

        var body: some Commands {
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Open...") {
                    var listing:[URL] = []
                    if let selectedDirectory = NSOpenPanelDirectoryListing(files: &listing) {
                        navigatorModel?.update(url: selectedDirectory)
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
                    navigatorModel.update(url: url)
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
