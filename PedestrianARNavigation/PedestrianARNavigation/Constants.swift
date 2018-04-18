//
//  Constants.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 04/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation
import SceneKit

struct Constants {

    static let sceneRadiusLimit: CGFloat = 100

    static let distanceBetweenArrows: Float = 5.0

    static let sampleRoute: [CGPoint] = [
        CGPoint.zero,
        CGPoint(x: 2, y: 0),
        CGPoint(x: 7, y: 0),
        CGPoint(x: 10, y: 0),
        CGPoint(x: 10, y: 5),
        CGPoint(x: 7, y: 7),
        CGPoint(x: 5, y: 5),
        CGPoint(x: 5, y: 10),
        CGPoint(x: 0, y: 10),
        CGPoint(x: -6, y: 4),
        CGPoint(x: 0, y: 0)
    ]
}
