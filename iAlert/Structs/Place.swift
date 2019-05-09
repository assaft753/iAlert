//
//  Place.swift
//  iAlert
//
//  Created by Assaf Tayouri on 04/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation
struct Place:CustomStringConvertible{
    var description: String{
        var desc = ""
        if let streetName = streetName
        {
            desc += "\(streetName)"
        }
        
        if let streetNumber = streetNumber
        {
            desc += ", \(streetNumber)"
        }
        return desc
    }
    
    var streetNumber:String?
    var streetName:String?
    var cityName:String?
    var countryName:String?
}
