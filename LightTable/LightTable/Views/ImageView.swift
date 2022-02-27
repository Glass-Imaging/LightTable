//
//  ImageView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

//struct OrientedImage: View {
//    let image:CGImage
//    let orientation:Image.Orientation
//    let scaledToFit:Bool
//
//    var body: some View {
//        Image(image, scale: 1, orientation: orientation, label: Text(String(describing: orientation)))
//            .interpolation(scaledToFit ? .high : .none)
//            .antialiased(scaledToFit ? true : false)
//    }
//}

struct OrientedImage: View {
    let image:CGImage
    let orientation:Image.Orientation
    let scaledToFit:Bool

    var body: some View {
        Image(image, scale: 1, label: Text(""))
            .interpolation(scaledToFit ? .high : .none)
            .antialiased(scaledToFit ? true : false)
            .rotationEffect(orientationToAngle(orientation: orientation))
    }
}

struct ImageView: View {
    let url:URL
    let fileIndex:(Int, Int)
    let index:Int
    @Binding var imageViewModel:ImageViewModel

    @ObservedObject var imageLoader = ImageLoader()
    @State var imageWithMetadata:ImageWithMetadata? = nil
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

        if let imageWithMetadata = imageWithMetadata {
            let metadata = imageWithMetadata.metadata
            let imageURL = imageWithMetadata.url

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
            if let imageWithMetadata = imageWithMetadata {
                let scaleFactor = imageViewModel.viewScaleFactor
                let orientation = viewOrientation()
                let image = imageWithMetadata.image
                let imageSize = imageSize(image: image, orientation: orientation)

                GeometryReader { geometry in
                    let geometryFrameSize = geometry.frame(in: .global).size
                    ScrollView([]) {
                        let scale = min(geometryFrameSize.width / imageSize.width, geometryFrameSize.height / imageSize.height)

                        if (scaleFactor == 0) {
                            OrientedImage(image: image, orientation: orientation, scaledToFit: true)
                                .frame(width: geometryFrameSize.width, height: geometryFrameSize.height, alignment: .center)
                                .scaleEffect(x: scale, y: scale)
                        } else {
                            let frameSize = imageSize * scaleFactor
                            var viewOffset = ImageView.offsetMap[url] ?? CGPoint.zero
                            let imageOffset = imageOffset(scale: scaleFactor,
                                                          viewOffset: viewOffset,
                                                          viewPortOffset: (imageSize * scaleFactor - geometryFrameSize) / 2)

                            OrientedImage(image: image, orientation: orientation, scaledToFit: false)
                                .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
                                .scaleEffect(x: scaleFactor, y: scaleFactor)
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
            if let imageWithMetadata = imageWithMetadata {
                ImageViewCaption(url: url, index: fileIndex, metadata: imageWithMetadata.metadata, viewInfoItems: $imageViewModel.viewInfoItems)
            }
        }
        .onReceive(imageLoader.didChange) { imageWithMetadata in
            self.imageWithMetadata = imageWithMetadata
        }
    }
}
