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

struct ThumbnailButtonView: View {
    let file:URL
    @Binding var selection:[URL]
    @Binding var thumbnailSize:CGFloat
    let action: (_ modifiers: EventModifiers) -> Void

    @Environment(\.controlActiveState) var windowState: ControlActiveState

    var body: some View {
        Button(action: {
            // Single Click
            action([])
        }) {
            let selected = selection.contains(file)

            VStack {
                ThumbnailView(withURL: file)
                    .border(selected ? (windowState == .inactive ? Color.gray : Color.accentColor) : Color.clear, width: 2)
                Text(file.lastPathComponent)
                    .lineLimit(1)
                    .font(.caption)
                    .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                    .background(selected ? (windowState == .inactive ? Color.gray : Color.accentColor) : nil)
                    .cornerRadius(3)
                    .frame(width: thumbnailSize, height: 20)
            }
            .frame(width: thumbnailSize, height: thumbnailSize + 20)
            // Double Click: reveal the file in Finder
            .gesture(TapGesture(count: 2).onEnded {
                action([])
                NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: "")
            })
            // Command-Click Multiple Selection
            .gesture(TapGesture().modifiers(.command).onEnded {
                action(.command)
            })
        }
        .buttonStyle(PlainButtonStyle())
    }
}
