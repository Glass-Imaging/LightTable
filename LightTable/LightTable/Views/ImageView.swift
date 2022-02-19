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
    @ObservedObject var model:ImageBrowserModel
    let url:URL
    let index:Int

    @ObservedObject var imageLoader = ImageLoader()
    @State var cgImageWithMetadata:CGImageWithMetadata? = nil

    @State var viewOffsetInteractive = CGPoint.zero

    @State var showLoading = false

    static var offsetMap: [URL : CGPoint] = [:]

    func storedOffset(url: URL) -> CGPoint {
        if let storedOffset = ImageView.offsetMap[url] {
            return storedOffset
        }
        return CGPoint.zero
    }

    init(url:URL, model:ImageBrowserModel, index:Int) {
        self.url = url
        self.model = model
        self.index = index

        imageLoader.load(url:url)
    }

    func viewOrientation() -> Image.Orientation {
        let baseOrientation:Image.Orientation

        if let cgImageWithMetadata = cgImageWithMetadata {
            let metadata = cgImageWithMetadata.metadata
            let imageURL = cgImageWithMetadata.url

            if model.useMasterOrientation {
                // ImageView objects are being recycled by the container, see if this one is up to date
                if (url == imageURL && index == 0) {
                    baseOrientation = imageOrientation(metadata: metadata)
                    if model.masterOrientation != baseOrientation {
                        DispatchQueue.main.async {
                            model.masterOrientation = baseOrientation
                        }
                    }
                } else {
                    baseOrientation = model.masterOrientation
                }
            } else {
                baseOrientation = imageOrientation(metadata: metadata)
            }
        } else {
            baseOrientation = .up
        }
        return rotate(value: baseOrientation, by: model.orientation)
    }

    var body: some View {
        GeometryReader { geometry in
            let geometryFrameSize = geometry.frame(in: .global).size

            ScrollView([]) {
                if let cgImageWithMetadata = cgImageWithMetadata {
                    let cgImage = cgImageWithMetadata.image
                    let metadata = cgImageWithMetadata.metadata

                    let orientation = viewOrientation()

                    var viewOffset = storedOffset(url: url)

                    let scale = model.viewScaleFactor

                    let swapDimensions = [.left, .right].contains(orientation)
                    let imageSize = swapDimensions ? CGSize(width: cgImage.height, height: cgImage.width) : CGSize(width: cgImage.width, height: cgImage.height)
                    let frameSize = scale == 0 ? geometryFrameSize : imageSize * scale

                    let viewPortOffset = (imageSize * scale - geometryFrameSize) / 2

                    let offset = scale == 0
                               ? CGPoint.zero
                               : model.viewOffset * scale + model.viewOffsetInteractive + viewOffset + viewOffsetInteractive - viewPortOffset

                    VStack {
                        Image(cgImage, scale: 1, orientation: orientation, label: Text(String(describing: orientation)))
                                .interpolation(scale == 0 ? .high : .none)
                                .antialiased(scale == 0 ? true : false)
                                .resizable()
                                .scaledToFit()
                                .overlay(alignment: .bottom) {
                                    ImageViewCaption(url: url, metadata: metadata, model: model)
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
                } else {
                    VStack {
                        if showLoading {
                            Text("Loading Image...")
                        }
                    }
                    .frame(width: geometryFrameSize.width, height: geometryFrameSize.height, alignment: .center)
                    .onAppear {
                        withAnimation {
                            showLoading = true
                        }
                    }
                }
            }
        }
        .onReceive(imageLoader.didChange) { cgImageWithMetadata in
            print("new data")
            self.cgImageWithMetadata = cgImageWithMetadata
        }
    }
}

//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView(withURL: URL(string:"")!, model: ImageBrowserModel())
//    }
//}
