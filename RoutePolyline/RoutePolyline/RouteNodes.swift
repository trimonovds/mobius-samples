//
//  RouteNodes.swift
//  RoutePolyline
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation
import SceneKit

class ARSCNPathArrow: SCNGeometry {

    convenience init(material: SCNMaterial) {
        let vertices: [SCNVector3] = [
            SCNVector3Make(-0.02,  0.00,  0.00), // 0
            SCNVector3Make(-0.02,  0.50, -0.33), // 1
            SCNVector3Make(-0.10,  0.44, -0.50), // 2
            SCNVector3Make(-0.22,  0.00, -0.39), // 3
            SCNVector3Make(-0.10, -0.44, -0.50), // 4
            SCNVector3Make(-0.02, -0.50, -0.33), // 5

            SCNVector3Make( 0.02,  0.00,  0.00), // 6
            SCNVector3Make( 0.02,  0.50, -0.33), // 7
            SCNVector3Make( 0.10,  0.44, -0.50), // 8
            SCNVector3Make( 0.22,  0.00, -0.39), // 9
            SCNVector3Make( 0.10, -0.44, -0.50), // 10
            SCNVector3Make( 0.02, -0.50, -0.33), // 11
        ]

        let sources: [SCNGeometrySource] = [SCNGeometrySource(vertices: vertices)]
        let indices: [Int32] = [0,3,5, 3,4,5, 1,2,3, 0,1,3, 10,9,11, 6,11,9, 6,9,7, 9,8,7,
                                6,5,11, 6,0,5, 6,1,0, 6,7,1, 11,5,4, 11,4,10, 9,4,3, 9,10,4, 9,3,2, 9,2,8, 8,2,1, 8,1,7]
        let geometryElements = [SCNGeometryElement(indices: indices, primitiveType: .triangles)]
        self.init(sources: sources, elements: geometryElements)
        self.materials = [material]
    }

}

class RoutePointNode: SCNNode {

    public init(radius: CGFloat = 0.2, color: UIColor = UIColor.blue, transparency: CGFloat = 0.3, height: CGFloat = 0.01) {
        let cylinder = SCNCylinder(radius: radius, height: height)

        cylinder.firstMaterial?.diffuse.contents = color
        cylinder.firstMaterial?.transparency = transparency
        cylinder.firstMaterial?.lightingModel = .constant

        super.init()
        self.geometry = cylinder
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct RouteGeometryFactory {
    static func arrowBlue() -> SCNGeometry {
        let blue = SCNMaterial()
        blue.diffuse.contents = UIColor.blue
        blue.lightingModel = .constant
        return ARSCNPathArrow(material: blue)
    }

    static func axesNode(quiverLength: CGFloat, quiverThickness: CGFloat) -> SCNNode {
        let quiverThickness = (quiverLength / 50.0) * quiverThickness
        let chamferRadius = quiverThickness / 2.0

        let xQuiverBox = SCNBox(width: quiverLength, height: quiverThickness, length: quiverThickness, chamferRadius: chamferRadius)
        xQuiverBox.firstMaterial?.diffuse.contents = UIColor.red
        let xQuiverNode = SCNNode(geometry: xQuiverBox)
        xQuiverNode.position = SCNVector3Make(Float(quiverLength / 2.0), 0.0, 0.0)

        let yQuiverBox = SCNBox(width: quiverThickness, height: quiverLength, length: quiverThickness, chamferRadius: chamferRadius)
        yQuiverBox.firstMaterial?.diffuse.contents = UIColor.green
        let yQuiverNode = SCNNode(geometry: yQuiverBox)
        yQuiverNode.position = SCNVector3Make(0.0, Float(quiverLength / 2.0), 0.0)

        let zQuiverBox = SCNBox(width: quiverThickness, height: quiverThickness, length: quiverLength, chamferRadius: chamferRadius)
        zQuiverBox.firstMaterial?.diffuse.contents = UIColor.blue
        let zQuiverNode = SCNNode(geometry: zQuiverBox)
        zQuiverNode.position = SCNVector3Make(0.0, 0.0, Float(quiverLength / 2.0))

        let quiverNode = SCNNode()
        quiverNode.addChildNode(xQuiverNode)
        quiverNode.addChildNode(yQuiverNode)
        quiverNode.addChildNode(zQuiverNode)
        quiverNode.name = "Axes"
        return quiverNode
    }
}
