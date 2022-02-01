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

class SelectedFile: ObservableObject {
    @Published var file:URL? = nil
}

struct Thumbnail: View {
    var file:URL
    @ObservedObject var selectedFile:SelectedFile
    var action: () -> Void

    var body: some View {
        Button(action: {
             if (selectedFile.file != file) {
                selectedFile.file = file
                action()
            }
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

    @State var detailImageViewModel = DetailImageViewModel()
    @State var scrollViewHeight:CGFloat = 200

    @ObservedObject var selectedFile:SelectedFile = SelectedFile()

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
                                detailImageViewModel.showImage(atURL: file)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: scrollViewHeight, maxHeight: scrollViewHeight)
        }
        .onReceive(fileListing.$files) { value in
            detailImageViewModel.hideImage()
        }
    }
}
