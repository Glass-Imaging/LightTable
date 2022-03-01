// Copyright (c) 2022 Glass Imaging Inc.
// Author: Fabio Riccardi <fabio@glass-imaging.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    @ObservedObject var viewState:ImageViewState

    @ObservedObject var imageLoader = ImageLoader()
    @State var viewOffsetInteractive = CGPoint.zero
    static var offsetMap: [URL : CGPoint] = [:]

    init(url:URL, fileIndex:(Int, Int), index:Int, imageViewModel:Binding<ImageViewModel>, viewState:ImageViewState) {
        self.url = url
        self.fileIndex = fileIndex
        self.index = index
        self._imageViewModel = imageViewModel
        self.viewState = viewState

        imageLoader.loadImage(url:url)
    }

    func viewOrientation(imageWithMetadata:ImageWithMetadata) -> Image.Orientation {
        let metadata = imageWithMetadata.metadata
        let imageURL = imageWithMetadata.url

        let baseOrientation:Image.Orientation
        if viewState.useMasterOrientation {
            // ImageView objects are being recycled by the container, see if this one is up to date
            if (url == imageURL && index == 0) {
                baseOrientation = imageOrientation(metadata: metadata)
                if viewState.masterOrientation != baseOrientation {
                    DispatchQueue.main.async {
                        imageViewModel.setMasterOrientation(orientation: baseOrientation)
                    }
                }
            } else {
                baseOrientation = viewState.masterOrientation
            }
        } else {
            baseOrientation = imageOrientation(metadata: metadata)
        }
        return rotate(value: baseOrientation, by: viewState.orientation)
    }

    func imageSize(image: CGImage, orientation: Image.Orientation) -> CGSize {
        let swapDimensions = [.left, .right].contains(orientation)
        return swapDimensions ? CGSize(width: image.height, height: image.width) : CGSize(width: image.width, height: image.height)
    }

    func imageOffset(scale: CGFloat, viewOffset: CGPoint, viewPortOffset: CGSize) -> CGPoint {
        return scale == 0
               ? CGPoint.zero
               : viewState.viewOffset * scale + viewState.viewOffsetInteractive + viewOffset + viewOffsetInteractive - viewPortOffset
    }

    var body: some View {
        VStack {
            // If the image is already cached by imageLoader the ProgressView will never show

            if let imageWithMetadata = imageLoader.imageWithMetadata {
                let scaleFactor = imageViewModel.viewScaleFactor
                let orientation = viewOrientation(imageWithMetadata: imageWithMetadata)
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
                                            viewState.viewOffsetInteractive = CGPoint(x: gesture.translation.width, y: gesture.translation.height)
                                        }
                                        .onEnded { value in
                                            viewState.viewOffset += viewState.viewOffsetInteractive / scaleFactor
                                            viewState.viewOffsetInteractive = CGPoint.zero
                                        }
                                )
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    ImageViewCaption(url: url, index: fileIndex, metadata: imageWithMetadata.metadata, viewInfoItems: $imageViewModel.viewInfoItems)
                }
            } else {
                ProgressView("Loading Image...")
            }
        }
    }
}
