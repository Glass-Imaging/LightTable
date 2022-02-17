//
//  ImageView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
//

import Combine
import SwiftUI

struct ImageViewCaption: View {
    let url: URL
    let metadata: NSDictionary
    @ObservedObject var model:ImageBrowserModel

    func imageMetadata() -> String {
        if let pixelWidth = metadata["PixelWidth"] as? Int {
            if let pixelHeight = metadata["PixelHeight"] as? Int {
                return "\(pixelWidth)w \(pixelHeight)h"
            }
        }
        return "--"
    }

    var body: some View {
        let parentFolder = parentFolder(url:url).lastPathComponent
        let filename = url.lastPathComponent
        let index = model.fileIndex(file: url)

        if model.viewInfoItems > 0 {
            VStack(spacing: 1) {
                Text("\(filename) (\(index.0)/\(index.1))")
                    .bold()
                    .font(.subheadline)

                if model.viewInfoItems > 1 {
                    Divider()
                        .frame(width: 150)

                    Text(parentFolder)
                        .font(.caption)

                    if model.viewInfoItems > 2 {
                        Divider()
                            .frame(width: 150)

                        Text(imageMetadata())
                            .font(.caption)
                    }
                }
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.3))
            )
            .padding(.bottom, 5)
        }
    }
}

struct ImageView: View {
    let url:URL
    @ObservedObject var model:ImageBrowserModel

    @ObservedObject var imageLoader = ImageLoader()
    @State var nsImage:NSImage = NSImage()
    @State var metadata:NSDictionary = NSDictionary()

    @State var viewOffsetInteractive = CGPoint.zero

    static var offsetMap: [URL : CGPoint] = [:]

    func storedOffset(url: URL) -> CGPoint {
        if let storedOffset = ImageView.offsetMap[url] {
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
                let swapDimensions = model.orientation == .left || model.orientation == .right
                let imageSize = swapDimensions ? CGSize(width: nsImage.size.height, height: nsImage.size.width) : nsImage.size
                let frameSize = scale == 0 ? geometry.size : imageSize * scale

                let offset = scale == 0
                           ? CGPoint.zero
                           : model.viewOffset * scale + model.viewOffsetInteractive + viewOffset + viewOffsetInteractive

                VStack {
                    if let image = Image(nsImage: nsImage, metadata: metadata, orientation: model.orientation, downScale: scale == 0) {
                        image
                            .scaledToFit()
                            .overlay(alignment: .bottom) {
                                ImageViewCaption(url: url, metadata: metadata, model: model)
                            }
                    }
                }
                .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
                .offset(x: offset.x, y: offset.y)
                .gesture(
                    // Option-Click-Drag for individual image offset, made persistent in ImageView.offsetMap
                    DragGesture().modifiers(.option)
                        .onChanged { gesture in
                            if (scale > 0) {
                                viewOffsetInteractive = CGPoint(x: gesture.translation.width, y: gesture.translation.height)
                            }
                        }
                        .onEnded { value in
                            if (scale > 0) {
                                viewOffset += viewOffsetInteractive / scale
                                viewOffsetInteractive = CGPoint.zero

                                // Make viewOffset persistent
                                ImageView.offsetMap[url] = viewOffset
                            }
                        }
                )
                .gesture(
                    // Click-Drag for global image offset
                    DragGesture()
                        .onChanged { gesture in
                            if (scale > 0) {
                                model.viewOffsetInteractive = CGPoint(x: gesture.translation.width, y: gesture.translation.height)
                            }
                        }
                        .onEnded { value in
                            if (scale > 0) {
                                model.viewOffset += model.viewOffsetInteractive / scale
                                model.viewOffsetInteractive = CGPoint.zero
                            }
                        }
                )
            }
        }
        .onReceive(imageLoader.didChange) { data in
            if !data.isEmpty {
                if let nsImage = NSImage(nsData: data) {
                    self.nsImage = nsImage
                    metadata = NSImageMetadata(nsData: data)
                }
            }
        }
    }
}

//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView(withURL: URL(string:"")!, model: ImageBrowserModel())
//    }
//}
