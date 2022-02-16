//
//  ContentView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI

func parentFoldersList(url: URL) -> [URL] {
    let rootPath = URL(string: "file:///")
    var parents:[URL] = []
    if (url.hasDirectoryPath) {
        var current = url
        repeat {
            parents.append(current)
            current = current.deletingLastPathComponent()
        } while(current != rootPath)
    }
    return parents
}

func parentFolder(url: URL) -> URL {
    let rootPath = URL(string: "file:///")
    let parent = url.deletingLastPathComponent()
    if parent != rootPath {
        return parent
    }
    return url
}

private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?
        .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct LightTableView: View {
    @StateObject private var imageBrowserModel = ImageBrowserModel()
    @StateObject private var navigatorModel = NavigatorModel()

    let backgroundColor = Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)

    var body: some View {
        let navigatorModelBinding = Binding<NavigatorModel>(
            get: { navigatorModel },
            set: { val in }
        )

        let browserActive = !imageBrowserModel.directories.isEmpty

        let modelBinding = Binding<ImageBrowserModel>(
            get: { imageBrowserModel },
            set: { val in }
        )

        VStack {
            ZStack {
                NavigationView {
                    FolderTreeNavigator(imageBrowserModel: imageBrowserModel, navigatorModel: navigatorModel)
                        .frame(minWidth: 250)
                        .toolbar {
                            ToolbarItem(placement: .automatic) {
                                Button(action: toggleSidebar) {
                                    Image(systemName: "sidebar.left")
                                    .help("Toggle Sidebar")
                                }
                            }
                        }

                    if (browserActive) {
                        ImageBrowserView(model: imageBrowserModel)
                            .toolbar {
                                LightTableToolbar(model: imageBrowserModel)
                            }
                    }
                }
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .focusedSceneValue(\.focusedNavigatorModel, navigatorModelBinding)
                .onDrop(of: ["public.file-url"], delegate: self)

                if imageBrowserModel.fullScreen {
                    ImageListView(model: imageBrowserModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .focusedSceneValue(\.focusedBrowserModel, modelBinding)
                        .background(backgroundColor)
                }
            }
        }
        .background(backgroundColor)
        .onChange(of: navigatorModel.multiSelection) { newValue in
            var directories:[URL] = []

            for entry in navigatorModel.multiSelection {
                directories.append(entry)
            }

            imageBrowserModel.setDirectories(directories: directories)
        }
        .onReceive(navigatorModel.$children) { children in
            // Reset navigator's selection
            navigatorModel.multiSelection = Set<URL>()

            // Reset image browser state
            imageBrowserModel.reset()
        }
    }

    struct ContentCommands: Commands {
        @FocusedBinding(\.focusedNavigatorModel) private var model: NavigatorModel?

        var body: some Commands {
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Open...") {
                    if let model = model {
                        var listing:[URL] = []
                        let selectedDirectory = NSOpenPanelDirectoryListing(files: &listing)
                        if (listing.count > 0) {
                            model.root = selectedDirectory
                            model.children = listing
                        }
                    }
                }
                .keyboardShortcut("O", modifiers: .command)
                .disabled(model == nil)
            }

            CommandMenu("Go") {
                CommandButton(model: model, label: "Back", key: "[", modifiers: [.command]) { model in
                    model.back()
                }

                CommandButton(model: model, label: "Forward", key: "]", modifiers: [.command]) { model in
                    model.forward()
                }

                CommandButton(model: model, label: "Enclosing Folder", key: .upArrow, modifiers: [.command]) { model in
                    if let root = model.root {
                        model.update(url: parentFolder(url: root))
                        model.multiSelection = [root]
                    }
                }

                CommandButton(model: model, label: "Selected Folder", key: .downArrow, modifiers: [.command]) { model in
                    if let selection = model.multiSelection.first {
                        model.update(url: selection)
                    }
                }
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
