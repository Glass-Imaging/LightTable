//
//  FileListing.swift
//  PhotoBrowser
//
//  Created by Fabio Riccardi on 1/31/22.
//

import SwiftUI

class FileListing: ObservableObject {
    @Published var files:[URL] = []
}
