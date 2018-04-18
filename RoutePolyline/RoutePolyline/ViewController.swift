//
//  ViewController.swift
//  RoutePolyline
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import UIKit
import SceneKit

struct RouteConstants {
    static let distanceBetweenArrows: Float = 5.0
}

class ViewController: UIViewController, SCNSceneRendererDelegate {

    var sceneView: SCNView!
    var restart: UIButton = UIButton(type: .system)
    var hideNodesButton: UIButton = UIButton(type: .system)
    var showNodesButton: UIButton = UIButton(type: .system)
    var showNextNodeButton: UIButton = UIButton(type: .system)

    var polylineNodes: [SCNNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromParentNode() }
            polylineNodes.forEach { sceneView.scene?.rootNode.addChildNode($0) }
        }
    }

    var animationStepNodes: [SCNNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromParentNode() }
            animationStepNodes.forEach { sceneView.scene?.rootNode.addChildNode($0) }
        }
    }

    var routePointNodes: [SCNNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromParentNode() }
            routePointNodes.forEach { sceneView.scene?.rootNode.addChildNode($0) }
        }
    }

    func update() {
        // Здесь x - по оси Z в SceneKit, y - по оси X в SceneKit (ось Y SceneKit смотрит при этом вверх)
        let route: [CGPoint] = [
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
        polylineNodes = createPolyline(forRoute: route, withAnimationLength: RouteConstants.distanceBetweenArrows)
        let representation = createRepresentation(forRoute: route, withAnimationLength: RouteConstants.distanceBetweenArrows)
        routePointNodes = representation.routeNodes
        animationStepNodes = representation.animationNodes
    }

    @objc func hideTapped() {
        polylineNodes.forEach { $0.isHidden = true }
    }

    @objc func showTapped() {
        polylineNodes.forEach { $0.isHidden = false }
    }

    @objc func refreshTapped() {
        update()
    }

    @objc func showNextNodeTapped() {
        for polylineNode in polylineNodes {
            if polylineNode.isHidden {
                polylineNode.isHidden = false
                break
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView = SCNView()
        view.addSubview(sceneView)

        // Set the view's delegate
        sceneView.delegate = self

        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene
        sceneView.showsStatistics = false
        sceneView.debugOptions = []
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true

        update()

        let axises: SCNNode = RouteGeometryFactory.axesNode(quiverLength: 4.0, quiverThickness: 0.5)
        scene.rootNode.addChildNode(axises)

        // Buttons

        hideNodesButton.setTitle("Hide all", for: .normal)
        hideNodesButton.addTarget(self, action: #selector(hideTapped), for: .touchUpInside)

        showNodesButton.setTitle("Show all", for: .normal)
        showNodesButton.addTarget(self, action: #selector(showTapped), for: .touchUpInside)

        restart.setTitle("Refresh", for: .normal)
        restart.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)

        showNextNodeButton.setTitle("Show next", for: .normal)
        showNextNodeButton.addTarget(self, action: #selector(showNextNodeTapped), for: .touchUpInside)

        [hideNodesButton, showNodesButton, restart, showNextNodeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        }

        restart.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        showNextNodeButton.leftAnchor.constraint(equalTo: restart.rightAnchor, constant: 8.0).isActive = true
        hideNodesButton.leftAnchor.constraint(equalTo: showNextNodeButton.rightAnchor, constant: 8.0).isActive = true
        showNodesButton.leftAnchor.constraint(equalTo: hideNodesButton.rightAnchor, constant: 8.0).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneView.frame = self.view.bounds
    }


}

