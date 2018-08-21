//
//  ViewController.swift
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
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var directionView: UIView!
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
        createBlurView()
        initLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showDirections()
        addMapViewLocationButton()
    }
    
    @IBAction func finishBtn(_ sender: UIButton) {
        prepareForPop()
        navigationController?.popToRootViewController(animated: true)
    }
    
    func createBlurView() {
        let blurView = UIView(frame:directionView.bounds)
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = blurView.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(visualEffectView)
        blurView.backgroundColor = #colorLiteral(red: 0.9786400199, green: 0.3367310166, blue: 0.3028771579, alpha: 0.06903681505)
        containerView.insertSubview(blurView, belowSubview: directionView)
    }
    
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.dismissHeadingCalibrationDisplay()
        mapView.showsCompass = false
    }
    
    func prepareForPop()
    {
        speechSyntheizer.stopSpeaking(at: .immediate)
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
        locationManager.delegate = nil
        mapView.delegate = nil
    }
    
    func addMapViewLocationButton()
    {
        let trackingButton: MKUserTrackingBarButtonItem = MKUserTrackingBarButtonItem.init(mapView: mapView)
        let originPoint: CGPoint = CGPoint(x: mapView.bounds.width-70,y: mapView.bounds.height-85)
        
        let roundedSquare: UIView = UIView(frame: CGRect(origin: originPoint, size: CGSize(width: 55, height: 55)))
        
        roundedSquare.backgroundColor = UIColor.clear
        roundedSquare.layer.cornerRadius = 10
        roundedSquare.layer.masksToBounds = true
        
        let toolBarFrame = CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: 55, height: 55))
        let toolbar = UIToolbar.init(frame: toolBarFrame)
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.items = [flex,trackingButton,flex]
        roundedSquare.addSubview(toolbar)
        mapView.addSubview(roundedSquare)
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
            self.mapView.add(primaryRoute.polyline)
            
            //Get fresh directions
            //To avoid doubles
            self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
            
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
        let region = MKCoordinateRegion(center: currentCoordinate, span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        
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
}

//This extension will happen when we want to display things on the screen
extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //This extension will happen when we want to display the location on the screen
        if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.9786400199, green: 0.3367310166, blue: 0.3028771579, alpha: 1)
            renderer.lineWidth = 7
            return renderer
        }
        
        //This extension will happen when we want to display the directions on the screen
        if overlay is MKCircle{
            let renderer = MKCircleRenderer(overlay: overlay)
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
