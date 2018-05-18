//
//  PedestrianARNavigationTests.swift
//  PedestrianARNavigationTests
//
//  Created by Dmitry Trimonov on 18/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import XCTest
import CoreLocation
@testable import PedestrianARNavigation

class PedestrianARNavigationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let size = ViewController.finishPlacemarkSize(
            forDistance: 50.0,
            closeDistance: 0.0,
            farDistance: 100.0,
            closeDistanceSize: 100.0,
            farDistanceSize: 50.0
        )
        XCTAssert(size == 75.0)
    }

    func testTranslationToPosition() {

        let coreLocationE1 = CLLocationCoordinate2D(latitude: 55.768382, longitude: 37.617810)
        let coreLocationActualLocation2 = coreLocationE1.transform(using: -162.0, longitudinalMeters: 240.0)
        let expectedLocation = CLLocationCoordinate2D(latitude: 55.766986, longitude: 37.621629)

        let distance = metersBetween(coreLocationActualLocation2, expectedLocation)
        XCTAssert(distance < 7.0)
    }

    func testCLLocationCoordinate2DTransformLon() {
        let center = CLLocationCoordinate2DMake(0, 0)
        let lonMeters: CLLocationDistance = 111000
        let result = center.transform(using: 0, longitudinalMeters: lonMeters)
        XCTAssert(fabs(result.lat - 0.0) <= 1e-6)
        XCTAssert(fabs(result.lon - 0.997130) <= 1e-6)
    }

    func testCLLocationCoordinate2DTransformLat() {
        let center = CLLocationCoordinate2DMake(0, 0)
        let latMeters: CLLocationDistance = 2 * .pi * GeometryConstants.EarthRadius / 4
        let result = center.transform(using: latMeters, longitudinalMeters: 0.0)
        XCTAssert(fabs(result.lat - 90.505170) <= 1e-6)
        XCTAssert(fabs(result.lon - 0.0) <= 1e-6)
    }

    func testSizeIsEqualToCloseDistanceSizeWhenDistanceIsLessThenCloseDistance() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let distance: CGFloat = 10.0
        let size = ViewController.finishPlacemarkSize(
            forDistance: distance,
            closeDistance: 30.0,
            farDistance: 100.0,
            closeDistanceSize: 100.0,
            farDistanceSize: 23.0
        )
        XCTAssert(size == 100.0)
    }

    func testSizeIsEqualToFarDistanceSizeWhenDistanceIsMoreThenFarDistance() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let distance: CGFloat = 120.0
        let size = ViewController.finishPlacemarkSize(
            forDistance: distance,
            closeDistance: 30.0,
            farDistance: 100.0,
            closeDistanceSize: 120.0,
            farDistanceSize: 50.0
        )
        XCTAssert(size == 50.0)
    }

    func testSize() {
        let distance: CGFloat = 20.0
        let size = ViewController.finishPlacemarkSize(
            forDistance: distance,
            closeDistance: 10.0,
            farDistance: 50.0,
            closeDistanceSize: 100.0,
            farDistanceSize: 60.0
        )
        XCTAssert(size == 90.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
