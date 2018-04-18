//
//  AdvancedLocationEstimatesHolder.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 04/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

class AdvancedLocationEstimatesHolder: BasicLocationEstimatesHolder {

    override func add(_ locationEstimate: SceneLocationEstimate) {
        for estimate in estimates {
            guard !estimate.canReplace(locationEstimate) else { return }
        }
        super.add(locationEstimate)
        filter { !locationEstimate.canReplace($0) }
    }
}
