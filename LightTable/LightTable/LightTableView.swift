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
    if (url.hasDirectoryPath) {
        let parent = url.deletingLastPathComponent()
        if parent != rootPath {
            return parent
        }
    }
    return url
}

struct LightTableView: View {
    @StateObject private var imageBrowserModel = ImageBrowserModel()
    @StateObject private var navigatorModel = NavigatorModel()

    @State private var imageActive = false

    var body: some View {
        // We need a binding for .focusedSceneValue, although model as @ObservedObject is read only...
        let navigatorModelBinding = Binding<NavigatorModel>(
            get: { navigatorModel },
            set: { val in }
        )

        let selectionBinding = Binding<Set<URL>>(
            get: { navigatorModel.multiSelection },
            set: { val in navigatorModel.multiSelection = val }
        )

        NavigationView {
            HStack(spacing: 0) {
                if (navigatorModel.children.count == 0) {
                    Text("Drop a folder here.")
                } else {
                    VStack(alignment: .leading) {
                        Spacer(minLength: 10)

                        FolderTreeNavigation(navigatorModel: navigatorModel)

                        Spacer()
                        
                        Divider()

                        List(navigatorModel.children, id:\.self, selection: selectionBinding) { folder in
                            FolderTreeDisclosure(url: folder, selection: selectionBinding, doubleTapAction:{ url in
                                navigatorModel.update(url: url)
                            })
                        }
                        .onChange(of: navigatorModel.multiSelection) { newValue in
                            var directories:[URL] = []

                            for entry in navigatorModel.multiSelection {
                                directories.append(entry)
                            }

                            imageBrowserModel.setDirectories(directories: directories)

                            imageActive = !directories.isEmpty
                        }
                        .onReceive(navigatorModel.$children) { children in
                            // Reset navigator's selection
                            navigatorModel.multiSelection = Set<URL>()

                            // Reset image browser state
                            imageBrowserModel.reset()
                        }
                    }
                }

                NavigationLink(destination: ImageBrowserView(model: imageBrowserModel), isActive: $imageActive){}.hidden()
                    .frame(width: 0, height: 0)
            }
        }
        .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        .focusedSceneValue(\.focusedNavigatorModel, navigatorModelBinding)
        .onDrop(of: ["public.file-url"], delegate: self)
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
                commandButton(model: model, label: "Back", key: "[", modifiers: [.command]) { model in
                    model.back()
                }

                commandButton(model: model, label: "Forward", key: "]", modifiers: [.command]) { model in
                    model.forward()
                }

                commandButton(model: model, label: "Enclosing Folder", key: .upArrow, modifiers: [.command]) { model in
                    if let root = model.root {
                        model.update(url: parentFolder(url: root))
                        model.multiSelection = [root]
                    }
                }

                commandButton(model: model, label: "Selected Folder", key: .downArrow, modifiers: [.command]) { model in
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
