//
//  ImageViewModel.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/22/22.
//

import SwiftUI

struct ImageViewModel {
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

    // Image View Orientation
    private(set) var orientation:Image.Orientation = .up

    mutating func rotateLeft() {
        orientation = LightTable.rotateLeft(value: orientation)
    }

    mutating func rotateRight() {
        orientation = LightTable.rotateRight(value: orientation)
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

    private(set) var useMasterOrientation = false

    mutating func togglaMasterOrientation() {
        useMasterOrientation = !useMasterOrientation
    }

    private(set) var masterOrientation:Image.Orientation = .up

    mutating func setMasterOrientation(orientation:Image.Orientation) {
        masterOrientation = orientation
    }

    var thumbnailSize:CGFloat = 150

    // User dragging action
    var viewOffset = CGPoint.zero
    var viewOffsetInteractive = CGPoint.zero

    mutating func resetInteractiveState() {
        resetImageViewSelection()
        // fullScreen = false
        viewScaleFactor = 0
        viewOffset = CGPoint.zero
        viewOffsetInteractive = CGPoint.zero
    }
}
