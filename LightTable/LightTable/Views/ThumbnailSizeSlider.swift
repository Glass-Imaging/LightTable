//
//  SmallSlider.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/14/22.
//

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
