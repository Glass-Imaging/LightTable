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

func formattedExposureTime(_ exposureTime: CGFloat) -> String {
    if exposureTime > 1 {
        return String(format: "%.1f", exposureTime)
    } else if exposureTime == 0 {
        return "0"
    } else {
        return "1/\(String(format:"%.0f", 1.0/exposureTime))"
    }
}

extension NSDictionary {
    func value(section: String, key: String) -> Any? {
        return (self[section] as? NSDictionary)?[key]
    }

    func value<T>(section: String, key: String) -> T? {
        return (self[section] as? NSDictionary)?[key] as? T
    }

    func value<T>(_ type: T.Type, section: String, key: String) -> T? {
        return (self[section] as? NSDictionary)?[key] as? T
    }
}

struct MetadataValues {
    let fileName: String
    let filePath: String
    let pixelWidth: Int
    let pixelHeight: Int
    let fileModificationTime: Date
    let captureTime: String?
    let fNumber: CGFloat?
    let exposureTime: CGFloat?
    let focalLength: Int?
    let exposureBias: Int?
    let isoSpeed: Int?
    let flash: Int?
    let exposureProgram: Int?
    let meteringMode: Int?
    let make: String?
    let model: String?
    let serialNumber: String?
    let lens: String?
    let software: String?

    init(url: URL, fileDate: Date, metadata: NSDictionary) {
        fileName = url.lastPathComponent
        filePath = parentFolder(url:url).lastPathComponent
        pixelWidth = metadata["PixelWidth"] as? Int ?? 0
        pixelHeight = metadata["PixelHeight"] as? Int ?? 0
        fileModificationTime = fileDate

        captureTime = metadata.value(section: "{TIFF}", key: "DateTime")
        fNumber = metadata.value(section: "{Exif}", key: "FNumber") ??
                  metadata.value(section: "{Exif}", key: "ApertureValue") ?? 0
        exposureTime = metadata.value(section: "{Exif}", key: "ExposureTime")
        focalLength = metadata.value(section: "{Exif}", key: "FocalLength")
        exposureBias = metadata.value(section: "{Exif}", key: "ExposureBiasValue")
        isoSpeed = metadata.value([Int].self, section: "{Exif}", key: "ISOSpeedRatings")?[0]
        flash = metadata.value(section: "{Exif}", key: "Flash")
        exposureProgram = metadata.value(section: "{Exif}", key: "ExposureProgram")
        meteringMode = metadata.value(section: "{Exif}", key: "MeteringMode")
        make = metadata.value(section: "{TIFF}", key: "Make")
        model = metadata.value(section: "{TIFF}", key: "Model")
        serialNumber = metadata.value(section: "{ExifAux}", key: "SerialNumber") ??
                       metadata.value(section: "{Exif}", key: "BodySerialNumber")
        lens = metadata.value(section: "{Exif}", key: "LensModel") ??
               metadata.value(section: "{ExifAux}", key: "LensModel")
        software = metadata.value(section: "{TIFF}", key: "Software")
    }
}

func ExifText(_ text: String) -> some View {
    Text(text)
        .bold()
}

struct ImageViewExif: View {
    let url: URL
    let index: (Int, Int)
    let fileDate: Date
    let metadata: NSDictionary?
    @Binding var showEXIFMetadata:Bool

    var body: some View {
        if showEXIFMetadata, let metadata = metadata {
            let metadataValues = MetadataValues(url: url, fileDate: fileDate, metadata: metadata)
            let dateFormatter:DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                return dateFormatter
            }()

            let leftColumn = GridItem(.fixed(120), spacing: 5, alignment: .trailing)
            let rightColumn = GridItem(spacing: 5, alignment: .leading)

            LazyVGrid(columns: [leftColumn, rightColumn]) {
                Group {
                    Text("File Name:")
                    ExifText("\(metadataValues.fileName)")

                    Text("File Path:")
                    ExifText("\(metadataValues.filePath)")

                    Text("Dimensions:")
                    ExifText("\(metadataValues.pixelWidth) x \(metadataValues.pixelHeight)")

                    Text("Modification Date:")
                    ExifText("\(dateFormatter.string(from: metadataValues.fileModificationTime))")

                    if let captureTime = metadataValues.captureTime {
                        Text("Capture Time:")
                        ExifText(captureTime)
                    }
                    if let fNumber = metadataValues.fNumber,
                       let exposureTime = metadataValues.exposureTime {
                        Text("Exposure:")
                        ExifText("\(formattedExposureTime(exposureTime)) sec at f / \(String(format: "%.1f", fNumber))")
                    }
                }
                Group {
                    if let focalLength = metadataValues.focalLength {
                        Text("Focal Length:")
                        ExifText("\(focalLength) mm")
                    }
                    if let exposureBias = metadataValues.exposureBias {
                        Text("Exposure Bias:")
                        ExifText("\(String(format: "%.1f", exposureBias)) EV")
                    }
                    if let isoSpeed = metadataValues.isoSpeed {
                        Text("ISO Speed Rating:")
                        ExifText("\(isoSpeed)")
                    }
                    if let flash = metadataValues.flash {
                        Text("Flash:")
                        ExifText("\(flash)")
                    }
                }
                Group {
                    if let exposureProgram = metadataValues.exposureProgram {
                        Text("Exposure Program:")
                        ExifText("\(exposureProgram)")
                    }
                    if let meteringMode = metadataValues.meteringMode {
                        Text("Metering Mode:")
                        ExifText("\(meteringMode)")
                    }
                    if let make = metadataValues.make {
                        Text("Make:")
                        ExifText("\(make)")
                    }
                    if let model = metadataValues.model {
                        Text("Model:")
                        ExifText("\(model)")
                    }
                    if let serialNumber = metadataValues.serialNumber {
                        Text("Serial Number:")
                        ExifText("\(serialNumber)")
                    }
                    if let lens = metadataValues.lens {
                        Text("Lens:")
                        ExifText("\(lens)")
                    }
                    if let software = metadataValues.software {
                        Text("Software:")
                        ExifText("\(software)")
                    }
                }
            }
            .frame(width: 350, alignment: .top)
            .shadow(color: .black, radius: 2, x: 0, y: 0)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.3))
            )
            .padding(.top, 5)
        }
    }
}

struct ImageViewCaption: View {
    let url: URL
    let index: (Int, Int)
    let fileDate: Date
    let metadata: NSDictionary?
    @Binding var viewInfoItems:Int

    func metadataProperty(metadata: NSDictionary, key: String) -> Int {
        return metadata[key] as? Int ?? 0
    }

    func imageMetadata() -> String {
        if let metadata = metadata {
            let ISO = metadata.value([Int].self, section: "{Exif}", key: "ISOSpeedRatings")?[0]

            let fNumber:CGFloat? = metadata.value(section: "{Exif}", key: "FNumber") ??
                                   metadata.value(section: "{Exif}", key: "ApertureValue")

            let exposureTime:CGFloat? = metadata.value(section: "{Exif}", key: "ExposureTime")

            let pixelWidth = metadata["PixelWidth"] as? Int ?? 0
            let pixelHeight = metadata["PixelHeight"] as? Int ?? 0

            let isoFmt = ISO != nil ? "ISO \(ISO!), " : ""
            let fNumberFmt = fNumber != nil ? "f/\(String(format: "%.1f", fNumber!)), " : ""
            let exposureTimeFmt = exposureTime != nil ? "\(formattedExposureTime(exposureTime!))s" : ""

            let exposure = isoFmt + fNumberFmt + exposureTimeFmt
            let dimensions = "\(pixelWidth) x \(pixelHeight)"

            return !exposure.isEmpty ? exposure + " - " + dimensions : dimensions
        }

        return "--"
    }

    var body: some View {
        let parentFolder = parentFolder(url:url).lastPathComponent
        let filename = url.lastPathComponent

        if viewInfoItems > 0 {
            VStack(spacing: 1) {
                Text("\(filename) (\(index.0)/\(index.1))")
                    .bold()
                    .font(.subheadline)

                if viewInfoItems > 1 {
                    Divider()
                        .frame(width: 150)

                    Text(parentFolder)
                        .font(.caption)

                    if viewInfoItems > 2 {
                        Divider()
                            .frame(width: 150)

                        Text(imageMetadata())
                            .font(.caption)
                    }
                }
            }
            .shadow(color: .black, radius: 2, x: 0, y: 0)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.3))
            )
            .padding(.bottom, 5)
        }
    }
}
