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

class iAlertService{
    static var shared = iAlertService()
    private var context:NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    public func loadShelters() -> [SafePlace]?
    {
        let context = self.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shelter")
        guard let shelters = try? context.fetch(fetchRequest) else {return nil}
        let safePlaces = shelters.map{SafePlace(longitude: $0.value(forKey: "longitude") as! Double, latitude: $0.value(forKey: "latitude") as! Double, address: $0.value(forKey: "address") as! String)  }
        return safePlaces
    }
    
    public func removeAllShelters()
    {
        let context = self.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shelter")
        do {
            let arr = try context.fetch(fetchRequest)
            arr.forEach{context.delete($0 as! NSManagedObject)}
            
        } catch {
            print("Error in delete !!!!!")
        }
    }
    
    public func saveShelters(shelters:[[String:Any]])
    {
        shelters.forEach{
            let entity = NSEntityDescription.entity(forEntityName: "Shelter", in: context)
            let shelter = NSManagedObject(entity: entity!, insertInto: context)
            shelter.setValue($0["latitude"], forKeyPath: "latitude")
            shelter.setValue($0["address"], forKeyPath: "address")
            shelter.setValue($0["longitude"], forKeyPath: "longitude")
        }
        try? context.save()
    }
    
    public func fetch(type idle:Idle, compilation:((Data?,Error?,URLResponse?)->Void)? = nil)
    {
        if let requestURL = idle.requestURL{
            self.activate(session: requestURL, compilation: compilation)
        }
    }
    
    public func fetch(type operative:Operative, compilation:((Data?,Error?,URLResponse?)->Void)? = nil)
    {
        if let requestURL = operative.requestURL{
            self.activate(session: requestURL, compilation: compilation)
        }
    }
    
    private func activate(session sessionOpt:URLRequest,compilation:((Data?,Error?,URLResponse?)->Void)?)
    {
        let session = URLSession.shared.dataTask(with: sessionOpt){ (data, response, err) in
            print("in data!!! \(data)")
            print("in err!!! \(err)")
            print("in response!!! \(response)")
            if let compilation = compilation
            {
                compilation(data,err,response)
            }
        }
        session.resume()
    }
}

