//
//  ContentView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI

struct FolderView: View {
    var folder:URL
    @State var open = false

    var body: some View {
        HStack {
            Button(action: {
                open = !open
            }) {
                Image(systemName: open ? "chevron.down" : "chevron.right" )
            }
            .buttonStyle(PlainButtonStyle())

            Label(folder.lastPathComponent, systemImage: "folder.fill")
        }
    }
}

class NavigatorModel: ObservableObject {
    @Published var parentFolder:URL? = nil
    @Published var folders:[URL] = []
}

struct ContentView: View {
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
                if (navigatorModel.folders.count == 0) {
                    Text("Drop a folder here.")
                } else {
                    VStack {
                        let directoryPath = navigatorModel.parentFolder != nil ? navigatorModel.parentFolder!.lastPathComponent : ""

                        Label("\(directoryPath)", systemImage: "lightbulb.fill")

                        List(navigatorModel.folders, id:\.self, selection: $multiSelection) {
                            FolderView(folder: $0)
                        }
                        .navigationTitle("Folders")
                        .onChange(of: multiSelection) { newValue in
                            if (newValue.first != nil) {
                                imageBrowserModel.setFiles(files: imageFileListingAt(url: newValue.first!))
                                imageActive = true
                            }
                        }
                        .onReceive(navigatorModel.$folders) { folders in
                            // Reset navigator's selection
                            multiSelection = Set<URL>()

                            // Reset image browser state
                            imageBrowserModel.files = []
                            imageBrowserModel.selection = []
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
                    var listing:[URL] = []
                    let selectedDirectory = NSOpenPanelDirectoryListing(files: &listing)
                    if (listing.count > 0) {
                        model?.parentFolder = selectedDirectory
                        model?.folders = listing
                    }
                }
                .keyboardShortcut("O", modifiers: .command)
                .disabled(model == nil)
            }
        }
    }
}

extension ContentView:DropDelegate {
    @MainActor
    func performDrop(info: DropInfo) -> Bool {
        DropUtils.urlFromDropInfo(info) { url in
            if let url = url {
                DispatchQueue.main.async {
                    navigatorModel.folders = folderListingAt(url: url)
                }
            }
        }
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
