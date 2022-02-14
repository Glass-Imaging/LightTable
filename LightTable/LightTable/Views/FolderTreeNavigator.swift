//
//  FolderTreeNavigator.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/10/22.
//

import SwiftUI

struct FolderTreeNavigator: View {
    @StateObject var imageBrowserModel:ImageBrowserModel
    @StateObject var navigatorModel:NavigatorModel

    @FocusState private var navigatorIsFocused: Bool

    var body: some View {
        if (navigatorModel.children.count == 0) {
            Text("Drop a folder here.")
        } else {
            let selectionBinding = Binding<Set<URL>>(
                get: { navigatorModel.multiSelection },
                set: { val in navigatorModel.multiSelection = val }
            )

            VStack(alignment: .leading) {
                FolderTreeHeader(navigatorModel: navigatorModel)
                    .padding(EdgeInsets(top: 10, leading: 5, bottom: 5, trailing: 5))

                Divider()

                List(navigatorModel.children, id:\.self, selection: selectionBinding) { folder in
                    FolderTreeDisclosure(url: folder, selection: selectionBinding, doubleTapAction:{ url in
                        navigatorModel.update(url: url)
                    })
                }
                .focused($navigatorIsFocused)
                .onAppear {
                    navigatorIsFocused = true
                }
            }
        }
    }
}
