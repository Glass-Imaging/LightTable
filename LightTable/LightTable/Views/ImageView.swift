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
    @State var image:NSImage = NSImage()
    
    init(withURL url:URL) {
        imageLoader.load(url:url)
    }
    
    var body: some View {
        VStack {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .onReceive(imageLoader.didChange) { data in
            self.image = data
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(withURL: URL(string:"")!)
    }
}
