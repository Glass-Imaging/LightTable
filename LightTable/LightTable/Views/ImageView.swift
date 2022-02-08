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
    @Binding var orientation:Image.Orientation
    @State var image:NSImage = NSImage()

    func orientationToDegrees(orientation:Image.Orientation) -> CGFloat {
        switch orientation {
        case Image.Orientation.up:
            return 0
        case Image.Orientation.right:
            return 90
        case Image.Orientation.down:
            return 180
        case Image.Orientation.left:
            return 270
        default:
            return 0
        }
    }

    func orientationToScale(orientation:Image.Orientation) -> CGFloat {
        if (image.isValid && (orientation == Image.Orientation.right || orientation == Image.Orientation.left)) {
            return image.size.height / image.size.width
        }
        return 1.0
    }

    init(withURL url:URL, orientation:Binding<Image.Orientation>) {
        _orientation = orientation
        imageLoader.load(url:url)
    }

    var body: some View {
        VStack {
            if let cgImage = image.CGImage {
                Image(cgImage, scale: 1, orientation: orientation, label: Text(""))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .onReceive(imageLoader.didChange) { data in
            image = data
        }
    }
}

//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView(withURL: URL(string:"")!, orientation: .up)
//    }
//}

extension NSImage {
    @objc var CGImage: CGImage? {
       get {
            guard let imageData = self.tiffRepresentation else { return nil }
            guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
       }
    }
}
