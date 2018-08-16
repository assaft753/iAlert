//
//  LoadingViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 11/08/2018.
//  Copyright © 2018 Assaf Tayouri. All rights reserved.
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
    
    
    private func sendPostRequest(sent from:String)
    {
        let url = URL(string: "http://192.168.1.103:3001/")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        let encoder = JSONEncoder()
        do {
            let dic:[String:String] = ["method":from]
            let jsonData = try encoder.encode(dic)
            request.httpBody = jsonData
        } catch {
            print("error in json \(error)")
        }
        
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            if let error = responseError
            {
                print("error in session \(error)")
            }
            
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialPulseAnimation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendPostRequest(sent: "enter viewWillAppear ")
        locationManager.delegate = self
        pulsator.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sendPostRequest(sent: "enter viewWillDisappear ")
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
                //locationManager.requestLocation()
            }
        }
        
    }
    
    private func nearestSafePlace(from safePlaces:[SafePlace],currentLocation:CLLocation)
    {
        let viewController:UIViewController!
        
        if safePlaces.count == 0
        {
            sendPostRequest(sent: "enter count == 0 ")
            let instructionViewController = storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
            viewController = instructionViewController
        }
            
        else if let safePlace = calculate(from: safePlaces, currentLocation: currentLocation)
        {
            sendPostRequest(sent: "enter calculate")
            print(safePlace)
            let mapViewController = storyboard!.instantiateViewController(withIdentifier: "Map Controller") as! MapViewController
            
            mapViewController.currentCoordinate = currentLocation.coordinate
            mapViewController.destinationCoordinate = safePlace.coordinate.coordinate
            mapViewController.address = safePlace.address
            viewController = mapViewController
        }
            
        else
        {
            sendPostRequest(sent: "enter else")
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
    }
    
    private func push(viewController:UIViewController)
    {
        sendPostRequest(sent: "enter push")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LoadingViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        sendPostRequest(sent: "enter didUpdateLocations")
        guard let currentLocation = locations.first else { return }
        nearestSafePlace(from: self.safePlaces, currentLocation: currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
