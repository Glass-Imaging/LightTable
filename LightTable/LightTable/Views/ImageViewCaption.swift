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

let exposureTimeTable:[(CGFloat, String)] = [
    (1.0,       "1"),
    (1.0/2,     "1/2"),
    (1.0/4,     "1/4"),
    (1.0/8,     "1/8"),
    (1.0/15,    "1/15"),
    (1.0/30,    "1/30"),
    (1.0/60,    "1/60"),
    (1.0/125,   "1/125"),
    (1.0/250,   "1/250"),
    (1.0/500,   "1/500"),
    (1.0/1000,  "1/1000"),
    (1.0/2000,  "1/2000"),
    (1.0/4000,  "1/4000"),
    (1.0/8000,  "1/8000"),
    (1.0/16000, "1/16000"),
    (1.0/32000, "1/32000"),
]

func formattedExposureTime(_ exposureTime: CGFloat) -> String {
    if exposureTime > 1 {
        return String(format: "%.1f", exposureTime)
    } else if exposureTime == 0 {
        return "0"
    } else {
        var minDifference:CGFloat = 10.0
        var minIndex = 0

        for i in 0 ..< exposureTimeTable.count {
            let difference = abs(exposureTime - exposureTimeTable[i].0)
            if difference < minDifference {
                minDifference = difference
                minIndex = i
            }
        }
        return exposureTimeTable[minIndex].1
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
        // print("Metadata for", url, metadata)

        fileName = url.lastPathComponent
        filePath = parentFolder(url:url).lastPathComponent
        pixelWidth = metadata["PixelWidth"] as? Int ?? 0
        pixelHeight = metadata["PixelHeight"] as? Int ?? 0
        fileModificationTime = fileDate

        captureTime = (metadata["{TIFF}"] as? NSDictionary)?["DateTime"] as? String
        fNumber = (metadata["{Exif}"] as? NSDictionary)?["FNumber"] as? CGFloat ??
                  (metadata["{Exif}"] as? NSDictionary)?["ApertureValue"] as? CGFloat ?? 0.0
        exposureTime = (metadata["{Exif}"] as? NSDictionary)?["ExposureTime"] as? CGFloat
        focalLength = (metadata["{Exif}"] as? NSDictionary)?["FocalLength"] as? Int
        exposureBias = (metadata["{Exif}"] as? NSDictionary)?["ExposureBiasValue"] as? Int
        isoSpeed = ((metadata["{Exif}"] as? NSDictionary)?["ISOSpeedRatings"] as? [Int])?[0]
        flash = (metadata["{Exif}"] as? NSDictionary)?["Flash"] as? Int
        exposureProgram = (metadata["{Exif}"] as? NSDictionary)?["ExposureProgram"] as? Int
        meteringMode = (metadata["{Exif}"] as? NSDictionary)?["MeteringMode"] as? Int
        make = (metadata["{TIFF}"] as? NSDictionary)?["Make"] as? String
        model = (metadata["{TIFF}"] as? NSDictionary)?["Model"] as? String
        serialNumber = (metadata["{ExifAux}"] as? NSDictionary)?["SerialNumber"] as? String ??
                       (metadata["{Exif}"] as? NSDictionary)?["BodySerialNumber"] as? String
        lens = (metadata["{Exif}"] as? NSDictionary)?["LensModel"] as? String ??
               (metadata["{ExifAux}"] as? NSDictionary)?["LensModel"] as? String
        software = (metadata["{TIFF}"] as? NSDictionary)?["Software"] as? String
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
            let ISO = ((metadata["{Exif}"] as? NSDictionary)?["ISOSpeedRatings"] as? [Int])?[0] ?? 0
            let fNumber = (metadata["{Exif}"] as? NSDictionary)?["FNumber"]  as? CGFloat ??
                          (metadata["{Exif}"] as? NSDictionary)?["ApertureValue"] as? CGFloat ?? 0

            let exposureTime = (metadata["{Exif}"] as? NSDictionary)?["ExposureTime"] as? CGFloat ?? 0

            let pixelWidth = metadata["PixelWidth"] as? Int ?? 0
            let pixelHeight = metadata["PixelHeight"] as? Int ?? 0

            return "ISO \(ISO), f/\(String(format: "%.1f", fNumber)), \(formattedExposureTime(exposureTime))s - \(pixelWidth) x \(pixelHeight)"
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
