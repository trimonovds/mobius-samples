//
//  RouteArrowAnimation.swift
//  RoutePolyline
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import UIKit

struct Step {
    let start: CGPoint
    let end: CGPoint
    let length: CGFloat

    init(start: CGPoint, end: CGPoint) {
        assert(start != end)
        self.start = start
        self.end = end
        self.length = start.distance(to: end)
    }
}

struct Animation {
    var steps: [Step]
}

extension Step {
    var vec: Vector2 {
        return Vector2(end) - Vector2(start)
    }
}

extension Animation {
    var points: [CGPoint] {
        return steps.map { [$0.start, $0.end] }.flatMap { $0 }
    }
}
