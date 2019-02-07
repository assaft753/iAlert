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
    @IBOutlet weak var pickLanguageBtn: UIButton!
    @IBOutlet weak var navigateBtn: UIButton!
    @IBOutlet weak var radioTowerImage: UIImageView!
    @IBOutlet weak var pulseContainer: UIView!
    @IBOutlet weak var viewsContainer: UIView!
    
    var isProccessing:Bool!
    var safePlace:SafePlace?
    let locationManager = CLLocationManager()
    let pulsator = Pulsator()
    var languageSelected:String!
    var isLocalShelter:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isProccessing = false
        initialLocalized(with: nil)
        initialPulseAnimation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func disappearButtons(completion:@escaping (() -> Void))
    {
        UIView.animate(withDuration: 0.5, animations: {
            self.pickLanguageBtn.alpha = 0
            self.navigateBtn.alpha = 0
        }) { (_) in
            completion()
        }
    }
    
    func appearButtons(animate:Bool = false,completion:(() -> Void)? = nil)
    {
        pulsator.stop()
        if animate == false
        {
            pickLanguageBtn.alpha = 1
            navigateBtn.alpha = 1
        }
        else
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.pickLanguageBtn.alpha = 1
                self.navigateBtn.alpha = 1
            }) { (_) in
                completion?()
            }
        }
        
    }
    
    func startProcessingLocationNavigation(isLocalShelter:Bool){
        if isProccessing == false
        {
            self.isLocalShelter = isLocalShelter
            isProccessing = true
            disappearButtons{self.takeCurrentLocation()}
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.delegate = nil
        
    }
    
    func initialLocalized(with languageId:String?)
    {
        if let languageId = languageId
        {
            UserDefaults.standard.set(languageId, forKey: ConstsKey.PREFFERED_LANGUAGE)
            UserDefaults.standard.synchronize()
        }
        let lang = getPickedLanguage()
        pickLanguageBtn.setTitle(lang, for: .normal)
        navigateBtn.setTitle("navigateBtn".localized, for: .normal)
    }
    
    func getPickedLanguage() -> String
    {
        if  UserDefaults.standard.string(forKey: ConstsKey.PREFFERED_LANGUAGE) != nil
        {
            let langName = "language".localized
            if langName != "language"
            {
                return langName
            }
            
            UserDefaults.standard.set(ConstsKey.ENGLISH_ID, forKey: ConstsKey.PREFFERED_LANGUAGE)
            UserDefaults.standard.synchronize()
            return "language".localized
        }
        
        UserDefaults.standard.set(ConstsKey.ENGLISH_ID, forKey: ConstsKey.PREFFERED_LANGUAGE)
        UserDefaults.standard.synchronize()
        return "language".localized
    }
    
    
    @IBAction func navigateBtnPressed(_ sender: Any){
        pulsator.start()
        startProcessingLocationNavigation(isLocalShelter: true)
    }
    
    @IBAction func pickLanguage(_ sender: Any) {
        showChoices()
    }
    func showChoices() {
        let alert = UIAlertController(title: "pickLanguage".localized, message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alert.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (UIAlertAction) in
            self.initialLocalized(with: self.languageSelected)
            
        }))
        self.languageSelected = ConstsKey.ENGLISH_ID
        self.present(alert,animated: true, completion: nil )
    }
    
    func findMinDistanceSafePlace(safePlaces:[SafePlace],currentLocation:CLLocation)->SafePlace?
    {
        let currentXY = Utilities.degreeToXY(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        var minDistance:Double = -1
        var minSafePlace:SafePlace?
        for safePlace in safePlaces {
            if currentLocation.coordinate.latitude != safePlace.coordinate.latitude, currentLocation.coordinate.longitude != safePlace.coordinate.longitude
            {
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
        }
        return minSafePlace
    }
    
    func loadShelterLocally(currentLocation:CLLocation)
    {
        
        print(currentLocation)
        if let safePlaces = iAlertService.shared.loadShelters(),let minSafePlace = findMinDistanceSafePlace(safePlaces: safePlaces, currentLocation: currentLocation)
        {
            let mapBoxViewController = self.storyboard!.instantiateViewController(withIdentifier: "MapBox Controller") as! MapBoxViewController
            mapBoxViewController.safePlace = minSafePlace
            mapBoxViewController.currentCoordinate = currentLocation.coordinate
            mapBoxViewController.isRedAlertId = false
            push(to: mapBoxViewController)
        }
            
        else{
            let instructionViewController = self.storyboard!.instantiateViewController(withIdentifier: "Instruction Controller")
            push(to: instructionViewController)
        }
    }
    
    func showAlreadyInSafeZoneAlert()
    {
        isProccessing = false
        let alert = UIAlertController(title: "safezone".localized, message: "alreadysafezone".localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { (_) in
            self.appearButtons(animate: true, completion: nil)
        })

        self.present(alert, animated: true)
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
                        
                        if currentLocation.coordinate.latitude == lat,currentLocation.coordinate.longitude == long
                        {
                            DispatchQueue.main.async {
                                self?.showAlreadyInSafeZoneAlert()
                            }
                            return
                        }
                        
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
                        let mapBoxViewController = self?.storyboard!.instantiateViewController(withIdentifier: "MapBox Controller") as! MapBoxViewController
                        mapBoxViewController.safePlace = self?.safePlace!
                        mapBoxViewController.currentCoordinate = currentLocation.coordinate
                        mapBoxViewController.isRedAlertId = true
                        viewCtrl = mapBoxViewController
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
        let x = (radioTowerImage.frame.width/2) - 15
        let center = CGPoint(x: radioTowerImage.frame.origin.x+x/*-19*/, y: radioTowerImage.frame.origin.y/*-85*/)
        pulsator.frame.origin.x = radioTowerImage.frame.origin.x
        pulsator.frame.origin.y = radioTowerImage.frame.origin.y
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
            if permission == .authorizedAlways || permission == .authorizedWhenInUse
            {
                print(pulsator.position)
                pulsator.start()
                print(pulsator.position)
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
            }
        }
        
    }
    
    private func push(to viewController:UIViewController)
    {
        self.navigationController?.pushViewController(viewController, animated: true)
        pulsator.stop()
        isProccessing = false
        safePlace = nil
        appearButtons()
    }
}

extension LoadingViewController:UIPickerViewDelegate, UIPickerViewDataSource
{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ConstsKey.LANGUAGE_STRS.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        languageSelected = ConstsKey.LANGUAGE_IDS[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ConstsKey.LANGUAGE_STRS[row]
    }
}

extension LoadingViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        guard let currentLocation = locations.first else { return }
        if self.isLocalShelter == true
        {
            self.loadShelterLocally(currentLocation: currentLocation)
        }
        else
        {
            let reachability = Reachability()!
            switch reachability.connection {
            case .none:
                self.loadShelterLocally(currentLocation: currentLocation)
            case .cellular,.wifi:
                if let fcmToken = UserDefaults.standard.string(forKey: "token")
                {
                    if self.safePlace != nil{
                        self.loadSheltersRemotelyForNotification(fcmToken: fcmToken, currentLocation: currentLocation)
                    }
                    else
                    {
                        self.loadShelterLocally(currentLocation: currentLocation)
                    }
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
