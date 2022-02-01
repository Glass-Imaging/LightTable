//
//  ContentView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI

class Folder : Hashable, Equatable, Identifiable {
    let id:URL
    // var children:Folder?

    func url() -> URL {
        return id
    }

    static func == (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(url:URL) {
        self.id = url
    }
}

struct FolderView: View {
    var folder:Folder
    @State var open = false

    var body: some View {
        HStack {
            Button(action: {
                open = !open
            }) {
                Image(systemName: open ? "chevron.down" : "chevron.right" )
            }
            .buttonStyle(PlainButtonStyle())

            Label(folder.url().lastPathComponent, systemImage: "folder.fill")
        }
    }
}

struct ContentView: View {
    @State var folders:[Folder] = []
    @State var fileListing = FileListing()
    @State var imageActive = false

    @State private var multiSelection = Set<URL>()

    var body: some View {
        NavigationView {
            HStack {
                if (folders.count == 0) {
                    Text("Drop a folder here.")
                } else {
                    VStack {
                        Text("\(multiSelection.count) selections")

                        List(folders, selection: $multiSelection) {
                            FolderView(folder: $0)
                        }
                        .navigationTitle("Folders")
                        .onChange(of: multiSelection) { newValue in
                            if (newValue.first != nil) {
                                fileListing.files = fileListingAt(url: newValue.first!)
                                imageActive = true                            }
                        }
                    }
                }

                NavigationLink(destination: ImageBrowser(fileListing: fileListing), isActive: $imageActive){}.hidden()
            }
        }
        .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        .onDrop(of: ["public.file-url"], delegate: self)
    }
}

extension ContentView:DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        DropUtils.urlFromDropInfo(info) { url in
            if let url = url {
                self.folders = folderListingAt(url: url)
            }
        }
        return true
    }
}

func fileListingAt(url:URL) -> [URL] {
    let manager = FileManager.default
    do {
        var entries:[URL] = []
        let items = try manager.contentsOfDirectory(at: url,
                                                    includingPropertiesForKeys: nil,
                                                    options: .skipsSubdirectoryDescendants)
        for item in items {
            let file_extension = item.pathExtension.lowercased()
            if (file_extension == "jpg" || file_extension == "jpeg" || file_extension == "png") {
                entries.append(item)
            }
        }
        return entries
    } catch {
        return []
    }
}

func folderListingAt(url:URL) -> [Folder] {
    let manager = FileManager.default
    do {
        var entries:[Folder] = []
        let items = try manager.contentsOfDirectory(at: url,
                                                    includingPropertiesForKeys: nil,
                                                    options: .skipsSubdirectoryDescendants)
        for item in items {
            if (item.hasDirectoryPath) {
                entries.append(Folder(url: item))
            }
        }
        return entries
    } catch {
        return []
    }
}

func selectDirectory(files:inout[URL]) -> String {
    var selection:String = ""
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false

    if panel.runModal() == .OK {
        selection = panel.url?.path ?? "<none>"
        print("Path: ", selection)
    }

    files = fileListingAt(url:URL(fileURLWithPath: selection, isDirectory: true))
    return selection
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
