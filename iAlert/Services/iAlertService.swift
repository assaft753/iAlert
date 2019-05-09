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
   /* // let context: NSManagedObjectContext = NSManagedObjectContext.context////TODO: delete
     public func loadShelters() -> [SafePlace]?//TODO: delete
     {
     //let context = NSManagedObjectContext.context
     let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shelter")
     guard let shelters = try? context.fetch(fetchRequest) else {return nil}
     let safePlaces = shelters.map{SafePlace(longitude: $0.value(forKey: "longitude") as! Double, latitude: $0.value(forKey: "latitude") as! Double, address: $0.value(forKey: "address") as! String)  }
     return safePlaces
     }
     
     public func removeAllShelters()//TODO: delete
     {
     //let context = self.context
     let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shelter")
     do {
     let arr = try context.fetch(fetchRequest)
     arr.forEach{context.delete($0 as! NSManagedObject)}
     
     } catch {
     print("Error in delete !!!!!")
     }
     }
     
     public func saveShelters(shelters:[[String:Any]])//TODO: delete
     {
     guard let entity = NSEntityDescription.entity(forEntityName: "Shelter", in: context) else{return}
     shelters.forEach{
     let shelter = NSManagedObject(entity: entity, insertInto: context)
     shelter.setValue($0["latitude"], forKeyPath: "latitude")
     shelter.setValue($0["address"], forKeyPath: "address")
     shelter.setValue($0["longitude"], forKeyPath: "longitude")
     }
     try? context.save()
     }*/
    
     func fetch(type idle:Idle, compilation:((Data?,Error?,URLResponse?)->Void)? = nil)
    {
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.sendLocalNotificationWith(title: "1", body: ("\(idle.requestURL)"))
        
        if let requestURL = idle.requestURL{
            //let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //appDelegate.sendLocalNotificationWith(title: "2", body: nil)
                self.activate(session: requestURL, compilation: compilation)
        }
    }
    
     func fetch(type operative:Operative, compilation:((Data?,Error?,URLResponse?)->Void)? = nil)
    {
        if let requestURL = operative.requestURL{
                 self.activate(session: requestURL, compilation: compilation)
        }
    }
    
    private func activate(session sessionOpt:URLRequest,compilation:((Data?,Error?,URLResponse?)->Void)?)
    {
        //print(sessionOpt)
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.sendLocalNotificationWith(title: "3", body: nil)
        
        URLSession.shared.dataTask(with: sessionOpt){ (data, response, err) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sendLocalNotificationWith(title: "4", body: nil)
            print(sessionOpt)
            print(response)
            print(err)
            if let data = data
            { print(String(data: data, encoding: .utf8))}
           
            if let compilation = compilation
            {
                compilation(data,err,response)
            }
        }.resume()
    }
    
    func getAndSaveAllClosestsSafePlaces(for coordinate:CLLocationCoordinate2D,completion:(([SafePlace]?)->Void)? = nil)
    {
        //print("getAndSaveAllClosestsSafePlaces")
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
    
}

