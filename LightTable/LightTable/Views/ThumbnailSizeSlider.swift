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

struct ThumbnailSizeSlider: View {
    @Binding var value:CGFloat

    private let thumbRadius: CGFloat = 15

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .font(Font.system(size: 12))

            CustomSlider(value: $value,
                         in: 50...200,
                         track: {
                Capsule()
                    .foregroundColor(Color.gray)
                    .frame(width: 150, height: 3)
            }, fill: {
                Capsule()
                    .foregroundColor(.blue)
            }, thumb: {
                Circle()
                    .foregroundColor(.white)
                    .shadow(radius: thumbRadius / 1)
            }, thumbSize: CGSize(width: thumbRadius, height: thumbRadius))

            Image(systemName: "person.fill")
                .font(Font.system(size: 18))
        }
    }
}
