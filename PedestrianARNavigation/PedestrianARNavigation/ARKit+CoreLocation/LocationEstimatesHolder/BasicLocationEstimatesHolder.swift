//
//  BasicLocationEstimatesHolder.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 03/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

class BasicLocationEstimatesHolder: LocationEstimatesHolder {

    private(set) var bestLocationEstimate: SceneLocationEstimate? = nil
    private(set) var estimates: [SceneLocationEstimate] = []

    func add(_ locationEstimate: SceneLocationEstimate) {
        estimates.append(locationEstimate)
        if let bestEstimate = bestLocationEstimate, bestEstimate < locationEstimate { return }
        bestLocationEstimate = locationEstimate
    }

    func filter(_ isIncluded: (SceneLocationEstimate) -> Bool) {
        let (passed, removed) = estimates.reduce(([SceneLocationEstimate](),[SceneLocationEstimate]())) { passedRemovedPair, estimate in
            let passed = isIncluded(estimate)
            return (passedRemovedPair.0 + (passed ? [estimate] : []),
                    passedRemovedPair.1 + (passed ? [] : [estimate]))
        }

        assert(passed.count + removed.count == estimates.count)

        estimates = passed
        if let bestEstimate = bestLocationEstimate, !removed.contains(bestEstimate) { return }
        bestLocationEstimate = estimates.sorted{ $0 < $1 }.first
    }
}
