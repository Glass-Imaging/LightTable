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
    let index: (Int, Int)
    let metadata: NSDictionary?
    @Binding var viewInfoItems:Int

    func imageMetadata() -> String {
        if let pixelWidth = metadata?["PixelWidth"] as? Int {
            if let pixelHeight = metadata?["PixelHeight"] as? Int {
                return "\(pixelWidth)w \(pixelHeight)h"
            }
        }
        return "--"
    }

    var body: some View {
        let parentFolder = parentFolder(url:url).lastPathComponent
        let filename = url.lastPathComponent

        if viewInfoItems > 0 {
            VStack(spacing: 1) {
                Text("\(filename) (\(index.0)/\(index.1))")
                    .bold()
                    .font(.subheadline)

                if viewInfoItems > 1 {
                    Divider()
                        .frame(width: 150)

                    Text(parentFolder)
                        .font(.caption)

                    if viewInfoItems > 2 {
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

struct OrientedImage: View {
    let cgImage:CGImage
    let orientation:Image.Orientation
    let scaledToFit:Bool

    var body: some View {
        Image(cgImage, scale: 3, orientation: orientation, label: Text(String(describing: orientation)))
            .interpolation(scaledToFit ? .high : .none)
            .antialiased(scaledToFit ? true : false)
            .resizable()
            .scaledToFit()
    }
}

struct ImageView: View {
    let url:URL
    let fileIndex:(Int, Int)
    let index:Int
    @Binding var imageViewModel:ImageViewModel

    @ObservedObject var imageLoader = ImageLoader()
    @State var cgImageWithMetadata:CGImageWithMetadata? = nil
    @State var viewOffsetInteractive = CGPoint.zero
    static var offsetMap: [URL : CGPoint] = [:]

    init(url:URL, fileIndex:(Int, Int), index:Int, imageViewModel:Binding<ImageViewModel>) {
        self.url = url
        self.fileIndex = fileIndex
        self.index = index
        self._imageViewModel = imageViewModel

        imageLoader.load(url:url)
    }

    func viewOrientation() -> Image.Orientation {
        let baseOrientation:Image.Orientation

        if let cgImageWithMetadata = cgImageWithMetadata {
            let metadata = cgImageWithMetadata.metadata
            let imageURL = cgImageWithMetadata.url

            if imageViewModel.useMasterOrientation {
                // ImageView objects are being recycled by the container, see if this one is up to date
                if (url == imageURL && index == 0) {
                    baseOrientation = imageOrientation(metadata: metadata)
                    if imageViewModel.masterOrientation != baseOrientation {
                        DispatchQueue.main.async {
                            imageViewModel.setMasterOrientation(orientation: baseOrientation)
                        }
                    }
                } else {
                    baseOrientation = imageViewModel.masterOrientation
                }
            } else {
                baseOrientation = imageOrientation(metadata: metadata)
            }
        } else {
            baseOrientation = .up
        }
        return rotate(value: baseOrientation, by: imageViewModel.orientation)
    }

    func imageSize(image: CGImage, orientation: Image.Orientation) -> CGSize {
        let swapDimensions = [.left, .right].contains(orientation)
        return swapDimensions ? CGSize(width: image.height, height: image.width) : CGSize(width: image.width, height: image.height)
    }

    func imageOffset(scale: CGFloat, viewOffset: CGPoint, viewPortOffset: CGSize) -> CGPoint {
        return scale == 0
               ? CGPoint.zero
               : imageViewModel.viewOffset * scale + imageViewModel.viewOffsetInteractive + viewOffset + viewOffsetInteractive - viewPortOffset
    }

    var body: some View {
        VStack {
            if let cgImageWithMetadata = cgImageWithMetadata {
                let scaleFactor = imageViewModel.viewScaleFactor
                let orientation = viewOrientation()
                let cgImage = cgImageWithMetadata.image

                GeometryReader { geometry in
                    let geometryFrameSize = geometry.frame(in: .global).size
                    ScrollView([]) {
                        if (scaleFactor == 0) {
                            OrientedImage(cgImage: cgImage, orientation: orientation, scaledToFit: true)
                                .frame(width: geometryFrameSize.width, height: geometryFrameSize.height, alignment: .center)
                        } else {
                            let imageSize = imageSize(image: cgImage, orientation: orientation)
                            let frameSize = imageSize * scaleFactor
                            var viewOffset = ImageView.offsetMap[url] ?? CGPoint.zero
                            let imageOffset = imageOffset(scale: scaleFactor,
                                                          viewOffset: viewOffset,
                                                          viewPortOffset: (imageSize * scaleFactor - geometryFrameSize) / 2)

                            OrientedImage(cgImage: cgImage, orientation: orientation, scaledToFit: false)
                                .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
                                .offset(x: imageOffset.x, y: imageOffset.y)
                                .gesture(
                                    // Option-Click-Drag for individual image offset, made persistent in ImageView.offsetMap
                                    DragGesture().modifiers(.option)
                                        .onChanged { gesture in
                                            viewOffsetInteractive = CGPoint(x: gesture.translation.width, y: gesture.translation.height)
                                        }
                                        .onEnded { value in
                                            viewOffset += viewOffsetInteractive / scaleFactor
                                            viewOffsetInteractive = CGPoint.zero

                                            // Make viewOffset persistent
                                            ImageView.offsetMap[url] = viewOffset
                                        }
                                )
                                .gesture(
                                    // Click-Drag for global image offset
                                    DragGesture()
                                        .onChanged { gesture in
                                            imageViewModel.viewOffsetInteractive = CGPoint(x: gesture.translation.width, y: gesture.translation.height)
                                        }
                                        .onEnded { value in
                                            imageViewModel.viewOffset += imageViewModel.viewOffsetInteractive / scaleFactor
                                            imageViewModel.viewOffsetInteractive = CGPoint.zero
                                        }
                                )
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let cgImageWithMetadata = cgImageWithMetadata {
                ImageViewCaption(url: url, index: fileIndex, metadata: cgImageWithMetadata.metadata, viewInfoItems: $imageViewModel.viewInfoItems)
            }
        }
        .onReceive(imageLoader.didChange) { cgImageWithMetadata in
            self.cgImageWithMetadata = cgImageWithMetadata
        }
    }
}
