//
//  ImageBrowser.swift
//  PhotoBrowser
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: { }
        }
        .buttonStyle(PlainButtonStyle())
        .background(configuration.isOn ? Color.blue : nil)
    }
}

class SelectedFile: ObservableObject, Equatable {
    @Published var file:URL? = nil

    static func == (lhs: SelectedFile, rhs: SelectedFile) -> Bool {
        return lhs.file == rhs.file
    }
}

struct Thumbnail: View {
    var file:URL
    @ObservedObject var selectedFile:SelectedFile
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                ThumbnailView(withURL: file, maxSize: 200)
                Text(file.lastPathComponent)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(selectedFile.file == file ? Color.blue : nil)
    }
}

struct ImageBrowser: View {
    @ObservedObject var fileListing:FileListing
    @ObservedObject var selectedFile:SelectedFile = SelectedFile()

    @State var detailImageViewModel = DetailImageViewModel()
    @State var scrollViewHeight:CGFloat = 200

    @EnvironmentObject private var keyInputSubjectWrapper: KeyInputSubjectWrapper

    var body: some View {
        VSplitView {
            DetailImageView(viewModel: detailImageViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            ScrollView(.horizontal, showsIndicators: true) {
                if (fileListing.files.count == 0) {
                    Text("Select a folder with images")
                        .padding(100)
                } else {
                    LazyHStack(alignment: .bottom) {
                        ForEach(fileListing.files, id: \.self) { file in
                            Thumbnail(file: file, selectedFile: selectedFile) {
                                updateSelection(selection: file)
                            }
                        }
                    }.onReceive(keyInputSubjectWrapper) {
                        let inputKey = $0

                        if (fileListing.files.isEmpty) {
                            return
                        }
                        guard let currentSelection = selectedFile.file else {
                            updateSelection(selection: fileListing.files[0])
                            return
                        }
                        guard let index = fileListing.files.firstIndex(of: currentSelection) else {
                            return
                        }
                        if (inputKey == .rightArrow && index < fileListing.files.count - 1) {
                            updateSelection(selection: fileListing.files[index + 1])
                        } else if (inputKey == .leftArrow && index > 0) {
                            updateSelection(selection: fileListing.files[index - 1])
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: scrollViewHeight, maxHeight: scrollViewHeight)
        }
        .onReceive(fileListing.$files) { value in
            detailImageViewModel.hideImage()
        }
        .onChange(of: selectedFile.file) { newFile in
            if (newFile != nil) {
                detailImageViewModel.showImage(atURL: newFile!)
            }
        }
    }

    func updateSelection(selection: URL) {
        if (selectedFile.file != selection) {
            selectedFile.file = selection
        }
    }
}
