//
//  SafePlace.swift
//  iAlert
//
//  Created by Assaf Tayouri on 12/08/2018.
//

import Foundation
import CoreLocation
import CoreData
import GoogleMaps



struct SafePlace: Codable {
    private typealias SafePlaces = [SafePlace]
    var longitude:Double!
    var latitude:Double!
    var address: String?
    var redAlertId:Int?
    var time:Int?
    
    var coordinate:CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    init(longitude:Double, latitude:Double, address:String? = nil, time:Int? = nil, redAlertId:Int? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.time = time
        self.redAlertId = redAlertId
    }
}

extension SafePlace
{
    private static var context:NSManagedObjectContext{
        return NSManagedObjectContext.context
    }
    
    public static func loadSafePlaces() -> [SafePlace]?
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shelter")
        guard let safePlacesCoreData = try? context.fetch(fetchRequest) else {return nil}
        let safePlaces = safePlacesCoreData.map{
            SafePlace(longitude: $0.value(forKey: "longitude") as! Double, latitude: $0.value(forKey: "latitude") as! Double, address: ($0.value(forKey: "address") as! String))
            
        }
        return safePlaces
    }
    
    public static func removeAllSafePlaces()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shelter")
        let safePlaces = try? context.fetch(fetchRequest)
        safePlaces?.forEach{context.delete($0 as! NSManagedObject)}
    }
    
    public static func saveShelters(shelters:[[String:Any]])
    {
        guard let entity = NSEntityDescription.entity(forEntityName: "Shelter", in: context) else{return}
        shelters.forEach{
            let shelter = NSManagedObject(entity: entity, insertInto: context)
            shelter.setValue($0["latitude"], forKeyPath: "latitude")
            shelter.setValue($0["address"], forKeyPath: "address")
            shelter.setValue($0["longitude"], forKeyPath: "longitude")
        }
        try? context.save()
    }
    
    public static func convertToSafePlaces(_ safePlacesDic:[[String:Any]])->[SafePlace]
    {
        var safePlaces:[SafePlace] = []
        safePlacesDic.forEach{
            if let lat = $0["latitude"] as? Double,
                let add = $0["address"] as? String,
                let long = $0["longitude"] as? Double
            {
                safePlaces.append(SafePlace(longitude: long, latitude: lat, address: add, time: nil, redAlertId: nil))
            }
        }
        return safePlaces
    }
    
    public static func getClosestSafePlace(of safePlaces:[SafePlace],for coordinate:CLLocationCoordinate2D)-> SafePlace?
    {
        if safePlaces.count == 0
        {
            return nil
        }
        
        return safePlaces.filter{ GMSGeometryDistance($0.coordinate,coordinate) <= 100 }.sorted {  GMSGeometryDistance($0.coordinate,coordinate) < GMSGeometryDistance($1.coordinate,coordinate)
            }.first
    }
}
