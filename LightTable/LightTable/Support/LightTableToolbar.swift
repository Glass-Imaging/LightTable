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

extension LightTableView {

    @ToolbarContentBuilder
    func LightTableToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {
                viewModel.rotateLeft()
            }) {
                Image(systemName: "rotate.left")
                .help("Rotate Left")
            }
            Button(action: {
                viewModel.rotateRight()
            }) {
                Image(systemName: "rotate.right")
                .help("Rotate Right")
            }

            OrientationIcon(orientation: viewModel.orientation)

            Divider()
        }
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {
                viewModel.zoomOut()
            }) {
                Image(systemName: "minus.magnifyingglass")
                .help("Zoom Out")
            }
            Button(action: {
                viewModel.zoomIn()
            }) {
                Image(systemName: "plus.magnifyingglass")
                .help("Zoom In")
            }
            Button(action: {
                viewModel.zoomToFit()
            }) {
                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                .help("Zoom To Fit")
            }

            Text(viewModel.viewScaleFactor == 0 ? "Fit" : "\(Int(viewModel.viewScaleFactor))X")
                .foregroundColor(viewModel.viewScaleFactor > 0 ? Color.blue : Color.gray)
                .frame(width: 25)
                .padding(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray).opacity(0.1)
                )

            Divider()
        }

        ToolbarItemGroup(placement: .automatic) {
            Button(action: {
                viewModel.resetImageViewSelection()
            }, label: {
                let caption = viewModel.imageViewSelection >= 0 ? "\(viewModel.imageViewSelection + 1)" : "—"
                Image(systemName: "viewfinder")
                    .help("View Selection")
                Text(caption)
                    .frame(width: 12)
            }).foregroundColor(viewModel.imageViewSelection >= 0 ? .blue : .gray)

            Divider()
        }

        ToolbarItemGroup(placement: .automatic) {
            Picker("View Arrangement", selection: $viewModel.imageViewLayout) {
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
            Toggle(isOn: $viewModel.fullScreen, label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .help("Full Screen View")
            })
                .foregroundColor(viewModel.fullScreen ? .blue : .gray)
                .toggleStyle(.button)
        }
    }
}
