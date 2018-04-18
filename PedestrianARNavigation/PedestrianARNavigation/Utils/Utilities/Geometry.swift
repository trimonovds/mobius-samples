//
//  Utils.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 24/03/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import UIKit
import SceneKit

public func reflect<T: FloatingPoint>(_ value: T, of reflectionPoint: T) -> T  {
    let diff = value - reflectionPoint
    return reflectionPoint - diff
}

public extension FloatingPoint {
    public var degreesToRadians: Self { return self * .pi / 180 }
    public var radiansToDegrees: Self { return self * 180 / .pi }
}

extension CGRect {
    var mid: CGPoint {
        return CGPoint(x: midX, y: midY)
    }

    var topLeft: CGPoint{
        return origin
    }

    var topRight: CGPoint{
        return CGPoint(x: origin.x + width, y: origin.y)
    }

    var bottomLeft: CGPoint{
        return CGPoint(x: origin.x, y: origin.y + height)
    }

    var bottomRight: CGPoint{
        return CGPoint(x: origin.x + width, y: origin.y + height)
    }
}

struct CGLine {
    let point1: CGPoint
    let point2: CGPoint
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        let dist = sqrt(pow(dx, 2) + pow(dy, 2))
        return dist
    }
}

let MT_EPS: CGFloat = 1e-4

typealias CGDelta = CGPoint

extension CGLine {

    func point(atDistance distance: CGFloat) -> CGPoint {
        let start = Vector2(self.point1)
        let end = Vector2(self.point2)
        let vec = start + (end - start).normalized() * Scalar(distance)
        return CGPoint(vec)
    }

    func contains(point: CGPoint) -> Bool {
        let end: CGPoint = self.point2
        let start: CGPoint = self.point1
        let startToEnd = Vector2(end) - Vector2(start)
        let startToPoint = Vector2(point) - Vector2(start)
        let pointToEnd = Vector2(end) - Vector2(point)
        if fabs(CGFloat(startToPoint.length)) < MT_EPS || fabs(CGFloat(pointToEnd.length)) < MT_EPS {
            return true
        } else {
            return (startToPoint.angle(with: startToEnd).truncatingRemainder(dividingBy: .twoPi) ~= 0.0)
                && (startToPoint.length <= startToEnd.length)
        }
    }

    var length: CGFloat {
        return point1.distance(to: point2)
    }

    func intersection(withRect rect: CGRect) -> CGPoint? {
        let top = CGLine(point1: rect.topLeft, point2: rect.topRight)
        let right = CGLine(point1: rect.topRight, point2: rect.bottomRight)
        let bottom = CGLine(point1: rect.bottomLeft, point2: rect.bottomRight)
        let left = CGLine(point1: rect.topLeft, point2: rect.bottomLeft)


        let points: [CGPoint?] = [ top.intersection(withLine: self),
                                   right.intersection(withLine: self),
                                   left.intersection(withLine: self),
                                   bottom.intersection(withLine: self)]

        for p in points {
            if p != nil {
                return p!
            }
        }

        return nil;
    }

    func intersection(withLine line: CGLine) -> CGPoint? {
        let line1 = self
        let line2 = line

        let x1 = line1.point1.x
        let y1 = line1.point1.y
        let x2 = line1.point2.x
        let y2 = line1.point2.y
        let x3 = line2.point1.x
        let y3 = line2.point1.y
        let x4 = line2.point2.x
        let y4 = line2.point2.y

        let denom  = (y4-y3) * (x2-x1) - (x4-x3) * (y2-y1)
        let numera = (x4-x3) * (y1-y3) - (y4-y3) * (x1-x3)
        let numerb = (x2-x1) * (y1-y3) - (y2-y1) * (x1-x3)

        /* Are the lines coincident? */
        if (fabs(numera) < MT_EPS && fabs(numerb) < MT_EPS && fabs(denom) < MT_EPS) {
            return CGPoint(x: (x1 + x2) / 2.0, y: (y1 + y2) / 2.0)
        }

        /* Are the line parallel */
        if (fabs(denom) < MT_EPS) {
            return nil
        }

        /* Is the intersection along the the segments */
        let mua = numera / denom
        let mub = numerb / denom
        if (mua < 0 || mua > 1 || mub < 0 || mub > 1) {
            return nil
        }
        return CGPoint(x: x1 + mua * (x2 - x1), y: y1 + mua * (y2 - y1))
    }
}
