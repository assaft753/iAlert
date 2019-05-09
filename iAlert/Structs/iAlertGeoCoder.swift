//
//  iAlertGeoCoder.swift
//  iAlert
//
//  Created by Assaf Tayouri on 25/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps


import UserNotifications

struct iAlertGeoCoder
{
       var coordinate:CLLocationCoordinate2D
       var GMSLanguageCode:String
    
    private var GMSGeoCoderUrl:URL?{
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.googleapis.com"
        components.path = "/maps/api/geocode/json"
        
        let queryItemLatLng = URLQueryItem(name: "latlng", value: "\(coordinate.latitude),\(coordinate.longitude)")
        let queryItemGMSLanguageCode = URLQueryItem(name: "language", value: GMSLanguageCode)
        let queryItemGMSApiKey = URLQueryItem(name: "key", value: GMSServices.GMS_UTILITIES_API_KEY)
        
        components.queryItems = [queryItemLatLng,queryItemGMSLanguageCode,queryItemGMSApiKey]
        
        return components.url
    }
    
    public func reverseGeocodeCoordinate(completionHandler:@escaping ((Place?)->Void))
    {
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.sendLocalNotificationWith(title: "77", body: nil)
        
        
        if let gmsUrl = GMSGeoCoderUrl
        {
            //appDelegate.sendLocalNotificationWith(title: "\(gmsUrl)", body: nil)
            URLSession.shared.dataTask(with: gmsUrl){
                (data, response, error)  in
                //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                //appDelegate.sendLocalNotificationWith(title: "error", body: "\(error)")
                //appDelegate.sendLocalNotificationWith(title: "data", body: "\(String(data:data ?? Data(),encoding: .utf8))")
                //appDelegate.sendLocalNotificationWith(title: "response", body: "\(response)")
                
                guard error != nil else{
                    guard let data = data else {
                        completionHandler(nil)
                        return
                    }
                    if let component = self.extractCorrectComponent(data: data)
                    {
                        let streetNumber = self.extractValue(from: component, for: ConstsKey.GMS_STREET_NUMBER)
                        let streetName = self.extractValue(from: component, for: ConstsKey.GMS_STREET_NAME)
                        let cityName = self.extractValue(from: component, for: ConstsKey.GMS_CITY)
                        let countryName = self.extractValue(from: component, for: ConstsKey.GMS_COUNTRY)
                        
                        let place = Place(streetNumber: streetNumber, streetName: streetName, cityName: cityName, countryName: countryName)
                        completionHandler(place)
                    }
                    else
                    {
                        completionHandler(nil)
                    }
                    return
                }
                completionHandler(nil)
                return
            }.resume()
        }
    }
    
    private func extractCorrectComponent(data:Data)->[[String: Any]]?
    {
        if let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDic = jsonData as? [String: Any],
            let jsonResults = jsonDic["results"] as? [[String: Any]],
            let addressComponent = jsonResults[0]["address_components"] as? [[String: Any]]
        {
            return addressComponent
        }
        return nil
    }
    
    
    private func extractComponentFor(componentKind:String, with component:[[String: Any]])->[String:Any]?
    {
            let desireComponent = component.first {
                if let types = $0[ConstsKey.GMS_TYPE] as? [String],
                    types.contains(componentKind)
                {
                    return true
                }
                return false
            }
        return desireComponent
    }
    
    private func extractValue(from component:[[String: Any]],for kind:String)->String?
    {
        guard let desireComponent = extractComponentFor(componentKind: kind, with: component),
            let desireString = desireComponent[ConstsKey.GMS_LONG_NAME] as? String
        else{return nil}
        return desireString
    }
}
