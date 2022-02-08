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

    init(withURL url:URL, orientation:Binding<Image.Orientation>) {
        _orientation = orientation
        imageLoader.load(url:url)
    }

    var body: some View {
        VStack {
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                // NOTE: Without the orientation-specific Text label the orientation changes are not picked up
                Image(cgImage, scale: 1, orientation: orientation, label: Text(String(describing: orientation)))
                    .resizable()
                    .scaledToFit()
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
