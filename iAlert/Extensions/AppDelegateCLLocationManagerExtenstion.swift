//
//  AppDelegateCLLocationManagerExtenstion.swift
//  iAlert
//
//  Created by Assaf Tayouri on 24/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//
import CoreLocation
import UserNotifications
import UIKit

extension AppDelegate: CLLocationManagerDelegate {
    
    func newLocationReceived( location: CLLocation, city: String, description: String) {

        iAlertService.shared.update(coordinate: location.coordinate, city: city){
            statusCode,data,err in
            self.sendLocalNotificationWith(title: "fetch", body: nil)
            let title:String = "status code \(statusCode?.description ?? "no status code")"
            var body:String = ""
            if let data = data
            {
                body = "with data: \(String(data: data, encoding: .utf8)!)"
            }
            else if let error = err
            {
                body = "with error: \(error)"
            }
            let contentBody = "\(description) with body \(body)"
            
            self.sendLocalNotificationWith(title:title,body:contentBody)
        }
        
        iAlertService.shared.getAndSaveAllClosestsSafePlaces(for: location.coordinate){
            _ in
            self.sendLocalNotificationWith(title: "safeplaces saved", body: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        let title = "location recv"
        self.sendLocalNotificationWith(title: title, body: nil)
        
        iAlertGeoCoder(coordinate: location.coordinate, GMSLanguageCode: Language.ENGLISH_ID).reverseGeocodeCoordinate{place in
            guard let place = place else{return}
            
            let description = "New Location: \(place)"
            self.sendLocalNotificationWith(title: "geoed place", body: description)
            guard let cityName = place.cityName else {return}
            self.newLocationReceived(location: location, city: cityName, description: description)
        }
    }
}
