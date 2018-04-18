//
//  ViewController.swift
//  PedestrianARNavigation
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import MapKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    func update(withRoute route: MKRoute) {
        let routePointsCount = route.polyline.pointCount
        let routePoints = route.polyline.points()
        var geoRoute: [CLLocationCoordinate2D] = []
        for pointIndex in 0..<routePointsCount {
            let point: MKMapPoint = routePoints[pointIndex]
            geoRoute.append(MKCoordinateForMapPoint(point))
        }

        let route = geoRoute
            .map { engine.convert(coordinate: $0) }
            .flatMap { $0 }
            .map { CGPoint(position: $0) }

        guard route.count == geoRoute.count else {
            return
        }

        polylineNodes = createPolyline(forRoute: route, withAnimationLength: Constants.distanceBetweenArrows)
        let representation = createRepresentation(forRoute: route, withAnimationLength: Constants.distanceBetweenArrows)
        routePointNodes = representation.routeNodes


        guard let routeFinishPoint = route.last else { return }

        // Create node for last route point

        routeFinishNode = SCNNode()
        routeFinishNode?.position = routeFinishPoint.positionIn3D

        // Create route finish view and hint

        routeFinishHint = makeFinishNodeHint()
        routeFinishView = makeFinishNodeView()
        routeDistanceLabel = makeDistanceLabel()
    }


    @objc func onRouteUISwitchValueChanged(_ sender: UISwitch) {
        polylineNodes.forEach { $0.isHidden = !sender.isOn }
        routeFinishHint?.isHidden = !sender.isOn
        routeFinishView?.isHidden = !sender.isOn
    }

    @objc func onRoutePointsSwitchValueChanged(_ sender: UISwitch) {
        routePointNodes.forEach { $0.isHidden = !sender.isOn }
    }

    @objc func onSetDestinationTapped() {
        let mapVc = MapViewController()
        mapVc.delegate = self
        self.present(mapVc, animated: true, completion: nil)
    }

    
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
        sceneView.autoenablesDefaultLighting = true

        let axises: SCNNode = RouteGeometryFactory.axesNode(quiverLength: 1.0, quiverThickness: 0.5)
        scene.rootNode.addChildNode(axises)

        // Buttons

        setDestinationButton.setTitle("Destination", for: .normal)
        setDestinationButton.addTarget(self, action: #selector(onSetDestinationTapped), for: .touchUpInside)
        [setDestinationButton].forEach {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            $0.setTitleColor(UIColor.white, for: .normal)
        }

        routeUILabel.text = "Route UI"
        routePointsLabel.text = "Route"

        routeUISwitch.addTarget(self, action: #selector(onRouteUISwitchValueChanged), for: .valueChanged)
        routePointsSwitch.addTarget(self, action: #selector(onRoutePointsSwitchValueChanged), for: .valueChanged)

        let settingsViews: [UIView] = [setDestinationButton, routeUILabel, routeUISwitch, routePointsLabel, routePointsSwitch]

        settingsViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [routeUILabel, routePointsLabel].forEach {
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            $0.textColor = UIColor.black
        }

        routeUILabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0).isActive = true
        routeUILabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0).isActive = true
        view.addHorizontalSpacing(8.0, items: [routeUILabel, routeUISwitch, routePointsLabel,
                                               routePointsSwitch])
        view.addEquality(of: .centerY, items: [routeUILabel, routeUISwitch, routePointsLabel,
                                               routePointsSwitch])
        setDestinationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0).isActive = true
        setDestinationButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0).isActive = true
        setDestinationButton.widthAnchor.constraint(equalToConstant: 125.0).isActive = true
        setDestinationButton.heightAnchor.constraint(equalToConstant: 75.0).isActive = true


        engine = ARKitCoreLocationEngineImpl(
            view: sceneView,
            locationManager: NativeLocationManager.sharedInstance,
            locationEstimatesHolder: AdvancedLocationEstimatesHolder()
        )

        routeUISwitch.isOn = true
        routePointsSwitch.isOn = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate


    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let routeFinishNode = routeFinishNode else { return }
        guard let parent = routeFinishNode.parent else { return }
        guard let pointOfView = renderer.pointOfView else { return }

        let bounds = UIScreen.main.bounds

        let positionInWorld = routeFinishNode.worldPosition
        let positionInPOV = parent.convertPosition(routeFinishNode.position, to: pointOfView)
        let projection = sceneView.projectPoint(positionInWorld)
        let projectionPoint = CGPoint(x: CGFloat(projection.x), y: CGFloat(projection.y))

        let annotationPositionInRFN = SCNVector3Make(0.0, 1.0, 0.0) // in Route finish node coord. system
        let annotationPositionInWorld = routeFinishNode.convertPosition(annotationPositionInRFN, to: nil)
        let annotationProjection = sceneView.projectPoint(annotationPositionInWorld)
        let annotationProjectionPoint = CGPoint(x: CGFloat(annotationProjection.x), y: CGFloat(annotationProjection.y))
        let rotationAngle = Vector2.y.angle(with: (Vector2(annotationProjectionPoint) - Vector2(projectionPoint)))

        let screenMidToProjectionLine = CGLine(point1: bounds.mid, point2: projectionPoint)
        let intersection = screenMidToProjectionLine.intersection(withRect: bounds)

        let povWorldPosition: Vector3 = Vector3(pointOfView.worldPosition)
        let routeFinishWorldPosition: Vector3 = Vector3(positionInWorld)
        let distanceToFinishNode = (povWorldPosition - routeFinishWorldPosition).length

        DispatchQueue.main.async { [weak self] in
            guard let slf = self else { return }
            guard let routeFinishHint = slf.routeFinishHint else { return }
            guard let routeFinishView = slf.routeFinishView else { return }
            guard let routeDistanceLabel = slf.routeDistanceLabel else { return }
            let placemarkSize = slf.finishPlacemarkSize(
                forDistance: CGFloat(distanceToFinishNode),
                closeDistance: 10.0,
                farDistance: 25.0,
                minSize: 50.0,
                maxSize: 100.0
            )

            let distance = floor(distanceToFinishNode)

            let point: CGPoint = intersection ?? projectionPoint
            let isInFront = positionInPOV.z < 0
            let isProjectionInScreenBounds: Bool = intersection == nil

            if slf.routeUISwitch.isOn {
                routeFinishHint.isHidden = (isInFront && intersection == nil)
                routeFinishView.isHidden = !routeFinishHint.isHidden
                routeDistanceLabel.isHidden = routeFinishView.isHidden
            } else {
                routeFinishHint.isHidden = true
                routeFinishView.isHidden = true
                routeDistanceLabel.isHidden = true
            }

            if isInFront {
                routeFinishHint.center = point
            } else {
                if isProjectionInScreenBounds {
                    routeFinishHint.center = CGPoint(
                        x: reflect(point.x, of: bounds.mid.x),
                        y: bounds.height
                    )
                } else {
                    routeFinishHint.center = CGPoint(
                        x: reflect(point.x, of: bounds.mid.x),
                        y: reflect(point.y, of: bounds.mid.y)
                    )
                }
            }

            routeFinishView.center = projectionPoint
            routeFinishView.bounds.size = CGSize(width: placemarkSize, height: placemarkSize)
            routeFinishView.layer.cornerRadius = placemarkSize / 2

            let distanceString = "\(distance) м"
            let distanceAttrStr = ViewController.distanceText(forString: distanceString)
            routeDistanceLabel.attributedText = distanceAttrStr
            routeDistanceLabel.center = projectionPoint
            let size = distanceAttrStr.boundingSize(width: .greatestFiniteMagnitude)
            routeDistanceLabel.bounds.size = size
            routeDistanceLabel.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle - .pi))
        }
    }

    var engine: ARKitCoreLocationEngine!

    var setDestinationButton: UIButton = UIButton(type: .system)
    var routePointsLabel: UILabel = UILabel()
    var routeUILabel: UILabel = UILabel()
    var routePointsSwitch: UISwitch = UISwitch()
    var routeUISwitch: UISwitch = UISwitch()

    var polylineNodes: [SCNNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromParentNode() }
            polylineNodes.forEach {
                sceneView.scene.rootNode.addChildNode($0)
                $0.isHidden = !routeUISwitch.isOn
            }
        }
    }

    var routePointNodes: [SCNNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromParentNode() }
            routePointNodes.forEach {
                sceneView.scene.rootNode.addChildNode($0)
                $0.isHidden = !routePointsSwitch.isOn
            }
        }
    }

    var routeFinishNode: SCNNode? = nil {
        didSet {
            oldValue?.removeFromParentNode()
            if let node = routeFinishNode {
                sceneView.scene.rootNode.addChildNode(node)
            }
        }
    }

    var routeFinishView: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let routeFinishView = routeFinishView {
                view.addSubview(routeFinishView)
                routeFinishView.isHidden = !routeUISwitch.isOn
            }
        }
    }

    var routeDistanceLabel: UILabel? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let label = routeDistanceLabel {
                view.addSubview(label)
                label.isHidden = !routeUISwitch.isOn
            }
        }
    }

    var routeFinishHint: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let hintView = routeFinishHint {
                view.addSubview(hintView)
                hintView.isHidden = !routeUISwitch.isOn
            }
        }
    }
}

extension ViewController: MapViewControllerDelegate {
    func viewController(_ mapVc: MapViewController, didSetDestination destination: CLLocationCoordinate2D) {
        guard let userLocation = engine.userLocationEstimate()?.location.coordinate else { return }
        let request = MKDirectionsRequest.init()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] (response, error) -> Void in
            guard let slf = self else { return }
            guard let response = response else { return }
            guard let route = response.routes.first else { return }
            slf.update(withRoute: route)
        }
    }
}

fileprivate extension ViewController {

    static func distanceText(forString string: String) -> NSAttributedString {
        return NSMutableAttributedString(string: string, attributes: [
            .strokeColor : UIColor.black,
            .foregroundColor : UIColor.white,
            .strokeWidth : -1.0,
            .font : UIFont.boldSystemFont(ofSize: 32.0)
            ])
    }

    func makeFinishNodeView() -> UIView {
        let nodeView = UIView()
        nodeView.backgroundColor = UIColor.green
        return nodeView
    }

    func makeFinishNodeHint() -> UIView {
        let hintView = UIView()
        hintView.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
        hintView.layer.cornerRadius = 25.0
        hintView.backgroundColor = UIColor.red
        return hintView
    }

    func makeDistanceLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32.0, weight: .bold)
        label.numberOfLines = 1
        label.layer.shadowRadius = 2.0
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize.zero
        return label
    }

    /// RouteFinishPlacemark size driven by design requirements
    ///
    /// - Parameters:
    ///   - distance: distance to route finish
    func finishPlacemarkSize(forDistance distance: CGFloat, closeDistance: CGFloat, farDistance: CGFloat,
                             minSize: CGFloat, maxSize: CGFloat) -> CGFloat
    {
        guard closeDistance >= 0 else { assert(false); return 0.0 }
        guard closeDistance >= 0, farDistance >= 0, closeDistance <= farDistance else { assert(false); return 0.0 }

        if distance > farDistance {
            return minSize
        } else if distance < closeDistance{
            return maxSize
        } else {
            let delta = maxSize - minSize
            let percent: CGFloat = ((distance - closeDistance) / (farDistance - closeDistance))
            let size = minSize + delta * percent
            return size
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
}
