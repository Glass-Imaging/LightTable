//
//  LightTableApp.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI
import Combine

@main
struct LightTableApp: App {

    private let keyInputSubject = KeyInputSubjectWrapper()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(keyInputSubject)
        }
        .commands {
            CommandMenu("Input") {
                keyInput(.leftArrow)
                keyInput(.rightArrow)
            }
        }
    }
}

private extension LightTableApp {
    func keyInput(_ key: KeyEquivalent, modifiers: EventModifiers = .none) -> some View {
        keyboardShortcut(key, sender: keyInputSubject, modifiers: modifiers)
    }
}
