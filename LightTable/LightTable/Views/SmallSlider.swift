//
//  SmallSlider.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/14/22.
//

import SwiftUI

struct SmallSlider: View {
  private let thumbRadius: CGFloat = 15
  @State private var value = 100.0

  var body: some View {
    // Text("Custom slider: \(value)")
    CustomSlider(value: $value,
                 in: 50...200,
                 minimumValueLabel: Text("􀉪").font(.system(size: 12)),
                 maximumValueLabel: Text("􀉪").font(.system(size: 18)),
                 onEditingChanged: { started in
               print("started custom slider: \(started)")
    }, track: {
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
  }
}
