//
//  ImageView.swift
//  LightTable
//
//  Created by Gualtiero Frigerio on 03/02/2021.
//

import Combine
import SwiftUI

struct ImageView: View {
    @ObservedObject var imageLoader = ImageLoader()
    @State var image:NSImage = NSImage()
    let url:URL

    @ObservedObject var model:ImageBrowserModel

    init(withURL url:URL, model:ImageBrowserModel) {
        self.model = model
        self.url = url
        imageLoader.load(url:url)
    }

    var body: some View {
        ZStack {
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                // NOTE: Without the orientation-specific Text label the orientation changes are not picked up
                Image(cgImage, scale: 1, orientation: model.orientation, label: Text(String(describing: model.orientation)))
                    .resizable()
                    .scaledToFit()
            }

            if image.isValid {
                VStack() {
                    Spacer()

                    let parentFolder = parentFolder(url:url).lastPathComponent
                    let filename = url.lastPathComponent
                    Text("\(parentFolder)/\(filename)")
                        .bold()
                        .font(.caption)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.4))
                        )
                        .padding(.bottom, 10)
                }
            }
        }
        .onReceive(imageLoader.didChange) { data in
            image = data
        }
    }
}

//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView(withURL: URL(string:"")!, model: ImageBrowserModel())
//    }
//}
