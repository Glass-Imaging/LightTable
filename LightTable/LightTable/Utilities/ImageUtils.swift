//
//  ImageUtils.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/16/22.
//

import SwiftUI

func NSImage(nsData: NSData) -> NSImage? {
    return NSImage(dataIgnoringOrientation: nsData as Data)
}

func NSImageMetadata(nsData: NSData) -> NSDictionary {
    if let cgImageSource = CGImageSourceCreateWithData(nsData as CFData, nil) {
        if let dictionary = CGImageSourceCopyPropertiesAtIndex(cgImageSource, 0, nil) {
            return dictionary as NSDictionary
        }
    }
    return NSDictionary()
}

func Image(nsImage: NSImage, metadata: NSDictionary, orientation: Image.Orientation, downScale: Bool) -> Image? {
    if nsImage.isValid {
        // NSImage sometimes changes the image size to take into account the ppi from metadata, override with NSImageRep
        let rep = nsImage.representations[0]
        let repSize = CGSize(width: rep.pixelsWide, height: rep.pixelsHigh)
        if (nsImage.size != repSize) {
            nsImage.size = repSize
        }
        if let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            // NOTE: Without the orientation-specific Text label the orientation changes are not picked up
            return Image(cgImage, scale: 1,
                         orientation: rotate(value: imageOrientation(metadata: metadata), by: orientation),
                         label: Text(String(describing: orientation)))
                    .interpolation(downScale ? .high : .none)
                    .antialiased(downScale ? true : false)
                    .resizable()
        }
    }
    return nil
}

func orientationToAngle(orientation: Image.Orientation) -> Angle {
    switch orientation {
    case .right:
        return Angle.degrees(90)
    case .down:
        return Angle.degrees(180)
    case .left:
        return Angle.degrees(270)
    default:
        return Angle.degrees(0)
    }
}

func hasOrientationMetadata(metadata: NSDictionary) -> Bool {
    return metadata["Orientation"] != nil
}

func imageOrientation(metadata: NSDictionary) -> Image.Orientation {
    if let exifOrientation = metadata["Orientation"] as? Int {
        switch(exifOrientation) {
        case 1:
            return .up
        case 8:
            return .left
        case 6:
            return .right
        case 3:
            return .down
        default:
            print("Unexpected EXIF orientation value:", exifOrientation)
            return .up
        }
    } else {
        return .up
    }
}

func rotateRight(value: Image.Orientation) -> Image.Orientation {
    switch value {
    case Image.Orientation.up:
        return Image.Orientation.right
    case Image.Orientation.right:
        return Image.Orientation.down
    case Image.Orientation.down:
        return Image.Orientation.left
    case Image.Orientation.left:
        return Image.Orientation.up
    default:
        print("Unexpected orientation: ", value)
        return value
    }
}

func rotateLeft(value: Image.Orientation) -> Image.Orientation {
    switch value {
    case Image.Orientation.up:
        return Image.Orientation.left
    case Image.Orientation.right:
        return Image.Orientation.up
    case Image.Orientation.down:
        return Image.Orientation.right
    case Image.Orientation.left:
        return Image.Orientation.down
    default:
        print("Unexpected orientation: ", value)
        return value
    }
}

func rotateDown(value: Image.Orientation) -> Image.Orientation {
    switch value {
    case Image.Orientation.up:
        return Image.Orientation.down
    case Image.Orientation.right:
        return Image.Orientation.left
    case Image.Orientation.down:
        return Image.Orientation.up
    case Image.Orientation.left:
        return Image.Orientation.up
    default:
        print("Unexpected orientation: ", value)
        return value
    }
}

func rotate(value: Image.Orientation, by: Image.Orientation) -> Image.Orientation {
    switch by {
    case Image.Orientation.up:
        return value
    case Image.Orientation.right:
        return rotateRight(value: value)
    case Image.Orientation.down:
        return rotateDown(value: value)
    case Image.Orientation.left:
        return rotateLeft(value: value)
    default:
        print("Unexpected orientation: ", value)
        return value
    }
}
