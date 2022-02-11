//
//  ScrollViewOffsetModifier.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/8/22.
//

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

