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
    case AllClosestsShelters(uniqueId:String,latitude:Double,longitude:Double)
    
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
        case .AllClosestsShelters(let uniqueId, let latitude, let longitude):
            body[ConstsKey.UNIQUE_ID] = uniqueId
            body[ConstsKey.LATITUDE2] = latitude
            body[ConstsKey.LANGITUDE2] = longitude
        }
        return body
    }
    
    var requestURL:URLRequest?{
        var endPoint = "\(ConstsKey.BASE_URL)/\(ConstsKey.OPERATIVE)"
        var method:String
        switch self {
        case .Arrive:
            endPoint+="/\(ConstsKey.ARRIVE)"
            method = "POST"
        case .ClosestsShelter:
            endPoint+="/\(ConstsKey.CLOSESTS_SHELTER)"
            method = "POST"
        case .AllClosestsShelters:
            endPoint+="/\(ConstsKey.ALL_CLOSESTS_SHELTER)"
            method = "POST"
        }
        if let url = URL(string: endPoint)
        {
            var sessionOpt = URLRequest(url: url)
            sessionOpt.httpMethod = method
            sessionOpt.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {return nil}
            sessionOpt.httpBody = bodyData
            return sessionOpt
        }
        return nil
    }
}
