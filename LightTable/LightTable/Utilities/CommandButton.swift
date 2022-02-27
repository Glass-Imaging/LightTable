//
//  CommandButton.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI

func CommandButton(label:String, key: KeyEquivalent, modifiers: EventModifiers = [], action: @escaping () -> Void) -> some View {
    return Button {
        action()
    } label: {
        Text(label)
    }
    .keyboardShortcut(key, modifiers: modifiers)
}
