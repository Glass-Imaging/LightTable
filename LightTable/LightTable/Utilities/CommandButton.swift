//
//  CommandButton.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI
import Combine

func CommandButton<M>(model: M?, label:String, key: KeyEquivalent, modifiers: EventModifiers = [], action: @escaping (_ model: M) -> Void) -> some View {
    return Button {
        if let model = model {
            action(model)
        }
    } label: {
        Text(label)
    }
    .keyboardShortcut(key, modifiers: modifiers)
    .disabled(model == nil)
}
