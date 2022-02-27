//
//  ImageViewCaption.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/26/22.
//

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
