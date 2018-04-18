//
//  SceneLocationEstimate+Extensions.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 03/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

extension SceneLocationEstimate: Comparable {

    public static func < (lhs: SceneLocationEstimate, rhs: SceneLocationEstimate) -> Bool {
        if lhs.location.horizontalAccuracy == rhs.location.horizontalAccuracy {
            return lhs.location.timestamp > rhs.location.timestamp
        } else {
            return lhs.location.horizontalAccuracy < rhs.location.horizontalAccuracy
        }
    }

    public static func == (lhs: SceneLocationEstimate, rhs: SceneLocationEstimate) -> Bool {
        guard lhs.position.distance(vector: rhs.position) < Float.ulpOfOne else { return false }
        return lhs.location.coordinate.latitude == rhs.location.coordinate.latitude &&
            lhs.location.coordinate.longitude == rhs.location.coordinate.longitude &&
            lhs.location.horizontalAccuracy == rhs.location.horizontalAccuracy &&
            lhs.location.timestamp == rhs.location.timestamp
    }
}

extension CLLocation {
    public func isInsideAccuracyCircle(of location: CLLocation) -> Bool {
        return metersBetween(self.coordinate, location.coordinate) + self.horizontalAccuracy + .ulpOfOne < location.horizontalAccuracy
    }
}

extension CGPoint {
    func radiusContainsPoint(radius: CGFloat, point: CGPoint) -> Bool {
        let x = pow(point.x - self.x, 2)
        let y = pow(point.y - self.y, 2)
        let radiusSquared = pow(radius, 2)
        return x + y <= radiusSquared
    }
}

extension SceneLocationEstimate {
    public func canReplace(_ estimate: SceneLocationEstimate) -> Bool {
        guard !self.location.isInsideAccuracyCircle(of: estimate.location) else { return true }
        guard !estimate.location.isInsideAccuracyCircle(of: self.location) else { return false }
        guard metersBetween(self.location.coordinate, estimate.location.coordinate) < Double(self.location.horizontalAccuracy / 4) else { return false }
        return self < estimate
    }
}
