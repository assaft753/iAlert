//
//  ViewController.swift
//  TurnByTurn2
//
//  Created by Sapir Kaplan on 10/07/2018.
//  Copyright © 2018 Sapir Kaplan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

class MapViewController: UIViewController {

    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func startBtn(_ sender: UIButton) {  }
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate:CLLocationCoordinate2D!
    let TITLE = "Safe Place"
    var address:String!
    var steps = [MKRouteStep]()
    let speechSyntheizer = AVSpeechSynthesizer()
    var stepCounter = 0
    var timer:Timer!
    var countDown = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showDirections()
    }
    
    @objc
    func countDownAction(){
        countDown -= 1
        timeLeftLabel.text = "Time left: \(countDown)"
        if countDown == 0 {
            timer.invalidate()
        }
    }
    
    func showDirections() {
        let direction = setDirectionsValues()
        
        direction.calculate { (response, _) in
            guard let response = response else {return}
            guard let primaryRoute = response.routes.first else {return}
            self.mapView.add(primaryRoute.polyline) // Call the renderer extension
            
            //Get fresh directions
            //To avoid doubles
            //self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
            
            //Turn by turn directions
            self.turnByTurnDirections(primaryRoute: primaryRoute)
            
            //Set directions
            self.setDirections()
        }
        
        //Set time left
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownAction), userInfo: nil, repeats: true)
    }
    
    func setDirectionsValues() -> MKDirections {
        //This will make zoom in automaticly when running the application
        let region = MKCoordinateRegion(center: currentCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
        mapView.userTrackingMode = .followWithHeading
        
        let directionsRequest = MKDirectionsRequest()
        
        directionsRequest.source = source()
        directionsRequest.destination = destination()
        directionsRequest.transportType = .walking
        
        return MKDirections(request: directionsRequest)
    }
    
    func source() -> MKMapItem {
        let sourcePlaceMark = MKPlacemark(coordinate: currentCoordinate)
        return MKMapItem(placemark: sourcePlaceMark)
    }
    
    func destination() -> MKMapItem {
        //Create annotation for destination
        let destinationAnnotation = Annotation(coordinate: destinationCoordinate, title: TITLE, subtitle: address)
        mapView.addAnnotation(destinationAnnotation)
        
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate)
        return MKMapItem(placemark: destinationPlaceMark)
    }
    
    func turnByTurnDirections(primaryRoute:MKRoute!){
        steps = primaryRoute.steps
        for i in 0..<primaryRoute.steps.count{
            let step = primaryRoute.steps[i]
            let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
            locationManager.startMonitoring(for: region)
            
            //Show the directions instructions
            let circle = MKCircle(center: region.center, radius: region.radius)
            mapView.add(circle)
        }
    }
    
    func setDirections(){
        //Set text directions
        let initialMessage = "In \(steps[1].distance) meters, \(steps[1].instructions) then in \(steps[2].distance) meters, \(steps[2].instructions)."
        directionsLabel.text = initialMessage
        
        //Set speech directions
        setSpeechDirections(initialMessage: initialMessage)
    }
    
    func setSpeechDirections(initialMessage:String) {
        let speechUtterance = AVSpeechUtterance(string: initialMessage)
        self.speechSyntheizer.speak(speechUtterance)
        self.stepCounter += 1
    }
}

//This extension will happen when updating location from viewDidLoad - to get user current location
extension MapViewController: CLLocationManagerDelegate{
    /*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        //Get user current location
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        
        //Zoom in to user location
//        mapView.userTrackingMode = .followWithHeading //The followWithHeading means that when ever you move the phone it will point the map in the direction that you are looking instead of just pointing it to north
    }*/
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("stepCounter = \(stepCounter)")
        stepCounter += 1
        if stepCounter < steps.count{
            let currentStep = steps[stepCounter]
            let message = "In \(currentStep.distance) meters, \(currentStep.instructions)"
            directionsLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSyntheizer.speak(speechUtterance)
        }
        else{
            let message = "Arrived to destination"
            directionsLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSyntheizer.speak(speechUtterance)
            stepCounter = 1
            locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapView.camera.heading = newHeading.magneticHeading
        mapView.setCamera(mapView.camera, animated: true)
    }
}

//This extension will happen when we want to display things on the screen
extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //This extension will happen when we want to display the location on the screen
        if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 7
            return renderer
        }
        
        //This extension will happen when we want to display the directions on the screen
        if overlay is MKCircle{
            let renderer = MKCircleRenderer(overlay: overlay)
          //  renderer.strokeColor = .red
//            renderer.fillColor = .red
//            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}


//Create an annotation object
final class Annotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
}
