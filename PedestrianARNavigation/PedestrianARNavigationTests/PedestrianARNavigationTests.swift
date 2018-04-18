//
//  PedestrianARNavigationTests.swift
//  PedestrianARNavigationTests
//
//  Created by Dmitry Trimonov on 18/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import XCTest
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
