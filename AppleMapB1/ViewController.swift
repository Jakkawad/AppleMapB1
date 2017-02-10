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
    
    var currentLocation = CLLocation()
    var sourceLocation = CLLocationCoordinate2D()
    var pinLocation = MKPointAnnotation()
    var oldPin = MKPointAnnotation()
    var newPin = MKPointAnnotation()
    var destinationLocation = MKPlacemark()
    
    var dropPin: Bool = false
    
    @IBOutlet weak var mapView: MKMapView!
    
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
        } else {
//            print("tapped end")
        }
    }
    
    
    func calculateSegmentDirections(index: Int) {
//        let request: MKDirectionsRequest = MKDirectionsRequest()
        
    }
    
    func getDirections(){
//        guard let selectedPin = selectedPin else { return }
//        let mapItem = MKMapItem(placemark: selectedPin)
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        mapItem.openInMaps(launchOptions: launchOptions)
        print("getDirections")
        
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
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        
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
        
//        print("PlaceMark: \(placemark)")
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
//        print("sourceLocation: \(sourcePlacemark)")
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//        print("sourcePlacemark: \(sourcePlacemark)")
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Times Square"
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
//            print("route: \(route)")
            print(route.distance)
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
//            print("rect: \(rect)")
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
//            print("location: \(location)")
            sourceLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            print("source: \(sourceLocation)")
//            currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.latitude)
//            print("currentLocation: \(currentLocation)")
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
        }
        
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
        
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        
        // LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
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

