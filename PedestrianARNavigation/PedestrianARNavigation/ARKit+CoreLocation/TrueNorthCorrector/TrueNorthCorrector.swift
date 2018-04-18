//
//  TrueNorthCorrector.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 09/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

public func correctionAngleByBearing(_ e1: SceneLocationEstimate, _ e2: SceneLocationEstimate) -> Double {
    let calculatedE2Location = e1.translatedLocation(to: e2.position)
    return bearingBetween(e1.location.coordinate, calculatedE2Location.coordinate) - bearingBetween(e1.location.coordinate, e2.location.coordinate)
}
