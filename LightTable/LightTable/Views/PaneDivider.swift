//
//  PaneDivider.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/4/22.
//

import SwiftUI

struct PaneDivider<Content> : View where Content : View {
    var action: (_ offset: CGFloat) -> Void
    var content: () -> Content

    @GestureState private var isDragging = false // Will reset to false when dragging has ended

    init(action: @escaping (_ offset: CGFloat) -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }

    var body: some View {
        VStack(content: content)
            .foregroundColor(Color.black)
            .onHover { inside in
                if !isDragging {
                    if inside { NSCursor.resizeUpDown.push() }
                    else { NSCursor.pop() }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        action(gesture.translation.height)
                    }
                    .updating($isDragging) { (value, state, transaction) in
                        // This is overridden, something else in the system is pushing the arrow cursor during the drag
                        if !state { NSCursor.resizeUpDown.push() }
                        state = true
                    }
                    .onEnded { _ in
                        NSCursor.pop()
                    }
            )
    }
}
