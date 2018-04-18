//
//  RouteAnimation.swift
//  RoutePolyline
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import SceneKit

func divideRoute(route: [CGPoint], toAnimationsOfLength animationLength: Float) -> [Animation] {
    guard route.count >= 2 else { return [] }
    var animations: [Animation] = []
    var currentAnimation: Animation = Animation(steps: [])
    let segmentsCount = Array(zip(route, route.skip(1))).count
    var currentSegmentIndex = 0
    var offsetInSegment: CGFloat = 0.0
    var lengthTailFromPrevSegment: CGFloat? = nil
    while currentSegmentIndex < segmentsCount {
        let segmentStart = route[currentSegmentIndex]
        let segmentEnd = route[currentSegmentIndex + 1]
        let segmentLine = CGLine(point1: segmentStart, point2: segmentEnd)

        var stepStart: CGPoint
        var stepEnd: CGPoint

        if let lengthTail = lengthTailFromPrevSegment {
            assert(offsetInSegment == 0.0)
            stepStart = segmentStart
            let stepEndCandidate = segmentLine.point(atDistance: lengthTail)
            if segmentLine.contains(point: stepEndCandidate) {
                stepEnd = stepEndCandidate
                currentAnimation.steps.append(Step(start: stepStart, end: stepEnd))
                animations.append(currentAnimation)
                currentAnimation = Animation(steps: [])

                if stepEnd == segmentEnd {
                    offsetInSegment = 0.0
                    currentSegmentIndex += 1
                } else {
                    offsetInSegment = lengthTail
                }
                lengthTailFromPrevSegment = nil
            } else {
                stepEnd = segmentEnd
                let step = Step(start: stepStart, end: stepEnd)
                currentAnimation.steps.append(step)

                currentSegmentIndex += 1
                offsetInSegment = 0.0
                lengthTailFromPrevSegment = lengthTail - step.length
            }
            continue
        }

        stepStart = segmentLine.point(atDistance: offsetInSegment)
        assert(segmentLine.contains(point: stepStart))
        let nextOffset = offsetInSegment + CGFloat(animationLength)
        let stepEndCandidate = segmentLine.point(atDistance: nextOffset)
        if segmentLine.contains(point: stepEndCandidate) {
            stepEnd = stepEndCandidate
            currentAnimation.steps.append(Step(start: stepStart, end: stepEnd))
            animations.append(currentAnimation)
            currentAnimation = Animation(steps: [])
            if stepEnd == segmentEnd {
                offsetInSegment = 0.0
                currentSegmentIndex += 1
            } else {
                offsetInSegment = nextOffset
            }
            lengthTailFromPrevSegment = nil
        } else {
            if stepStart ~= segmentEnd {
                break
            }
            stepEnd = segmentEnd
            let step = Step(start: stepStart, end: stepEnd)
            currentAnimation.steps.append(step)
            currentSegmentIndex += 1
            offsetInSegment = 0.0
            lengthTailFromPrevSegment = CGFloat(animationLength) - step.length
        }
    }

    if currentAnimation.steps.count > 0 {
        animations.append(currentAnimation)
    }
    return animations
}

fileprivate extension CGPoint {
    /// Здесь x - по оси Z в SceneKit, y - по оси X в SceneKit (ось Y SceneKit смотрит при этом вверх)
    /// на плоскость Y = 0
    var positionIn3D: SCNVector3 {
        return SCNVector3(y, 0.0, x)
    }
}

func createRepresentation(forRoute route: [CGPoint], withAnimationLength animationLength: Float) -> (routeNodes: [SCNNode], animationNodes: [SCNNode]) {
    let animationPointNodes: [SCNNode] = divideRoute(route: route, toAnimationsOfLength: animationLength).map { $0.points }.flatMap { $0 }.map {
        let node = RoutePointNode(radius: 0.15, color: UIColor.red, transparency: 1.0, height: 0.05)
        node.position = $0.positionIn3D
        return node
    }
    let routePointNodes: [SCNNode] = route.map {
        let node = RoutePointNode(radius: 0.3, transparency: 0.5)
        node.position = $0.positionIn3D
        return node
    }
    return (routeNodes: routePointNodes, animationNodes: animationPointNodes)
}

func createResetAction(firstStep: Step) -> SCNAction {
    let initialPosition = firstStep.start.positionIn3D
    let initialAngle = Vector2.x.angle(with: firstStep.vec) // Стрелка направлена по оси Z, которая переводится в 2D (CGPoint) как к-та X
    let moveToInitial = SCNAction.move(to: initialPosition, duration: 0.0)
    let rotateToInitial = SCNAction.rotateTo(x: 0.0, y: CGFloat(initialAngle), z: 0.0, duration: 0.0)
    let reset = SCNAction.group([moveToInitial, rotateToInitial])
    return reset
}

func createAction(forStep step: Step, previousStep: Step?, animationLength: CGFloat,
                  animationDuration: TimeInterval) -> SCNAction
{
    let stepDuration = (step.length / animationLength) * CGFloat(animationDuration)
    let moveBy = CGPoint(step.vec).positionIn3D
    let move = SCNAction.move(by: moveBy, duration: TimeInterval(stepDuration))
    if let prevStep = previousStep {
        let rotationAngle = prevStep.vec.angle(with: step.vec)
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat(rotationAngle), z: 0, duration: 0)
        return SCNAction.sequence([rotate, move])
    } else {
        return move
    }
}

func createPolyline(forRoute route: [CGPoint], withAnimationLength animationLength: Float, animationDuration: TimeInterval = 2.0) -> [SCNNode] {
    let animations = divideRoute(route: route, toAnimationsOfLength: animationLength)
    let nodesCount = animations.count
    var nodes: [SCNNode] = []
    for index in 0..<nodesCount {
        let animation = animations[index]
        let stepsLength = animation.steps.map { $0.length }.reduce(0, +)
        let arrow = SCNNode(geometry: RouteGeometryFactory.arrowBlue())
        guard let firstStep = animation.steps.first else { continue }

        let reset = createResetAction(firstStep: firstStep)
        var stepActions: [SCNAction] = []
        for stepIndex in 0..<animation.steps.count {
            let step = animation.steps[stepIndex]
            let prevStep = animation.steps[safe: stepIndex - 1]
            let stepAction = createAction(forStep: step, previousStep: prevStep,
                                          animationLength: stepsLength, animationDuration: animationDuration)
            stepActions.append(stepAction)
        }
        arrow.runAction(SCNAction.repeatForever(SCNAction.sequence([reset] + stepActions)))
        nodes.append(arrow)
    }
    return nodes
}
