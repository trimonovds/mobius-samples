import Foundation
import CoreLocation
import SceneKit
import MapKit

public struct GeometryConstants {
    public static let EarthRadius = Double(6_371_000)
    public static let LatLonEps = 1e-6
}

public extension Double {

    /// Конвертирует длину в метрах в длину по меридиану (по любому, так как они все одной длины) в радианах
    ///
    /// - Returns: длины в радианах
    public func metersToLatitude() -> Double {
        return self / GeometryConstants.EarthRadius
    }

    /// Конвертирует длину в метрах в длину по параллели
    /// переданной в параметрах (так как длина праллели зависит от широты) в радианах
    /// - Parameter lat: широта в градусах
    /// - Returns: длину в радианах
    func metersToLongitude(lat: Double) -> Double {
        return self / GeometryConstants.EarthRadius * cos(lat.degreesToRadians)
    }
}

public extension BinaryFloatingPoint {
    public var degreesToRadians: Self { return self * .pi / 180 }
    public var radiansToDegrees: Self { return self * 180 / .pi }
}


public struct SceneLocationEstimate {
    public let location: CLLocation
    public let position: SCNVector3
    public init(location: CLLocation, position: SCNVector3) {
        self.location = location
        self.position = position
    }
}

public extension SceneLocationEstimate {

    /// Translates the location by comparing with a given position
    public func translatedLocation(to position: SCNVector3) -> CLLocation {
        let translation = position - self.position
        let translatedCoordinate = location.coordinate.transform(using: CLLocationDistance(-translation.z),
                                                                 longitudinalMeters: CLLocationDistance(translation.x))
        return CLLocation(
            coordinate: translatedCoordinate,
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            timestamp: location.timestamp
        )
    }
}


/// Haversine formula to calculate the great-circle distance between two points
///
/// - Parameters:
///   - lat1: 1-st point latitude
///   - lon1: 1-st point longitude
///   - lat2: 2-nd point latitude
///   - lon2: 2-nd point longitude
/// - Returns: Distance in meters
public func metersBetween(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
    // From here: http://www.movable-type.co.uk/scripts/latlong.html

    let sqr: (Double) -> Double = { $0 * $0 }
    let R = GeometryConstants.EarthRadius // meters

    let phi_1 = lat1.degreesToRadians
    let phi_2 = lat2.degreesToRadians
    let dPhi = (lat2 - lat1).degreesToRadians
    let dLmb = (lon2 - lon1).degreesToRadians

    let a = sqr(sin(dPhi/2)) + cos(phi_1) * cos(phi_2) * sqr(sin(dLmb/2))
    let c: Double = 2 * atan2(sqrt(a), sqrt(Double(1) - a))

    return R * c
}

public func metersBetween(_ coordinate1: CLLocationCoordinate2D, _ coordinate2: CLLocationCoordinate2D) -> Double {
    return metersBetween(coordinate1.latitude, coordinate1.longitude, coordinate2.latitude, coordinate2.longitude)
}

//(-180,180] anticlockwise is positive
public func bearingBetween(_ point1: CLLocationCoordinate2D, _ point2: CLLocationCoordinate2D) -> Double {
    let lat1 = point1.latitude.degreesToRadians
    let lon1 = point1.longitude.degreesToRadians

    let lat2 = point2.latitude.degreesToRadians
    let lon2 = point2.longitude.degreesToRadians

    let dLon = lon2 - lon1

    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)

    return radiansBearing.radiansToDegrees
}

/// Translation in meters between 2 locations
public struct LocationTranslation {
    public var latitudeTranslation: Double
    public var longitudeTranslation: Double

    public init(latitudeTranslation: Double, longitudeTranslation: Double) {
        self.latitudeTranslation = latitudeTranslation
        self.longitudeTranslation = longitudeTranslation
    }
}

extension LocationTranslation {
    public init(dLat: Double, dLon: Double) {
        self.init(latitudeTranslation: dLat, longitudeTranslation: dLon)
    }

    public var dLat: Double {
        return latitudeTranslation
    }

    public var dLon: Double {
        return longitudeTranslation
    }
}

public extension CLLocationCoordinate2D {

    var lat: Double {
        return latitude
    }

    var lon: Double {
        return longitude
    }

    public func transform(using latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) -> CLLocationCoordinate2D {
        let region = MKCoordinateRegionMakeWithDistance(self, latitudinalMeters, longitudinalMeters)
        return CLLocationCoordinate2D(latitude: latitude + region.span.latitudeDelta, longitude: longitude + region.span.longitudeDelta)
    }

    /// Calculate translation between to coordinates
    func translation(toCoordinate coordinate: CLLocationCoordinate2D) -> LocationTranslation {
        let position = CLLocationCoordinate2D(latitude: self.latitude, longitude: coordinate.longitude)
        let distanceLat = metersBetween(coordinate, position)
        let dLat: Double = (coordinate.lat > position.lat ? 1 : -1) * distanceLat
        let distanceLon = metersBetween(self, position)
        let dLon: Double = (lon > position.lon ? -1 : 1) * distanceLon
        return LocationTranslation(dLat: dLat, dLon: dLon)
    }

    func translation2(toCoordinate coordinate: CLLocationCoordinate2D) -> LocationTranslation {
        let metersInOneLatDegree: Double = 2 * Double.pi * GeometryConstants.EarthRadius / 360
        let metersInOneLonDegree: ((Double) -> Double) = {
            2 * Double.pi * GeometryConstants.EarthRadius * cos($0.degreesToRadians) / 360
        }
        let distanceLat = abs(coordinate.lat - lat)
        let distanceLon = abs(coordinate.lon - lon)
        let dLat: Double = (coordinate.lat > lat ? 1 : -1) * distanceLat
        let dLon: Double = (lon > coordinate.lon ? -1 : 1) * distanceLon
        return LocationTranslation(dLat: dLat * metersInOneLatDegree, dLon: dLon * metersInOneLonDegree(lat))
    }
}



