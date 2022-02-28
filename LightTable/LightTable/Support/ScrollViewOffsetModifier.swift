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

// Preference key keeping track of the scroller position
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGPoint
    static var defaultValue = CGPoint.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let next = nextValue()
        value.x += next.x
        value.y += next.y
    }
}

struct ScrollViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding var offset:CGPoint

    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                let origin = proxy.frame(in: .named("scroll")).origin
                Color.clear.preference(key: ViewOffsetKey.self, value: CGPoint(x: -origin.x, y: -origin.y))
            }
        }
        .onPreferenceChange(ViewOffsetKey.self) { value in
            DispatchQueue.main.async {
                offset = value
            }
        }
    }
}

extension View {
    func readingScrollView(from coordinateSpace: String, into binding: Binding<CGPoint>) -> some View {
        modifier(ScrollViewOffsetModifier(coordinateSpace: coordinateSpace, offset: binding))
    }
}

