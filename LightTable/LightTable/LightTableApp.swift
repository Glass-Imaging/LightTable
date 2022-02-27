//
//  LightTableApp.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/1/22.
//

import SwiftUI

@main
struct LightTableApp: App {
    var body: some Scene {
        WindowGroup {
            LightTableView()
        }
        .commands {
            LightTableView.ContentCommands()

            ImageBrowserView.BrowserCommands()
        }
    }
}
