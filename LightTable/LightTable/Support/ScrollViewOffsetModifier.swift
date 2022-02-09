//
//  ScrollViewOffsetModifier.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/8/22.
//

import SwiftUI

// Preference key keeping track of the scroller position
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ScrollViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding var offset:CGFloat

    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                Color.clear.preference(key: ViewOffsetKey.self, value: -proxy.frame(in: .named("scroll")).origin.x)
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
    func readingScrollView(from coordinateSpace: String, into binding: Binding<CGFloat>) -> some View {
        modifier(ScrollViewOffsetModifier(coordinateSpace: coordinateSpace, offset: binding))
    }
}

