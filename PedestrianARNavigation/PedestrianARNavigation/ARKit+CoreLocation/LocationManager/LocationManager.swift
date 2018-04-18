//
//  LocationManager.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 03/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation
import CoreLocation

public protocol LocationManager {
    var location: CLLocation? { get }
    var configuration: LocationManagerConfiguration { get set }

    func addListener(_ listener: LocationManagerListener)
    func removeListener(_ listener: LocationManagerListener)

    func suspend()
    func resume()
}

public enum DesiredAccuracy {
    case bestForNavigation
    case best
    case distance(Double)
}

public struct LocationManagerConfiguration {
    public var desiredAccuracy: DesiredAccuracy
    public var distanceFilter: Double
    public var updateFrequencyFilter: TimeInterval?
    public var allowsUseInBackground: Bool

    public init(desiredAccuracy: DesiredAccuracy, distanceFilter: Double,
                updateFrequencyFilter: TimeInterval? = nil, allowsUseInBackground: Bool = false)
    {
        self.desiredAccuracy = desiredAccuracy
        self.distanceFilter = distanceFilter
        self.updateFrequencyFilter = updateFrequencyFilter
        self.allowsUseInBackground = allowsUseInBackground
    }
}

public protocol LocationManagerListener: class {
    func onLocationUpdate(_ location: CLLocation)
    func onAuthorizationStatusUpdate(_ authorizationStatus: CLAuthorizationStatus)
}
