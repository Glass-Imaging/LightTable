//
//  ImageView.swift
//  LightTable
//
//  Created by Gualtiero Frigerio on 03/02/2021.
//

import Combine
import SwiftUI

struct ImageViewLabel: View {
    let url:URL

    var body: some View {
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

struct ImageView: View {
    @ObservedObject var imageLoader = ImageLoader()
    @State var image:NSImage = NSImage()
    let url:URL

    @ObservedObject var model:ImageBrowserModel

    @State private var scrollViewOffset = CGPoint.zero

    init(withURL url:URL, model:ImageBrowserModel) {
        self.model = model
        self.url = url
        imageLoader.load(url:url)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                let viewFrame = geometry.frame(in: .global)
                let imageSize = (model.orientation == .up || model.orientation == .down) ? image.size : CGSize(width: image.size.height, height: image.size.width)
                let scaleRatio = 1 / min(viewFrame.width / imageSize.width, viewFrame.height / imageSize.height)
                let scale = model.viewScaleFactor == 0 ? 1 : scaleRatio * model.viewScaleFactor

                ZStack {
                    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                        // NOTE: Without the orientation-specific Text label the orientation changes are not picked up
                        Image(cgImage, scale: 1, orientation: model.orientation, label: Text(String(describing: model.orientation)))
                            .interpolation(scale > 1.0 ? .none : .high)
                            .antialiased(scale > 1.0 ? false : true)
                            .resizable()
                            .scaledToFit()
                    }

                    if image.isValid {
                        ImageViewLabel(url: url)
                    }
                }
                .frame(width: geometry.size.width * scale,
                       height: geometry.size.height * scale, alignment: .center)
                .readingScrollView(from: "ScalableImageViewScroll", into: $scrollViewOffset)
                .onChange(of: scrollViewOffset) { offset in
                    if (image.isValid) {
                        print("scrollViewOffset: ", scrollViewOffset)
                    }
                }
            }
            .coordinateSpace(name: "ScalableImageViewScroll")
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
