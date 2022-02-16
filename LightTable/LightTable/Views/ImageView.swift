//
//  ImageView.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/31/22.
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
            return storedOffset
        }
        return CGPoint.zero
    }

    init(url:URL, model:ImageBrowserModel) {
        self.model = model
        self.url = url
        imageLoader.load(url:url)
    }

    func orientationToAngle(orientation: Image.Orientation) -> Angle {
        switch orientation {
        case .right:
            return Angle.degrees(90)
        case .down:
            return Angle.degrees(180)
        case .left:
            return Angle.degrees(270)
        default:
            return Angle.degrees(0)
        }
    }

    func prepareImage(downScale: Bool) -> AnyView {
        if image.isValid {
            // NSImage sometimes changes the image size to take into account the ppi from metadata, override with NSImageRep
            let rep = image.representations[0]
            let repSize = CGSize(width: rep.pixelsWide, height: rep.pixelsHigh)
            if (image.size != repSize) {
                image.size = repSize
            }
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                return AnyView(
                    // NOTE: Without the orientation-specific Text label the orientation changes are not picked up
                    Image(cgImage, scale: 1, orientation: model.orientation, label: Text(String(describing: model.orientation)))
                        .interpolation(downScale ? .high : .none)
                        .antialiased(downScale ? true : false)
                        .resizable()
                        .scaledToFit()
                        .overlay(alignment: .bottom) {
                            ImageViewCaption(url: url)
                        }
                )
            }
        }
        return AnyView(EmptyView())
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView([]) {
                var viewOffset = storedOffset(url: url)

                let scale = model.viewScaleFactor
                let swapDimensions = model.orientation == .left || model.orientation == .right
                let imageSize = swapDimensions ? CGSize(width: image.size.height, height: image.size.width) : image.size
                let frameSize = scale == 0 ? geometry.size : imageSize * scale

                let offset = scale == 0
                           ? CGPoint.zero
                           : model.viewOffset * scale + model.viewOffsetInteractive + viewOffset + viewOffsetInteractive

                VStack {
                    prepareImage(downScale: scale == 0)
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
            image = data
        }
    }
}

//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView(withURL: URL(string:"")!, model: ImageBrowserModel())
//    }
//}
