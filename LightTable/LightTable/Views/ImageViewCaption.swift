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
