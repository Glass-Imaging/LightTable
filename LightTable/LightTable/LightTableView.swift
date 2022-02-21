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
    @StateObject var imageBrowserModel = ImageBrowserModel()
    @State var navigatorModel = NavigatorModel()

    let backgroundColor = Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)

    var body: some View {
        let browserActive = !imageBrowserModel.directories.isEmpty

        let modelBinding = Binding<ImageBrowserModel>(
            get: { imageBrowserModel },
            set: { _in in }
        )

        VStack {
            ZStack {
                NavigationView {
                    FolderTreeNavigator(imageBrowserModel: imageBrowserModel, navigatorModel: $navigatorModel)
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
                                LightTableToolbar()
                            }
                    }
                }
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .focusedSceneValue(\.focusedNavigatorModel, $navigatorModel)
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
        .onChange(of: navigatorModel.children) { children in
            // Reset navigator's selection
            navigatorModel.multiSelection = Set<URL>()

            // Reset image browser state
            imageBrowserModel.reset()
        }
    }

    struct ContentCommands: Commands {
        @FocusedBinding(\.focusedNavigatorModel) var model: NavigatorModel?

        var body: some Commands {
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Open...") {
                    var listing:[URL] = []
                    if let selectedDirectory = NSOpenPanelDirectoryListing(files: &listing) {
                        model?.update(url: selectedDirectory, listing: listing)
                    }
                }
                .keyboardShortcut("O", modifiers: .command)
                .disabled(model == nil)
            }

            CommandMenu("Go") {
                CommandButton(label: "Back", key: "[", modifiers: [.command]) {
                    model?.back()
                }.disabled(model == nil || !model!.hasBackHistory())

                CommandButton(label: "Forward", key: "]", modifiers: [.command]) {
                    model?.forward()
                }.disabled(model == nil || !model!.hasForwardHistory())

                CommandButton(label: "Enclosing Folder", key: .upArrow, modifiers: [.command]) {
                    model?.enclosingFolder()
                }.disabled(model == nil)

                CommandButton(label: "Selected Folder", key: .downArrow, modifiers: [.command]) {
                    model?.selectedFolder()
                }.disabled(model == nil || !model!.hasSelection())
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
