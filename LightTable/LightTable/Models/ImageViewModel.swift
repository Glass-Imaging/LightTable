//
//  ImageViewModel.swift
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

// User zoomed-in view dragging action state, the master instance is a @State variable in ImageListView
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

    @Published private(set) var useMasterOrientation = false

    func togglaMasterOrientation() {
        useMasterOrientation = !useMasterOrientation
    }

    @Published private(set) var masterOrientation:Image.Orientation = .up

    func setMasterOrientation(orientation:Image.Orientation) {
        masterOrientation = orientation
    }
}

struct ImageViewModel {
    // Reference to the ImageListView @State object, used to reset imageViewOffset without having a global handle on it
    var viewState:ImageViewState? = nil

    mutating func rotateLeft() {
        viewState?.rotateLeft()
    }

    mutating func rotateRight() {
        viewState?.rotateRight()
    }

    mutating func togglaMasterOrientation() {
        viewState?.togglaMasterOrientation()
    }

    mutating func setMasterOrientation(orientation:Image.Orientation) {
        viewState?.setMasterOrientation(orientation: orientation)
    }

    // Multipe Image View layout (Horizontal/Vertical/Grid)
    var imageViewLayout:ImageListLayout = .Horizontal

    mutating func switchLayout() {
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
    private(set) var imageViewSelection = -1

    mutating func imageViewSelection(char:Character, selection:[URL]) {
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

    mutating func resetImageViewSelection() {
        imageViewSelection = -1
    }

    // Fullscreen view presentation
    var fullScreen = false

    mutating func toggleFullscreen() {
        fullScreen = !fullScreen
    }

    // View magnification factor: 0 -> scale to fit, 1x, 2x, 3x, ...
    private(set) var viewScaleFactor:CGFloat = 0

    mutating func zoomIn() {
        viewScaleFactor += 1
    }

    mutating func zoomOut() {
        if (viewScaleFactor > 0) {
            viewScaleFactor -= 1
        }
    }

    mutating func zoomToFit() {
        viewScaleFactor = 0
    }

    mutating func switchViewInfoItems() {
        viewInfoItems = viewInfoItems == 0 ? 3 : viewInfoItems - 1
    }

    /* private(set) */ var viewInfoItems:Int = 3

    var thumbnailSize:CGFloat = 150

    mutating func resetInteractiveState() {
        viewScaleFactor = 0
        resetImageViewSelection()
        viewState?.resetInteractiveOffset()
    }
}
