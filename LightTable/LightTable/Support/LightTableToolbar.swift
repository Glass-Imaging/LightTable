//
//  LightTableToolbar.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/15/22.
//

import SwiftUI

func OrientationIcon(orientation: Image.Orientation) -> some View {
    let orientationIconName =
        orientation == .right ? "person.fill.turn.right" :
        orientation == .left ? "person.fill.turn.left" :
        orientation == .down ? "person.fill.turn.down" : "person.fill"

    return Image(systemName: orientationIconName)
        .foregroundColor(orientation == .up ? Color.gray : Color.blue)
        .font(Font.system(size: 14))
        .frame(width: 20, height: 20)
        .padding(2)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray).opacity(0.1)
        )
}

@ToolbarContentBuilder
func LightTableToolbar(model:ImageBrowserModel) -> some ToolbarContent {
    let imageViewLayoutBinding = Binding<ImageListLayout>(
        get: { model.imageViewLayout },
        set: { val in model.imageViewLayout = val }
    )

    let fullScreenViewModeBinding = Binding<Bool>(
        get: { model.fullScreen },
        set: { val in model.fullScreen = val }
    )

    let viewSelectionBinding = Binding<Bool>(
        get: { model.imageViewSelection >= 0 },
        set: { val in model.imageViewSelection = -1 }
    )

    ToolbarItemGroup(placement: .automatic) {
        Button(action: {
            model.orientation = rotateLeft(value: model.orientation)
        }) {
            Image(systemName: "rotate.left")
            .help("Rotate Left")
        }
        Button(action: {
            model.orientation = rotateRight(value: model.orientation)
        }) {
            Image(systemName: "rotate.right")
            .help("Rotate Right")
        }

        OrientationIcon(orientation: model.orientation)

        Divider()
    }
    ToolbarItemGroup(placement: .automatic) {
        Button(action: {
            model.viewScaleFactor += 1
        }) {
            Image(systemName: "plus.magnifyingglass")
            .help("Zoom In")
        }
        Button(action: {
            if (model.viewScaleFactor > 0) {
                model.viewScaleFactor -= 1
            }
        }) {
            Image(systemName: "minus.magnifyingglass")
            .help("Zoom Out")
        }
        Button(action: {
            model.viewScaleFactor = 0
        }) {
            Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
            .help("Zoom To Fit")
        }

        Text(model.viewScaleFactor == 0 ? "Fit" : "\(Int(model.viewScaleFactor))X")
            .foregroundColor(model.viewScaleFactor > 0 ? Color.blue : Color.gray)
            .frame(width: 25)
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray).opacity(0.1)
            )

        Divider()
    }

    ToolbarItemGroup(placement: .automatic) {
        Toggle(isOn: viewSelectionBinding, label: {
            let caption = model.imageViewSelection >= 0 ? "\(model.imageViewSelection + 1)" : "—"
            Image(systemName: "viewfinder")
                .help("View Selection")
            Text(caption)
                .frame(width: 12)
        })
            .foregroundColor(model.imageViewSelection >= 0 ? .blue : .gray)
            .toggleStyle(.button)

        Divider()
    }

    ToolbarItemGroup(placement: .automatic) {
        Picker("View Arrangement", selection: imageViewLayoutBinding) {
            Image(systemName: "rectangle.split.3x1")
                .help("Horizontal")
                .tag(ImageListLayout.Horizontal)

            Image(systemName: "rectangle.split.1x2")
                .help("Vertical")
                .tag(ImageListLayout.Vertical)

            Image(systemName: "rectangle.split.3x3")
                .help("Grid")
                .tag(ImageListLayout.Grid)
        }
        .pickerStyle(.inline)

        Divider()
    }

    ToolbarItem(placement: .automatic) {
        Toggle(isOn: fullScreenViewModeBinding, label: {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .help("Full Screen View")
        })
            .foregroundColor(model.fullScreen ? .blue : .gray)
            .toggleStyle(.button)
    }
}
