//
//  ContentView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

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
        let browserActive = !browserModel.directories.isEmpty

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
                        .onChange(of: navigatorModel.selection) { newValue in
                            var directories:[URL] = []
                            for entry in navigatorModel.selection {
                                directories.append(entry)
                            }
                            browserModel.setDirectories(directories: directories)
                            viewModel.resetImageViewSelection()
                        }
                        .onChange(of: navigatorModel.root) { _ in
                            // Reset navigator's selection
                            navigatorModel.selection = Set<URL>()

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

    struct ContentCommands: Commands {
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
