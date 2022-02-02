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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            ImageBrowser.BrowserCommands()
        }
    }
}
