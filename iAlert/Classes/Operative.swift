//
//  Operative.swift
//  iAlert
//
//  Created by Assaf Tayouri on 26/01/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation
enum Operative {
    case Arrive(redAlertId:Int,uniqueId:String)
    case ClosestsShelter(uniqueId:String,latitude:Double,longitude:Double,redAlertId:Int)
    
    var requestBody:[String:Any]{
        var body:[String:Any]=[:]
        switch self {
        case .Arrive(let redAlertId,let uniqueId):
            body[ConstsKey.RED_ALERT_ID] = redAlertId
            body[ConstsKey.UNIQUE_ID] = uniqueId
        case .ClosestsShelter(let uniqueId,let latitude,let longitude,let redAlertId):
            body[ConstsKey.UNIQUE_ID] = uniqueId
            body[ConstsKey.RED_ALERT_ID] = redAlertId
            body[ConstsKey.LATITUDE2] = latitude
            body[ConstsKey.LANGITUDE2] = longitude
        }
        return body
    }
    
    var requestURL:URL?{
        var endPoint = "\(ConstsKey.BASE_URL)/\(ConstsKey.OPERATIVE)"
        switch self {
        case .Arrive:
            endPoint+="/\(ConstsKey.ARRIVE)"
        case .ClosestsShelter:
            endPoint+="/\(ConstsKey.CLOSESTS_SHELTER)"
        }
        return URL(string: endPoint)
    }
}
