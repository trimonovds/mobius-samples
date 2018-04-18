//
//  ViewController.swift
//  FinishPlacemarkHelper
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene

        // Add node for route finish point

        routeFinishNode = createSphereNode(withRadius: 0.5, color: UIColor.green)
        routeFinishNode.position = SCNVector3Make(10.0, 0.0, 0.0)
        scene.rootNode.addChildNode(routeFinishNode)

        // Draw route finish placemark hint

        routeFinishHint = UIView()
        routeFinishHint.isHidden = true
        routeFinishHint.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
        routeFinishHint.layer.cornerRadius = 25.0
        routeFinishHint.backgroundColor = UIColor.red

        view.addSubview(routeFinishHint)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let parent = routeFinishNode.parent else { return }
        guard let pointOfView = renderer.pointOfView else { return }

        let bounds = UIScreen.main.bounds

        let positionInWorld = routeFinishNode.worldPosition
        let positionInPOV = parent.convertPosition(routeFinishNode.position, to: pointOfView)
        let projection = sceneView.projectPoint(positionInWorld)
        let projectionPoint = CGPoint(x: CGFloat(projection.x), y: CGFloat(projection.y))

        let screenMidToProjectionLine = CGLine(point1: bounds.mid, point2: projectionPoint)
        let intersection = screenMidToProjectionLine.intersection(withRect: bounds)

        DispatchQueue.main.async {
            let point: CGPoint = intersection ?? projectionPoint
            let isInFront = positionInPOV.z < 0
            let isProjectionInScreenBounds: Bool = intersection == nil

            self.routeFinishHint.isHidden = isInFront && intersection == nil

            if isInFront {
                self.routeFinishHint.center = point
            } else {
                if isProjectionInScreenBounds {
                    self.routeFinishHint.center = CGPoint(
                        x: reflect(point.x, of: bounds.mid.x),
                        y: bounds.height
                    )
                } else {
                    self.routeFinishHint.center = CGPoint(
                        x: reflect(point.x, of: bounds.mid.x),
                        y: reflect(point.y, of: bounds.mid.y)
                    )
                }
            }
        }
    }

    func findProjection(ofNode node: SCNNode, inSceneOfView scnView: SCNView) -> CGPoint {
        let nodeWorldPosition = node.worldPosition
        let projection = scnView.projectPoint(nodeWorldPosition)
        return CGPoint(x: CGFloat(projection.x), y: CGFloat(projection.y))
    }

    func isNodeInFrontOfCamera(_ node: SCNNode, scnView: SCNView) -> Bool {
        guard let pointOfView = scnView.pointOfView else { return false }
        guard let parent = node.parent else { return false }
        let positionInPOV = parent.convertPosition(node.position, to: pointOfView)
        return positionInPOV.z < 0
    }

    func createSphereNode(withRadius radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }

    private var routeFinishNode: SCNNode!
    private var routeFinishHint: UIView!
}
