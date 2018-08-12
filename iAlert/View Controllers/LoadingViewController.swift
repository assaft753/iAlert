//
//  LoadingViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 11/08/2018.
//  Copyright © 2018 Lior Cohen. All rights reserved.
//

import UIKit
import CoreLocation

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var radioTowerImage: UIImageView!
    @IBOutlet weak var pulseContainer: UIView!
    
    let MAX_DiSTANCE:Double = 10000
    var safePlaces:[SafePlace]!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialPulseAnimation()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
    }
    
    func initialPulseAnimation()
    {
        let pulsator = Pulsator()
        pulsator.position = radioTowerImage.center
        pulseContainer.layer.addSublayer(pulsator)
        pulsator.radius = 240.0
        pulsator.numPulse = 5
        pulsator.backgroundColor = UIColor.white.cgColor
        pulsator.start()
    }
    
    func calculateAndPush(safePlaces:[SafePlace])
    {
        if CLLocationManager.locationServicesEnabled()
        {
            let permission = CLLocationManager.authorizationStatus()
            if permission == .authorizedAlways || permission == .authorizedWhenInUse
            {
                self.safePlaces = safePlaces
                locationManager.startUpdatingLocation()
                
            }
        }
        
    }
    
    private func nearestSafePlace(from safePlaces:[SafePlace],currentLocation:CLLocation)
    {
        
        if safePlaces.count == 0
        {
             print("enter2")
            let instructionViewController = storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
            push(viewController: instructionViewController)
            return
        }
        else if let safePlace = calculate(from: safePlaces, currentLocation: currentLocation)
        {
            print(safePlace)
            let mapViewController = storyboard!.instantiateViewController(withIdentifier: "Map Controller") as! MapViewController
            
            mapViewController.currentCoordinate = currentLocation.coordinate
            mapViewController.destinationCoordinate = safePlace.coordinate.coordinate
            mapViewController.address = safePlace.address
            
            push(viewController: mapViewController)
            return
        }
        print("enter1")
        let instructionViewController = storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
        push(viewController: instructionViewController)
        
        
    }
    
    private func calculate(from safePlaces:[SafePlace],currentLocation:CLLocation)->SafePlace?
    {
        var minSafePlace:SafePlace? = nil
        var minDistance:Double = Double.infinity
        for safePlace in safePlaces
        {
            let distance = currentLocation.distance(from: safePlace.coordinate)
            if distance <= MAX_DiSTANCE && distance < minDistance
            {
                minSafePlace = safePlace
                minDistance = distance
            }
        }
        return minSafePlace
//        let safe = SafePlace(longitude: 34.80996975251469, latitude: 32.05411042165174, address: "Ma'apilei Egoz St 76, Tel Aviv-Yafo, Israel")
//        return nil
    }
    
    private func push(viewController:UIViewController)
    {
         print("enter3")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LoadingViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        nearestSafePlace(from: self.safePlaces, currentLocation: currentLocation)
    }
}
