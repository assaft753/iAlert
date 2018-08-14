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
    
    let MAX_DISTANCE:Double = 20000
    var safePlaces:[SafePlace]!
    let locationManager = CLLocationManager()
    let pulsator = Pulsator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialPulseAnimation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.delegate = self
        pulsator.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.delegate = nil
        
    }
    
    func initialPulseAnimation()
    {
        pulsator.position = radioTowerImage.center
        pulseContainer.layer.addSublayer(pulsator)
        pulsator.radius = 240.0
        pulsator.numPulse = 5
        pulsator.backgroundColor = UIColor.white.cgColor
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
        let viewController:UIViewController!
        
        if safePlaces.count == 0
        {
            print("enter2")
            let instructionViewController = storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
            viewController = instructionViewController
        }
            
        else if let safePlace = calculate(from: safePlaces, currentLocation: currentLocation)
        {
            print("enter4")
            print(safePlace)
            let mapViewController = storyboard!.instantiateViewController(withIdentifier: "Map Controller") as! MapViewController
            
            mapViewController.currentCoordinate = currentLocation.coordinate
            mapViewController.destinationCoordinate = safePlace.coordinate.coordinate
            mapViewController.address = safePlace.address
            viewController = mapViewController
        }
            
        else
        {
            print("enter1")
            let instructionViewController = storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
            viewController = instructionViewController
        }
        push(viewController: viewController)
        
        
    }
    
    private func calculate(from safePlaces:[SafePlace],currentLocation:CLLocation)->SafePlace?
    {
        var minSafePlace:SafePlace? = nil
        var minDistance:Double = Double.infinity
        for safePlace in safePlaces
        {
            let distance = currentLocation.distance(from: safePlace.coordinate)
            if distance <= MAX_DISTANCE && distance < minDistance
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
        /*let alert = UIAlertController(title: "d", message: "d", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)*/
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        nearestSafePlace(from: self.safePlaces, currentLocation: currentLocation)
    }
}
