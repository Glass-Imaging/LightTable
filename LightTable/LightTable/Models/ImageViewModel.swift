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

// ImegeView internal state. Held in a separate object from ImageViewModel,
// it can be passed through an @EnvironmentObject variable to all ImageView instances.
// Changes toImageViewState won't trigger a view tree refresh upstream of ImageView,
// preventing ImegeView thrashing on user interaction.

class ImageViewState: ObservableObject {
    @Published var viewOffset = CGPoint.zero
    @Published var viewOffsetInteractive = CGPoint.zero

    func resetInteractiveOffset() {
        viewOffset = CGPoint.zero
        viewOffsetInteractive = CGPoint.zero
    }

    @Published private(set) var orientation:Image.Orientation = .up

    func rotateLeft() {
        orientation = LightTable.rotateLeft(value: orientation)
    }

    func rotateRight() {
        orientation = LightTable.rotateRight(value: orientation)
    }

    @Published var useMasterOrientation = false

    @Published private(set) var masterOrientation:Image.Orientation = .up

    func setMasterOrientation(orientation:Image.Orientation) {
        masterOrientation = orientation
    }

    // View magnification factor: 0 -> scale to fit, 1x, 2x, 3x, ...
    @Published private(set) var viewScaleFactor:CGFloat = 0

    func zoomIn() {
        viewScaleFactor += 1
    }

    func zoomOut() {
        if (viewScaleFactor > 0) {
            viewScaleFactor -= 1
        }
    }

    func zoomToFit() {
        viewScaleFactor = 0
    }

    @Published /* private(set) */ var viewInfoItems:Int = 3

    func switchViewInfoItems() {
        viewInfoItems = viewInfoItems == 0 ? 3 : viewInfoItems - 1
    }

    @Published /* private(set) */ var showEXIFMetadata = false

    func copyState(from other:ImageViewState) {
        viewOffset = other.viewOffset
        viewOffsetInteractive = other.viewOffsetInteractive
        orientation = other.orientation
        masterOrientation = other.masterOrientation
        viewScaleFactor = other.viewScaleFactor
        viewInfoItems = other.viewInfoItems
    }
}

// ImageViewModel delegates most of the action to ImageViewState

class ImageViewModel: ObservableObject {
    // Multipe Image View layout (Horizontal/Vertical/Grid)
    @Published var imageViewLayout:ImageListLayout = .Horizontal

    func switchLayout() {
        switch (imageViewLayout) {
        case .Horizontal:
            imageViewLayout = .Vertical
        case .Vertical:
            imageViewLayout = .Grid
        case .Grid:
            imageViewLayout = .Horizontal
        }
    }

    // Single Image view selection for ImageListView
    @Published private(set) var imageViewSelection = -1

    func imageViewSelection(char:Character, selection:[URL]) {
        if (char >= "0" && char <= "9") {
            // Single image selection mode
            let zero = Character("0")
            let index = char == zero ? 9 : (char.wholeNumberValue! - zero.wholeNumberValue!) - 1;
            if (selection.count > 0 && selection.count > index) {
                imageViewSelection = index
            }
        } else if (KeyEquivalent(char) == "`") {
            // Exit single image selection mode
            imageViewSelection = -1
        }
    }

    func resetImageViewSelection() {
        imageViewSelection = -1
    }

    // Fullscreen view presentation
    @Published var fullScreen = false

    func toggleFullscreen() {
        fullScreen = !fullScreen
    }

    // Reference to the ImageListView object, allows ImageViewModel to delegate to ImageViewState
    let imageViewState = ImageViewState()

    func rotateLeft() {
        imageViewState.rotateLeft()
    }

    func rotateRight() {
        imageViewState.rotateRight()
    }

    func zoomIn() {
        imageViewState.zoomIn()
    }

    func zoomOut() {
        imageViewState.zoomOut()
    }

    func zoomToFit() {
        imageViewState.zoomToFit()
    }

    func switchViewInfoItems() {
        imageViewState.switchViewInfoItems()
    }

    func resetInteractiveState() {
        zoomToFit()
        resetImageViewSelection()
        imageViewState.resetInteractiveOffset()
    }
}
