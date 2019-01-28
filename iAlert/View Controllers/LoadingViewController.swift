//
//  LoadingViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 11/08/2018.
//  Copyright © 2018 Assaf Tayouri. All rights reserved.
//

import UIKit
import CoreLocation

class LoadingViewController: UIViewController
{
    
    @IBOutlet weak var navigateBtn: UIButton!
    @IBOutlet weak var radioTowerImage: UIImageView!
    @IBOutlet weak var pulseContainer: UIView!
    var isProccessing:Bool = false
    var safePlace:SafePlace?
    var toTakeLocation:Bool!
    let locationManager = CLLocationManager()
    let pulsator = Pulsator()
    var showNavigate:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toShowNavigateButton()
        initialPulseAnimation()
        toTakeLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        toTakeLocation = true
        super.viewWillAppear(animated)
        if !showNavigate
        {
            pulsator.start()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.delegate = nil
        
    }
    
    func toShowNavigateButton()
    {
        if self.showNavigate
        {
            navigateBtn.alpha = 1
            toTakeLocation = true
            navigateBtn.isEnabled = true
            pulsator.stop()
        }
        else
        {
            navigateBtn.alpha = 0
            navigateBtn.isEnabled = false
        }
    }
    
    @IBAction func navigateBtnPressed(_ sender: Any){
       activateCurrentLocation()
    }
    
    func activateCurrentLocation()
    {
        isProccessing = true
        navigateBtn.isEnabled = false
        self.pulsator.start()
        UIView.animate(withDuration: 0.5, animations: {
            self.navigateBtn.alpha = 0
        }) { (_) in
            self.takeCurrentLocation()
        }
    }
    
    func findMinDistanceSafePlace(safePlaces:[SafePlace],currentLocation:CLLocation)->SafePlace?
    {
        let currentXY = Utilities.degreeToXY(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        var minDistance:Double = -1
        var minSafePlace:SafePlace?
        for safePlace in safePlaces {
            let distance = Utilities.distanceBetweenTwoPoints(point1: currentXY, point2: safePlace.toXY())
            if distance <= ConstsKey.BOUND
            {
                if minDistance == -1 || distance < minDistance
                {
                    minSafePlace = safePlace
                    minDistance = distance
                }
            }
        }
        return minSafePlace
    }
    
    func loadShelterLocally(currentLocation:CLLocation)
    {
        print(currentLocation)
        if let safePlaces = iAlertService.shared.loadShelters(),let minSafePlace = findMinDistanceSafePlace(safePlaces: safePlaces, currentLocation: currentLocation)
        {
            let mapViewController = self.storyboard!.instantiateViewController(withIdentifier: "Map Controller") as! MapViewController
            mapViewController.safePlace = minSafePlace
            mapViewController.currentCoordinate = currentLocation.coordinate
            mapViewController.isRedAlertId = false
            push(to: mapViewController)
        }
            
        else{
            let instructionViewController = self.storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
            push(to: instructionViewController)
            self.showNavigate = true
            self.toShowNavigateButton()
        }
    }
    
    
    func loadSheltersRemotelyForNotification(fcmToken:String,currentLocation:CLLocation)
    {
        iAlertService.shared.fetch(type: .ClosestsShelter(uniqueId: fcmToken, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, redAlertId: safePlace!.redAlertId)) { [weak self,currentLocation] (data, err, response) in
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode < 400
                {
                    print("in fetch \(try? JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] )")
                    
                    var viewCtrl:UIViewController!
                    if let data = data, let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),let element = dicJson as? [String:Any],let result = element["result"] as? [String:Any]
                    {
                        print(result["latitude"] as! Double)
                    }
                    
                    if let data = data, let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),let element = dicJson as? [String:Any],let result = element["result"] as? [String:Any], let lat = result["latitude"] as? Double, let long = result["longitude"] as? Double {
                        
                        if let address = result["address"] as? String
                        {
                            self?.safePlace!.address = address
                        }
                        else
                        {
                            self?.safePlace!.address = ""
                        }
                        
                        self?.safePlace!.latitude = lat
                        self?.safePlace!.longitude = long
                        let mapViewController = self?.storyboard!.instantiateViewController(withIdentifier: "Map Controller") as! MapViewController
                        mapViewController.safePlace = self?.safePlace!
                        mapViewController.currentCoordinate = currentLocation.coordinate
                        mapViewController.isRedAlertId = true
                        viewCtrl = mapViewController
                    }
                    else
                    {
                        let instructionViewController = self?.storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
                        viewCtrl = instructionViewController
                    }
                    
                    DispatchQueue.main.sync {
                        self?.push(to: viewCtrl)
                    }
                }
                else
                {
                    let instructionViewController = self?.storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
                    DispatchQueue.main.sync {
                        self?.push(to: instructionViewController!)
                    }
                }
            }
        }
    }
    
    func initialPulseAnimation()
    {
        pulsator.position = radioTowerImage.center
        pulseContainer.layer.addSublayer(pulsator)
        pulsator.radius = 240.0
        pulsator.numPulse = 5
        pulsator.backgroundColor = UIColor.white.cgColor
    }
    
    
    func takeCurrentLocation()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            let permission = CLLocationManager.authorizationStatus()
            if permission == .authorizedAlways || permission == .authorizedWhenInUse,toTakeLocation == true
            {
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
            }
        }
        
    }
    
    
    private func push(to viewController:UIViewController)
    {
        isProccessing = false
        showNavigate = true
        toShowNavigateButton()
        safePlace = nil
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LoadingViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        toTakeLocation = false
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        guard let currentLocation = locations.first else { return }
        let reachability = Reachability()!
        switch reachability.connection {
        case .none:
            loadShelterLocally(currentLocation: currentLocation)
        case .cellular,.wifi:
            if let fcmToken = UserDefaults.standard.string(forKey: "token")
            {
                if self.safePlace != nil{
                    activateCurrentLocation()
                    self.loadSheltersRemotelyForNotification(fcmToken: fcmToken, currentLocation: currentLocation)
                }
                else
                {
                    loadShelterLocally(currentLocation: currentLocation)
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
