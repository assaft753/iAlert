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
    private let longitude:Double
    private let latitude:Double
    let address: String
    var coordinate:CLLocation{
        get{
            return CLLocation(latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    init(longitude:Double,latitude:Double,address:String) {
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
    }
    
    static func parseSafePlaces(from stringJsonData:String)->[SafePlace]?
    {
        guard let jsonData = stringJsonData.data(using: .utf8) else {return nil}
        let safePlaces = try? JSONDecoder().decode(SafePlaces.self, from: jsonData)
        return safePlaces
        
    }
}
