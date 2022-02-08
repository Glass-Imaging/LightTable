//
//  PaneDivider.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/4/22.
//

import SwiftUI

struct PaneDivider: View {
    var action: (_ offset: CGFloat) -> Void

    @GestureState private var isDragging = false // Will reset to false when dragging has ended

    let reallyDarkGray = Color(red: 11.0/255.0, green: 10.0/255.0, blue: 14.0/255.0)

    var body: some View {
        Rectangle()
            .frame(height:1).foregroundColor(reallyDarkGray)
            .onHover { inside in
                if !isDragging {
                    if inside { NSCursor.resizeUpDown.push() }
                    else {  NSCursor.pop() }
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
                    .onEnded { _ in NSCursor.pop() }
            )
    }
}