//
//  ImageView.swift
//  LightTable
//
//  Created by Gualtiero Frigerio on 03/02/2021.
//

import Combine
import SwiftUI

struct ImageViewCaption: View {
    let url:URL

    var body: some View {
        VStack() {
            Spacer()
            let parentFolder = parentFolder(url:url).lastPathComponent
            let filename = url.lastPathComponent
            VStack {
                Text(filename)
                    .bold()
                Text(parentFolder)
                    .font(.caption)
            }
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
    let url:URL
    @ObservedObject var model:ImageBrowserModel

    @ObservedObject var imageLoader = ImageLoader()
    @State var image:NSImage = NSImage()

    @State var viewOffsetInteractive = CGPoint.zero

    static var offsetMap: [URL : CGPoint] = [:]

    func storedOffset(url: URL) -> CGPoint {
        if let storedOffset = ImageView.offsetMap[url] {
            print("found stored offset", storedOffset)
            return storedOffset
        }
        return CGPoint.zero
    }

    init(url:URL, model:ImageBrowserModel) {
        self.model = model
        self.url = url
        imageLoader.load(url:url)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView([]) {
                var viewOffset = storedOffset(url: url)

                let scale = model.viewScaleFactor
                let viewFrame = geometry.frame(in: .local)
                let imageSize = (model.orientation == .up || model.orientation == .down)
                                ? image.size
                                : CGSize(width: image.size.height, height: image.size.width)
                let scaleRatio = 1 / min(viewFrame.width / imageSize.width,
                                         viewFrame.height / imageSize.height)
                let imageScale = scale == 0 ? 1 : scaleRatio * scale

                let frameSize = scale == 0
                                ? geometry.size
                                : CGSize(width: scale * image.size.width,
                                         height: scale * image.size.height);

                VStack {
                    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                        // NOTE: Without the orientation-specific Text label the orientation changes are not picked up
                        Image(cgImage, scale: 1, orientation: model.orientation, label: Text(String(describing: model.orientation)))
                            .interpolation(imageScale > 1.0 ? .none : .high)
                            .antialiased(imageScale > 1.0 ? false : true)
                            .resizable()
                            .scaledToFit()
                            .overlay(ImageViewCaption(url: url))
                    }
                }
                .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
                .offset(x: scale == 0 ? 0 : scale * model.viewOffset.x + model.viewOffsetInteractive.x + viewOffset.x + viewOffsetInteractive.x,
                        y: scale == 0 ? 0 : scale * model.viewOffset.y + model.viewOffsetInteractive.y + viewOffset.y + viewOffsetInteractive.y)
                .gesture(
                    DragGesture().modifiers(.option)
                        .onChanged { gesture in
                            if (scale > 0) {
                                print("onChanged - viewOffset", viewOffset)

                                viewOffsetInteractive = CGPoint(x: gesture.translation.width, y: gesture.translation.height)
                            }
                        }
                        .onEnded { value in
                            if (scale > 0) {
                                print("onEnded - viewOffset", viewOffset)

                                viewOffset.x += viewOffsetInteractive.x / scale
                                viewOffset.y += viewOffsetInteractive.y / scale
                                viewOffsetInteractive = CGPoint.zero

                                ImageView.offsetMap[url] = viewOffset
                            }
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if (scale > 0) {
                                model.viewOffsetInteractive = CGPoint(x: gesture.translation.width, y: gesture.translation.height)
                            }
                        }
                        .onEnded { value in
                            if (scale > 0) {
                                model.viewOffset.x += model.viewOffsetInteractive.x / scale
                                model.viewOffset.y += model.viewOffsetInteractive.y / scale
                                model.viewOffsetInteractive = CGPoint.zero
                            }
                        }
                )
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
