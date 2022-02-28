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

extension FocusedValues {
    var focusedBrowserModel: Binding<ImageBrowserModel>? {
        get { self[FocusedImageBrowserModelKey.self] }
        set { self[FocusedImageBrowserModelKey.self] = newValue }
    }

    private struct FocusedImageBrowserModelKey: FocusedValueKey {
        typealias Value = Binding<ImageBrowserModel>
    }

    var focusedViewModel: Binding<ImageViewModel>? {
        get { self[FocusedImageViewModelKey.self] }
        set { self[FocusedImageViewModelKey.self] = newValue }
    }

    private struct FocusedImageViewModelKey: FocusedValueKey {
        typealias Value = Binding<ImageViewModel>
    }

    var focusedNavigatorModel: Binding<NavigatorModel>? {
        get { self[FocusedNavigatorModelKey.self] }
        set { self[FocusedNavigatorModelKey.self] = newValue }
    }

    private struct FocusedNavigatorModelKey: FocusedValueKey {
        typealias Value = Binding<NavigatorModel>
    }
}
