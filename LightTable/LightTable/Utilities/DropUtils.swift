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
