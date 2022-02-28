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

import Foundation

extension CGPoint {
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func +(left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x + right.width, y: left.y + right.height)
    }

    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static func += (left: inout CGPoint, right: CGSize) {
        left = left + right
    }

    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func -(left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x - right.width, y: left.y - right.height)
    }

    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    static func -= (left: inout CGPoint, right: CGSize) {
        left = left - right
    }

    static func *(left: CGPoint, val: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * val, y: left.y * val)
    }

    static func /(left: CGPoint, val: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / val, y: left.y / val)
    }
}

extension CGSize {
    static func +(left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    static func += (left: inout CGSize, right: CGSize) {
        left = left + right
    }

    static func -(left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    static func *(left: CGSize, val: CGFloat) -> CGSize {
        return CGSize(width: left.width * val, height: left.height * val)
    }

    static func /(left: CGSize, val: CGFloat) -> CGSize {
        return CGSize(width: left.width / val, height: left.height / val)
    }
}
