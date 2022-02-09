//
//  ContentView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI

class NavigatorModel: ObservableObject {
    @Published var root:URL? = nil
    @Published var children:[URL] = []
}

func urlParents(url: URL) -> [URL] {
    let rootPath = URL(string: "file:///")
    var parents:[URL] = []
    if (url.hasDirectoryPath) {
        var current = url
        repeat {
            if (current != url) {
                parents.append(current)
            }
            current = current.deletingLastPathComponent()
        } while(current != rootPath)
    }
    return parents
}

struct LightTableView: View {
    @StateObject private var imageBrowserModel = ImageBrowserModel()
    @StateObject private var navigatorModel = NavigatorModel()

    @State private var multiSelection = Set<URL>()
    @State private var imageActive = false

    var body: some View {
        // We need a binding for .focusedSceneValue, although model as @ObservedObject is read only...
        let navigatorModelBinding = Binding<NavigatorModel>(
            get: { navigatorModel },
            set: { val in }
        )

        NavigationView {
            HStack {
                if (navigatorModel.children.count == 0) {
                    Text("Drop a folder here.")
                } else {
                    VStack {
                        if let root = navigatorModel.root {
                            let parents = urlParents(url: root)
                            Menu(root.lastPathComponent) {
                                ForEach(parents, id: \.self) { item in
                                    Button(item.lastPathComponent, action: {
                                        navigatorModel.root = item
                                        navigatorModel.children = folderListingAt(url: item)
                                    })
                                }
                            }
                        }

                        List(navigatorModel.children, id:\.self, selection: $multiSelection) { folder in
                            FolderDisclosure(url: folder, selection: $multiSelection, doubleTapAction:{ url in
                                navigatorModel.root = url
                                navigatorModel.children = folderListingAt(url: url)
                            })
                        }
                        .onChange(of: multiSelection) { newValue in
                            var directories:[URL] = []

                            for entry in multiSelection {
                                directories.append(entry)
                            }

                            imageBrowserModel.setDirectories(directories: directories)

                            imageActive = !directories.isEmpty
                        }
                        .onReceive(navigatorModel.$children) { children in
                            // Reset navigator's selection
                            multiSelection = Set<URL>()

                            // Reset image browser state
                            imageBrowserModel.reset()
                        }
                    }
                }

                NavigationLink(destination: ImageBrowserView(model: imageBrowserModel), isActive: $imageActive){}.hidden()
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
        }
    }
}

extension LightTableView:DropDelegate {
    @MainActor
    func performDrop(info: DropInfo) -> Bool {
        DropUtils.urlFromDropInfo(info) { url in
            if let url = url {
                DispatchQueue.main.async {
                    navigatorModel.root = url
                    navigatorModel.children = folderListingAt(url: url)
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
