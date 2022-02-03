//
//  FocusedValues+LightTable.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/3/22.
//

import SwiftUI

extension FocusedValues {
    var focusedBrowserModel: Binding<ImageBrowserModel>? {
        get { self[FocusedImageBrowserModelKey.self] }
        set { self[FocusedImageBrowserModelKey.self] = newValue }
    }

    private struct FocusedImageBrowserModelKey: FocusedValueKey {
        typealias Value = Binding<ImageBrowserModel>
    }

    var focusedNavigatorModel: Binding<NavigatorModel>? {
        get { self[FocusedNavigatorModelKey.self] }
        set { self[FocusedNavigatorModelKey.self] = newValue }
    }

    private struct FocusedNavigatorModelKey: FocusedValueKey {
        typealias Value = Binding<NavigatorModel>
    }
}
