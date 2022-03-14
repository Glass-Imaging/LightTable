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

extension URL {
    func starts(with url: URL) -> Bool {
        if (url.pathComponents.count <= pathComponents.count) {
            for i in 0 ..< url.pathComponents.count {
                if url.pathComponents[i] != pathComponents[i] {
                    return false
                }
            }
            return true
        }
        return false
    }
}

struct LightTableView: View {
    @StateObject var viewModel = ImageViewModel()
    @StateObject var navigatorModel = NavigatorModel()
    @StateObject var browserModel = ImageBrowserModel()

    @EnvironmentObject private var appDelegate: AppDelegate

    @AppStorage("navigatorModel.root") private var navigatorModelRoot:String?
    @AppStorage("navigatorModel.selection") private var navigatorModelSelection:[String]?
    @AppStorage("browserModel.selection") private var browserModelSelection:[String]?

    let backgroundColor = Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)

    // Used to toggle fullScreen mode and sidebar visibility
    @State var window:NSWindow? = nil

    func restoreNavigatorState() {
        if navigatorModel.root == nil {
            // Restore Navigator state
            navigatorModel.resetWith(storedRoot: navigatorModelRoot, storedSelection: navigatorModelSelection)

            // Restore image browser selection
            if let browserModelSelection = browserModelSelection {
                browserModel.selection = browserModelSelection.map({ URL(fileURLWithPath: $0) }).filter { item in
                    // Validate selection entries
                    resourceIsReachable(url: item) && navigatorModel.selection.contains(where: { $0.url == parentFolder(url: item) })
                }
            }
        }
    }

    var body: some View {
        VStack {
            if viewModel.fullScreen {
                ImageListView(browserModel: browserModel, viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
            } else {
                NavigationView {
                    FolderTreeNavigator(navigatorModel: navigatorModel)
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

                            navigatorModelRoot = navigatorModel.root?.url.path
                        }
                        .onChange(of: navigatorModel.selection) { selection in
                            browserModel.setFolders(folders: Set(selection.map({ $0 })))
                            viewModel.resetImageViewSelection()

                            navigatorModelSelection = selection.map({ $0.url.path })
                        }

                    ImageBrowserView(browserModel: browserModel, viewModel: viewModel)
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
        .onAppear(perform: {
            DispatchQueue.main.async {
                window = NSApplication.shared.windows.last
            }
        })
        .onChange(of: viewModel.fullScreen, perform: { _ in
            if appDelegate.fullScreen != viewModel.fullScreen {
                DispatchQueue.main.async {
                    window?.toolbar?.isVisible = !viewModel.fullScreen
                    window?.toggleFullScreen(nil)
                }
            }
        })
        .onChange(of: appDelegate.fullScreen, perform: { _ in
            viewModel.fullScreen = appDelegate.fullScreen
            DispatchQueue.main.async {
                window?.toolbar?.isVisible = !viewModel.fullScreen
            }
        })
        // Set imageViewState @EnvironmentObject for ImageView
        .environmentObject(viewModel.imageViewState)
        .focusedSceneValue(\.focusedViewModel, Binding<ImageViewModel>.constant(viewModel))
        .focusedSceneValue(\.focusedNavigatorModel, Binding<NavigatorModel>.constant(navigatorModel))
        .focusedSceneValue(\.focusedBrowserModel, Binding<ImageBrowserModel>.constant(browserModel))
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
