//
//  ViewController.swift
//  AppleMapB1
//
//  Created by Jakkawad Chaiplee on 11/13/2559 BE.
//  Copyright © 2559 Jakkawad Chaiplee. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}


class ViewController: UIViewController, CLLocationManagerDelegate, HandleMapSearch, MKMapViewDelegate {

    var selectedPin:MKPlacemark? = nil
    var resultSearchController: UISearchController!
    let locationManager = CLLocationManager()
    
    var currentLocation = CLLocationCoordinate2D()
    var sourceLocation = CLLocationCoordinate2D()
    var pinLocation = MKPointAnnotation()
    var oldPin = MKPointAnnotation()
    var newPin = MKPointAnnotation()
    var destinationLocation = MKPlacemark()
    
    var speedOnWay: Double = 0.0
    var isWoring: Bool = false
    
    var distanceToDestination: Double = 0.0
    var didSelectLocation: Bool = false
    
    var updateLocation: Bool = true
    
    var viewStatus: Bool = false
    var distanceInKM: Double = 0.0
    
    var dropPin: Bool = false
    
    // Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblArrival: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var viewStart: UIView!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var imageViewStartUpdate: UIImageView!
    
    @IBAction func btnStartUpdateLocation(_ sender: UITapGestureRecognizer) {
        changeImageArrow()
        
    }
    
    @IBAction func btnStart(_ sender: UITapGestureRecognizer) {
        if didSelectLocation {
//            print("true")
            if viewStatus == false {
                print("new pin is \(newPin)")
                let newPinCoordinate = CLLocationCoordinate2D(latitude: newPin.coordinate.latitude, longitude: newPin.coordinate.longitude)
                let newPinPoint = MKPlacemark(coordinate: newPinCoordinate)
                getDirections(placemark: newPinPoint)
                endDirections(status: true)
                viewStatus = true
//                isWoring = true
            } else {
                endDirections(status: false)
                
            }
        } else {
            print("false")
            let pinAlert = UIAlertController(title: "Pin not found.", message: "please select destination.", preferredStyle: UIAlertControllerStyle.alert)
            
            pinAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//                print("Handle Ok logic here")
            }))
            present(pinAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapped(gestureReconizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureReconizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        if gestureReconizer.state == UIGestureRecognizerState.began {
//            print("tapped start")
            // Add new pin
            mapView.removeAnnotation(oldPin)
            if dropPin == false {
                // Add new pin
//                print("new pin")
                dropPin = true
                newPin = annotation
                oldPin = annotation
                mapView.addAnnotation(newPin)
                annotation.title = "\(annotation)"
            } else {
                // Remove old pin and add new pin
//                print("old pin")
                dropPin = false
                newPin = annotation
                oldPin = annotation
                mapView.addAnnotation(newPin)
                annotation.title = "\(annotation)"
            }
            didSelectLocation = true
        } else {
//            print("tapped end")
        }
    }
    
    func updateDistance() {
        if didSelectLocation {
            let twoDecimalPlaces = String(format: "%.2f", distanceToDestination)
            let tw = Double(twoDecimalPlaces)!
//            print("tw: \(tw)")
            if tw < 1.5 {
                endDirections(status: false)
                let pinAlert = UIAlertController(title: "Weak Up!!!", message: "your in place", preferredStyle: UIAlertControllerStyle.alert)
                
                pinAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//                print("Handle Ok logic here")
                }))
                present(pinAlert, animated: true, completion: nil)
            }
//            2.65456916482402
            if viewStatus {
                lblDistance.text = "\(twoDecimalPlaces)"
                lblArrival.text = "\(speedOnWay)"
            }
        }
    }
    
    func changeImageArrow() {
        if updateLocation {
            updateLocation = false
            imageViewStartUpdate.image = UIImage(named: "location")
        } else {
            updateLocation = true
            imageViewStartUpdate.image = UIImage(named: "location-arrow")
        }
    }
    
    func endDirections(status: Bool) {
        if status == false  {
            viewStart.backgroundColor = UIColor.green
            lblStart.text = "Start"
            viewStatus = false
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
            mapView.removeAnnotation(newPin)
            lblDistance.text = "0.0"
//            isWoring = false
            didSelectLocation = false
            if updateLocation {
                
            } else {
                updateLocation = false
                changeImageArrow()
            }
        } else {
            viewStart.backgroundColor = UIColor.red
            lblStart.text = "End"
            changeImageArrow()
//            isWoring = true
        }
    }
    
    func getDirections(placemark: MKPlacemark) {
        updateLocation = false
        changeImageArrow()
        print("getDirections: \(placemark)")
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
//        print("PlaceMark: \(placemark)")
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
//        print("sourceLocation: \(sourcePlacemark)")
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//        print("sourcePlacemark: \(sourcePlacemark)")
        let sourceAnnotation = MKPointAnnotation()
//        sourceAnnotation.title = "Times Square"
        let destinationMapItem = MKMapItem(placemark: placemark)
//        print("destinationMapItem: \(destinationMapItem)")
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
//            print("time: \(route.expectedTravelTime)")
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
//        let smallSquare = CGSize(width: 30, height: 30)
//        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
//        button.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
//        button.addTarget(self, action: #selector(ViewController.getDirections), for: .touchUpInside)
//        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    func dropPinZoomIn(_ placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name

        // Set Camera to destination location
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.30, 0.30)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if updateLocation {
            if let location = locations.first {
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        } else {
            
        }
        if let location = locations.first {
//            print("location: \(location.speed)")
            
            speedOnWay = location.speed
//            sourceLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            print("source: \(sourceLocation)")
//            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
//                    print("sourceLocation: \(sourcePlacemark)")
//            let sourcePlaceMark
//            currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.latitude)
//            print("currentLocation: \(currentLocation)")
//            let span = MKCoordinateSpanMake(0.05, 0.05)
//            let region = MKCoordinateRegion(center: location.coordinate, span: span)
//            mapView.setRegion(region, animated: true)
            distanceToDestination = getBetweenPoint(p1Lati: newPin.coordinate.latitude, p1Long: newPin.coordinate.longitude, p2Lati: sourceLocation.latitude, p2Long: sourceLocation.longitude)
            updateDistance()
        }
//        print("didUpdateLocations")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        print("newPin: \(newPin.coordinate.latitude)")
        // Status view
        lblDistance.text = "0.0"
        lblTime.text = "15"
        lblArrival.text = "0.0"
        
        // MapView
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        
        // LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        // SearchTable
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

