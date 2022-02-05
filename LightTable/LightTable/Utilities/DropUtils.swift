//
//  DropUtils.swift
//  LightTable
//
//  Created by Fabio Riccardi on 1/30/22.
//

import SwiftUI
import UniformTypeIdentifiers

/// Utility class to implement the drag and drop functionallity
class DropUtils {
    /// Extract the URL of a file from the DropInfo object
    /// - Parameters:
    ///   - info: The DropInfo object
    ///   - completion: completion handler with an optional URL
    class func urlFromDropInfo(_ info:DropInfo, completion: @escaping (URL?) -> Void)  {
        guard let itemProvider = info.itemProviders(for: [UTType.fileURL]).first else {
            completion(nil)
            return
        }

        itemProvider.loadItem(forTypeIdentifier:UTType.fileURL.identifier, options: nil) {item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                completion(nil)
                return
            }
            completion(url)
        }
    }
}
