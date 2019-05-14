//
//  iAlertService.swift
//  iAlert
//
//  Created by Assaf Tayouri on 26/01/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class iAlertService{
    static var shared = iAlertService()
    private var context:NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
   private func fetch(type idle:Idle, compilation:((Data?,Error?,URLResponse?)->Void)? = nil)
    {
        if let requestURL = idle.requestURL{
            self.activate(session: requestURL, compilation: compilation)
        }
    }
    
   private func fetch(type operative:Operative, compilation:((Data?,Error?,URLResponse?)->Void)? = nil)
    {
        if let requestURL = operative.requestURL{
            self.activate(session: requestURL, compilation: compilation)
        }
    }
    
    private func fetch(type management:Management, compilation:((Data?,Error?,URLResponse?)->Void)? = nil)
    {
        if let requestURL = management.requestURL{
            self.activate(session: requestURL, compilation: compilation)
        }
    }
    
    private func activate(session sessionOpt:URLRequest,compilation:((Data?,Error?,URLResponse?)->Void)?)
    {
        URLSession.shared.dataTask(with: sessionOpt){ (data, response, err) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sendLocalNotificationWith(title: "4", body: nil)
            print(sessionOpt)
            print(response)
            print(err)
            if let data = data
            { print(String(data: data, encoding: .utf8))}
            compilation?(data,err,response)
            
            }.resume()
    }
    
    func getAndSaveAllClosestsSafePlaces(for coordinate:CLLocationCoordinate2D,completion:(([SafePlace]?)->Void)? = nil)
    {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            completion?(nil)
            return
        }
        
        fetch(type: .AllClosestsShelters(uniqueId: token, latitude: coordinate.latitude, longitude: coordinate.longitude)){
            data,err,response in
            if let data = data
            {
                print("getAndSaveAllClosestsSafePlaces \(String(decoding: data, as: UTF8.self)) \(err) \(response)")
            }
            else
            {
                print("getAndSaveAllClosestsSafePlaces \(err) \(response)")
            }
            
            if let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode < 300,let data = data, let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),let element = dicJson as? [String:Any],let result = element["result"] as? [[String:Any]]{
                SafePlace.removeAllSafePlaces()
                SafePlace.saveShelters(shelters: result)
                if let completion = completion
                {
                    let SafePlaces = SafePlace.loadSafePlaces()
                    completion(SafePlaces)
                }
            }
            else
            {
                completion?(nil)
            }
        }
    }
    
    func getSelfClosestSafePlace(for coordinate:CLLocationCoordinate2D,completion:@escaping ((SafePlace?)->Void))
    {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            completion(nil)
            return
        }
        
        fetch(type: .AllClosestsShelters(uniqueId: token, latitude: coordinate.latitude, longitude: coordinate.longitude)){
            data,err,response in
            if let data = data, let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),
                let element = dicJson as? [String:Any],
                let result = element["result"] as? [[String:Any]]
            {
                let safePlace = SafePlace.getClosestSafePlace(of: SafePlace.convertToSafePlaces(result), for: coordinate)
                completion(safePlace)
            }
            else
            {
                completion(nil)
            }
        }
    }
    
    
    func register(by fcmToken:String,completion:((Int?,Data?,Error?)->Void)? = nil)
    {
        if let token = UserDefaults.standard.string(forKey: "token")
        {
            if token != fcmToken
            {
                UserDefaults.standard.set(fcmToken, forKey: "token")
                iAlertService.shared.fetch(type: .Register(uniqueId: fcmToken, prevId: token)){ data,error,response in
                    let httpResponse = response as? HTTPURLResponse
                    completion?(httpResponse?.statusCode,data,error)
                }
            }
        }
        else
        {
            UserDefaults.standard.set(fcmToken, forKey: "token")
            iAlertService.shared.fetch(type: .Register(uniqueId: fcmToken, prevId: nil)){ data,error,response in
                let httpResponse = response as? HTTPURLResponse
                completion?(httpResponse?.statusCode,data,error)
            }
        }
        print("Firebase registration token: \(fcmToken)")
    }
    
    func update(coordinate: CLLocationCoordinate2D, city: String,completion:((Int?,Data?,Error?)->Void)? = nil)
    {
        if let token = UserDefaults.standard.string(forKey: "token")
        {
            fetch(type: .Update(latitude: coordinate.latitude, langitude: coordinate.longitude, city: city, uniqueId:token , language: Language.LANGUAGE_PRESENTAION[Settings.shared.languageId] ?? "")){
                data,err,response in
                completion?((response as? HTTPURLResponse)?.statusCode,data,err)
            }//TODO: update to english
        }
    }
    
    func arrived(redAlertId:Int)
    {
        if let token = UserDefaults.standard.string(forKey: "token")
        {
            fetch(type: .Arrived(redAlertId: redAlertId, uniqueId: token))
        }
    }
    
    func GetAllAreasWithPreffered(compilation:(([Area]?)->Void)?)
    {
        if let token = UserDefaults.standard.string(forKey: "token")
        {
            fetch(type: .GetAllAreas){[weak self]
                data,error,response in
                if let data = data, let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),let elements = dicJson as? [[String:Any]]
                {
                    var areasDic:[Int:Area] = [:]
                    elements.forEach{
                       guard let areaCode = $0[ConstsKey.AREA_CODE] as? Int
                        else{return}
                        guard let city = $0["city"] as? String
                            else{return}
                        let cities:[String] = city.components(separatedBy: ",").map{
                            var city = $0.lowercased()
                            print($0)
                            city = city.trimmingCharacters(in: .whitespacesAndNewlines)
                            city = city.replacingOccurrences(of: " ", with: "")
                            city = city.replacingOccurrences(of: "-", with: "")
                            return city
                        }
                        print(cities)
                        areasDic[areaCode] = Area(areaCode: areaCode, citiesNames: cities)
                    }
                    
                    self?.fetch(type: .GetPrefferedAreas(uniqueId: token)){
                        data,error,response in
                        
                        if let data = data, let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),let elements = dicJson as? [[String:Any]]
                        {
                            elements.forEach{
                               guard let areaCode = $0[ConstsKey.AREA_CODE] as? Int
                                else {return}
                                guard let area = areasDic[areaCode] else{return}
                                area.isPreffered = true
                            }
                            
                            var areas:[Area] = []
                            
                            for area in areasDic.values
                            {
                                areas.append(area)
                            }
                            
                            compilation?(areas)
                        }
                        
                        else {
                            compilation?(nil)
                            return
                        }
                    }
                }
                else {
                    compilation?(nil)
                    return
                }
            }
            
        }
        else
        {
            compilation?(nil)
        }
    }
    
    func setPrefferedArea(areaCode:Int)
    {
        if let token = UserDefaults.standard.string(forKey: "token")
        {
            fetch(type: .SetPrefferedArea(areaCode: areaCode,uniqueId: token))
        }
    }
    
    func deletePrefferedArea(areaCode:Int)
    {
        if let token = UserDefaults.standard.string(forKey: "token")
        {
            fetch(type: .DeletePrefferedArea(areaCode: areaCode,uniqueId: token))
        }
    }
    
    func getSafePlaceAfterNotification(redAlertId:Int, coordinate:CLLocationCoordinate2D,completion: @escaping ((Double?,Double?,Int?,Error?)->Void))
    {
        if let token = UserDefaults.standard.string(forKey: "token")
        {
            fetch(type: .ClosestsShelter(uniqueId: token, latitude: coordinate.latitude, longitude: coordinate.longitude, redAlertId: redAlertId)){
                data,error,response in
                
                if let error = error
                {
                    completion(nil,nil,nil,error)
                    return
                }
                
                if let data = data,
                    let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),
                    let element = dicJson as? [String:Any],
                    let dic = element["result"] as? [String:Any],
                    let time = dic["max_time_to_arrive_to_shelter"] as? Int,
                    let latitude = dic["latitude"] as? Double,
                    let longitude = dic["longitude"] as? Double
                {
                    completion(latitude,longitude,time,nil)
                    return
                }
                else
                {
                    completion(nil,nil,nil,NSError())
                    return
                }
                
            }
        }
    }
    
}

