//
//  ContentView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI

class FolderNode : Hashable, Equatable {
    var url:URL
    var children:FolderNode?

    static func == (lhs: FolderNode, rhs: FolderNode) -> Bool {
        return lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

    init(url:URL) {
        self.url = url
    }
}

struct Folder: View {
    @State var selected = false
    @State var open = false
    var text = ""
    var action = {}

    var body: some View {
        Button(action: {
            self.action()
            selected = !selected
        }) {
            HStack {
                Button(action: {
                    open = !open
                }) {
                    Image(systemName: open ? "chevron.down" : "chevron.right" )
                }
                .buttonStyle(PlainButtonStyle())

                Image(systemName: "folder.fill")

                Text(text).bold()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(selected ? Color.gray : nil)
    }
}

struct FolderTree: View {
    @State var folders:[FolderNode] = []
    @State var selectedFolders:[URL] = []

    var action: (_ url: URL) -> Void

    var body: some View {
        List {
            ForEach(folders, id: \.self) { folder in
                Folder(text: folder.url.lastPathComponent, action: {
                    let index = selectedFolders.firstIndex(of: folder.url)
                    if (index != nil) {
                        print("removing element at index", index!, selectedFolders[index!])
                        selectedFolders.remove(at: index!)
                    } else {
                        action(folder.url)

                        print("appending folder to the selected list", folder.url)
                        selectedFolders.append(folder.url)
                    }
                })
            }
        }
        .font(.largeTitle)
    }
}

struct ContentView: View {
    @State var folders:[FolderNode] = []
    @State var fileListing = FileListing()
    @State var imageActive = false

    var body: some View {
        NavigationView {
            HStack {
                if (folders.count == 0) {
                    Text("Drop a folder here.")
                } else {
                    FolderTree(folders: folders) { url in
                        fileListing.files = fileListingAt(url: url)
                        imageActive = true
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

func folderListingAt(url:URL) -> [FolderNode] {
    let manager = FileManager.default
    do {
        var entries:[FolderNode] = []
        let items = try manager.contentsOfDirectory(at: url,
                                                    includingPropertiesForKeys: nil,
                                                    options: .skipsSubdirectoryDescendants)
        for item in items {
            if (item.hasDirectoryPath) {
                entries.append(FolderNode(url: item))
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
