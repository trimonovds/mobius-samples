//
//  MapViewController.swift
//  PedestrianARNavigation
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate: class {
    func viewController(_ mapVc: MapViewController, didSetDestination destination: CLLocationCoordinate2D)
}

class MapViewController: UIViewController, MKMapViewDelegate {

    weak var delegate: MapViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        map = MKMapView()
        map.delegate = self
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(setDestination))
        map.addGestureRecognizer(longPressGestureRecognizer)
        view.addSubview(map)

        doneButton = UIButton(type: .system)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)

        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(onDoneTapped), for: .touchUpInside)
        [doneButton].forEach {
            $0?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            $0?.setTitleColor(UIColor.white, for: .normal)
        }
        doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0).isActive = true
        doneButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 75.0).isActive = true

        NativeLocationManager.sharedInstance.addListener(self)

        userLocationAnnotation.title = "My Location"
        map.addAnnotation(userLocationAnnotation)
    }

    @objc func setDestination(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: map)
            let touchLocation = map.convert(touchPoint, toCoordinateFrom: map)
            lastDestination = touchLocation

            if let prevAnnotation = destinationAnnotation {
                map.removeAnnotation(prevAnnotation)
            }

            let annotation = MKPointAnnotation()
            annotation.coordinate = touchLocation
            annotation.title = "Destination"
            map.addAnnotation(annotation)
            destinationAnnotation = annotation
        }
    }

    @objc func onDoneTapped(_ sender: UIButton) {
        if let coordinate = lastDestination {
            self.delegate?.viewController(self, didSetDestination: coordinate)
        }

        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = self.view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let userCoordinate = NativeLocationManager.sharedInstance.location?.coordinate {
            updateUserLocationAnnotation(withCoordinate: userCoordinate)
            let region = MKCoordinateRegion(center: userCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.map.setRegion(region, animated: true)
        }
    }

    private var map: MKMapView!
    private var doneButton: UIButton!
    private var lastDestination: CLLocationCoordinate2D? = nil
    private var userLocationAnnotation: MKPointAnnotation = MKPointAnnotation()
    private var destinationAnnotation: MKPointAnnotation? = nil
}

extension MapViewController: LocationManagerListener {

    func onLocationUpdate(_ location: CLLocation) {
        updateUserLocationAnnotation(withCoordinate: location.coordinate)

    }

    func onAuthorizationStatusUpdate(_ authorizationStatus: CLAuthorizationStatus) {
    }

    func updateUserLocationAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
        userLocationAnnotation.coordinate = coordinate
    }

}
