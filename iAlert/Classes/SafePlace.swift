//
//  SafePlace.swift
//  iAlert
//
//  Created by Assaf Tayouri on 12/08/2018.
//

import Foundation
import CoreLocation



struct SafePlace: Codable {
    private typealias SafePlaces = [SafePlace]
    var longitude:Double!
    var latitude:Double!
    var address: String!
    var redAlertId:Int!
    var time:Int!
    
    var coordinate:CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        //return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    init(longitude:Double,latitude:Double,address: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    init(redAlertId:Int,time:Int) {
        self.redAlertId = redAlertId
        self.time = time
    }
    
    func toXY() -> Utilities.XY
    {
        return Utilities.degreeToXY(latitude: self.latitude, longitude: self.longitude)
    }
    
    //This function is converting string, that represent JSON object, to an array of SafePlace instances
    static func parseSafePlaces(from stringJsonData:String)->[SafePlace]?
    {
        guard let jsonData = stringJsonData.data(using: .utf8) else {return nil}
        let safePlaces = try? JSONDecoder().decode(SafePlaces.self, from: jsonData)
        return safePlaces
        
    }
}
