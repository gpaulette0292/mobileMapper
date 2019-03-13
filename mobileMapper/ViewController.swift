//
//  ViewController.swift
//  mobileMapper
//
//  Created by Grace Paulette on 3/6/19.
//  Copyright © 2019 John Hersey HIgh School. All rights reserved.
//

import UIKit
import MapKit
//import safari services if adding URL
import SafariServices

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager ()
    var currentLocation: CLLocation!
    var parks : [MKMapItem] = []
    
    //add these 2 variables to zoom out on mapview, add func below them
    var initialRegion: MKCoordinateRegion!
    var isInitialMapLoad = true
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isInitialMapLoad {
            initialRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: mapView.region.span)
            isInitialMapLoad = false
    //stop here for zoom out function
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        //how to add an image for the pin
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = UIImage(named: "slideForPin")
        pin.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        //lines below show how to add a second button
        let secondButton = UIButton(type: .contactAdd)
        pin.leftCalloutAccessoryView = secondButton
        //line below demonstrates how to add a button to the pin
        pin.rightCalloutAccessoryView = button
        return pin 
    }
    //call out and tells the info button what to do
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //start for addition of another button for when a place pops up
        let buttonPressed = control as! UIButton
        if buttonPressed.buttonType == .contactAdd {
        //added line below to zoom out of map
            mapView.setRegion(initialRegion, animated: true)
        }
        //stop here for addition of another button
        var currentMapItem = MKMapItem()
        if let title = view.annotation?.title, let parkName =  title {
            for mapItem in parks {
                if mapItem.name == parkName{
                    currentMapItem = mapItem
                }
            }
        }
        let placeMark = currentMapItem.placemark
        // do this to add street when button is pressed
        let address = placeMark.addressDictionary
        print(address?["Street"])
        //how to have the website pop up when info button is hit (3 lines below this, make sure to add safari services)
        if let url = currentMapItem.url {
           let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
            
        }
        
    }
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            currentLocation = locations[0]
            print(currentLocation)
        }
        
        @IBAction func whenZoomButtonPressed(_ sender: Any) {
            let center = currentLocation.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            
        }
        
        @IBAction func whenSearchButtonPressed(_ sender: Any) {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "Parks"
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            //change latitude and longitude to expand how many places pop up in the radius given (make sure theyre equal to or close to the other coordinates)
            request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            let search = MKLocalSearch(request: request)
            search.start { (response, error ) in
                guard let response = response else {
                    return
                }
                for mapItem in response.mapItems {
                    self.parks.append(mapItem)
                    let annotation = MKPointAnnotation ()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
        
    
}
