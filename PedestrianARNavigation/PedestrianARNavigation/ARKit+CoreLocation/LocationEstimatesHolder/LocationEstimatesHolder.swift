//
//  LocationEstimatesHolder.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 03/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationEstimatesHolder {
    var bestLocationEstimate: SceneLocationEstimate? { get }
    var estimates: [SceneLocationEstimate] { get }

    func add(_ locationEstimate: SceneLocationEstimate)
    func filter(_ isIncluded: (SceneLocationEstimate) -> Bool)
}
