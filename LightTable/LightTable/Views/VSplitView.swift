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

public struct SlideableDivider: View {
    @Binding var dimension: Double
    @State private var dimensionStart: CGFloat?

    public init(dimension: Binding<Double>) {
        self._dimension = dimension
    }

    public var body: some View {
        Rectangle()
            .foregroundColor(Color.black)
            .frame(height: 2)
            .onHover { inside in
                if inside {
                    NSCursor.resizeUpDown.push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(drag)
    }

    var drag: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: CoordinateSpace.global)
            .onChanged { val in
                if dimensionStart == nil {
                    dimensionStart = dimension
                }
                let delta = val.location.y - val.startLocation.y
                dimension = dimensionStart! + delta
            }
            .onEnded { val in
                dimensionStart = nil
            }
    }
}

struct VSplitView<FirstView: View, SecondView: View>: View {
    let minSize:CGFloat
    let firstView:FirstView
    let secondView:SecondView

    @AppStorage("ImageBrowserView.dividerOffset") private var dividerOffset = 0.0

    init(minSize: CGFloat, @ViewBuilder first: @escaping () -> FirstView, @ViewBuilder second: @escaping () -> SecondView) {
        self.minSize = minSize
        self.firstView = first()
        self.secondView = second()
    }

    func clamp(_ value: CGFloat, to: CGFloat) -> CGFloat {
        return min(max(value, -to/2 + minSize), to/2 - minSize)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                firstView

                SlideableDivider(dimension: $dividerOffset)

                secondView
                    .frame(height: max(geometry.size.height/2 - dividerOffset, 0))
            }
            .onChange(of: dividerOffset) { _ in
                dividerOffset = clamp(dividerOffset, to: geometry.size.height)
            }
            .onChange(of: geometry.size, perform: { [oldSize = geometry.size] newSize in
                if let window = NSApplication.shared.windows.last {
                    if window.inLiveResize || window.isZoomed {
                        // Maintain the bottom pane height constant when the view size changes
                        dividerOffset = dividerOffset + (newSize.height - oldSize.height) / 2
                    }
                }
            })
        }
    }
}
