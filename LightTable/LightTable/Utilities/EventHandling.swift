//
//  EventHandling.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI

struct KeyEventHandling: NSViewRepresentable {
    var keyAction:(_ c: Character) -> Void
    var modifiersAction:(_ c: NSEvent.ModifierFlags) -> Void

    class KeyView: NSView {
        var keyAction:(_ c: Character) -> Void = { c in }
        var modifiersAction:(_ flags: NSEvent.ModifierFlags) -> Void = { flags in }

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            guard let str = event.charactersIgnoringModifiers else {
                return
            }
            keyAction(str[str.index(str.startIndex, offsetBy: 0)])
        }

        override func flagsChanged(with event: NSEvent) {
            modifiersAction(event.modifierFlags)
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.keyAction = keyAction
        view.modifiersAction = modifiersAction
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) { }
}
