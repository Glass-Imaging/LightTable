// Copyright (c) 2022 Glass Imaging Inc.
// Author: Fabio Riccardi <fabio@glass-imaging.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

@main
struct LightTableApp: App {
    // AppDelegate available as @EnvironmentObject to the rest of the app
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            LightTableView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            LightTableView.BrowserCommands()

            ImageBrowserView.BrowserCommands()

            ToolbarCommands()

            SidebarCommands()
        }

    }
}

// AppDelegate to keep track of fullScreen state
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var fullScreen = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(fullScreenHandler(notification:)),
                                               name: NSWindow.willEnterFullScreenNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fullScreenHandler(notification:)),
                                               name: NSWindow.willExitFullScreenNotification,
                                               object: nil)
    }

    @objc func fullScreenHandler(notification: Notification) {
        fullScreen = notification.name == NSWindow.willEnterFullScreenNotification
    }
}
