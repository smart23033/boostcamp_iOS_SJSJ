//
//  MapViewController.swift
//  WorldTrotter
//
//  Created by 김성준 on 2017. 7. 7..
//  Copyright © 2017년 김성준. All rights reserved.
//

import UIKit
import MapKit

struct myLocation {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, lat latitude: Double, long longitude: Double){
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    var mapView: MKMapView!
    var locationManager : CLLocationManager!
    var currentLocationButton: UIButton!
    var pinControlButton: UIButton!
    var myLocations: [myLocation] = []
    var selectedAnnotationIndex: Int = -1
    var savedLocation = CLLocation()
    
    // MARK: View
    
    override func loadView() {
        
        mapView = MKMapView()
        mapView.delegate = self
        
        view = mapView
        
        let segmentedControl = UISegmentedControl(items: ["Standard", "Hybrid", "Satellite"])
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.addTarget(self, action: #selector(mapTypeChanged(segControl:)), for: .valueChanged)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        let segmentedControlTopConstraint = segmentedControl.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8)
        let segmentedControlLeadingConstraint = segmentedControl.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        let segmentedControlTrailingConstraint = segmentedControl.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        
        segmentedControlTopConstraint.isActive = true
        segmentedControlLeadingConstraint.isActive = true
        segmentedControlTrailingConstraint.isActive = true
        
        currentLocationButton = UIButton(type: .custom)
        currentLocationButton.setImage(#imageLiteral(resourceName: "CurrentLocation"), for: .normal)
        
        currentLocationButton.addTarget(self, action: #selector(updateUserLocation), for: .touchUpInside)
        
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentLocationButton)
        
        let locationButtonTopConstraint
            = currentLocationButton.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20)
        let locationButtonTrailingConstraint
            = currentLocationButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -5)
        
        locationButtonTopConstraint.isActive = true
        locationButtonTrailingConstraint.isActive = true
        
        myLocations.append(myLocation(name: "Hometown", lat: 37.210407662727205, long: 127.11465741532114532114))
        //        myLocations.append(myLocation(name: "CurrentLocation", lat: 37.610407662727205, long: 127.01465741532114532114))
        myLocations.append(myLocation(name: "InterestingPlace", lat: 37.010407662727205, long: 127.05465741532114532114))
        
        for location in myLocations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            annotation.title = location.name
            mapView.addAnnotation(annotation)
        }
        
        pinControlButton = UIButton(type: .infoLight)
        
        pinControlButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinControlButton)
        
        pinControlButton.addTarget(self, action: #selector(showNextPin), for: .touchUpInside)
        
        let pinControlButtonTopConstraint = pinControlButton.topAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: 20)
        let pinControlButtonTrailingConstraint = pinControlButton.trailingAnchor.constraint(equalTo: currentLocationButton.trailingAnchor)
        
        pinControlButtonTopConstraint.isActive = true
        pinControlButtonTrailingConstraint.isActive = true
        
        let addPinButton = UIButton(type: .contactAdd)
        
        addPinButton.addTarget(self, action: #selector(addCurrentLocation), for: .touchUpInside)
        
        addPinButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addPinButton)
        
        let addPinButtonTopConstraint
            = addPinButton.topAnchor.constraint(equalTo: pinControlButton.bottomAnchor, constant: 20)
        let addPinButtonTrailingConstraint
            = addPinButton.trailingAnchor.constraint(equalTo: pinControlButton.trailingAnchor)
        
        addPinButtonTopConstraint.isActive = true
        addPinButtonTrailingConstraint.isActive = true
        
        let distanceButton = UIButton(type: .detailDisclosure)
        
        distanceButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(distanceButton)
        
        distanceButton.addTarget(self, action: #selector(getDistance), for: .touchUpInside)
        
        let distanceButtonTopConstraint = distanceButton.topAnchor.constraint(equalTo: addPinButton.bottomAnchor, constant: 20)
        let distanceButtonTrailingConstraint = distanceButton.trailingAnchor.constraint(equalTo: addPinButton.trailingAnchor)
        
        distanceButtonTopConstraint.isActive = true
        distanceButtonTrailingConstraint.isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MapViewController loaded its view")
        
    }
    
    // MARK: Methods
    
    // Get distance from savedLocation
    func getDistance(){
        
        updateUserLocation()
        
        let currentLocation = mapView.userLocation.location
       
        if let currentLocation = currentLocation, savedLocation != currentLocation {
            
            print(savedLocation.distance(from: currentLocation))

        }
        
    }
    
    // Add annotation at currentLocation
    func addCurrentLocation() {

        updateUserLocation()
        
        let currentLocation = mapView.userLocation.location
        
        if let currentLocation = currentLocation {
            let location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            
            print("currentLocation : \(location)")
            
            let span = MKCoordinateSpanMake(0.04, 0.04)
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
            
            savedLocation = currentLocation
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            annotation.title = "CurrentLocation"
            mapView.addAnnotation(annotation)
        }
        
    }
    
    // Change map type when segmented control value is changed
    func mapTypeChanged(segControl: UISegmentedControl){
        switch segControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            break
        }
    }
    
    // Update user location when currentLocationButton is clicked
    func updateUserLocation() {
        locationManager = CLLocationManager()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
    
    }
    
    // show next annotation when pinControlButton is clicked
    func showNextPin() {
        
        guard mapView.annotations.count > 0 else {
            return
        }
        
        selectedAnnotationIndex += 1
        if selectedAnnotationIndex == mapView.annotations.count {
            selectedAnnotationIndex = 0
        }
        
        let annotation = mapView.annotations[selectedAnnotationIndex]
        mapView.selectAnnotation(annotation, animated: true)
        let zoomedInCurrentLocation = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 5000, 5000)
        mapView.setRegion(zoomedInCurrentLocation, animated: true)
        
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let currentLocation = mapView.userLocation.location
        
        if let currentLocation = currentLocation {
            let location = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            
            print("currentLocation : \(location)")
            
            let span = MKCoordinateSpanMake(0.04, 0.04)
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
            
        }
        
    }
    
}
