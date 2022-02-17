//
//  CGOperations.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/15/22.
//

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
