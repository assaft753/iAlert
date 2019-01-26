//
//  Idle.swift
//  iAlert
//
//  Created by Assaf Tayouri on 26/01/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation
enum Idle {
    case Register(uniqueId:String,prevId:String?)
    case Update(latitude:Double,langitude:Double,city:String?,uniqueId:String,language:String)
    case PreferredLanguage(uniqueId:String,language:String)
    
    case test
    
    var requestBody:[String:Any]{
        switch self {
        case .Register(let uniqueId,let prevId):
            var body:[String:Any] = [:]
            if let prev = prevId{
                body[ConstsKey.PREV_ID] = prev
            }
            body[ConstsKey.UNIQUE_ID] = uniqueId
            body[ConstsKey.IS_ANDROID] = false
            return body
            
        case .Update(let latitude,let langitude,let city,let uniqueId,let language):
            var body:[String:Any] = [:]
            if let currentCity = city{
                body[ConstsKey.CITY] = currentCity
            }
            body[ConstsKey.LATITUDE] = latitude
            body[ConstsKey.LANGITUDE] = langitude
            body[ConstsKey.UNIQUE_ID] = uniqueId
            body[ConstsKey.LANGUAGE] = language
            return body
            
        case .PreferredLanguage(let uniqueId,let language):
            var body:[String:Any] = [:]
            body[ConstsKey.UNIQUE_ID] = uniqueId
            body[ConstsKey.LANGUAGE] = language
            return body
        case .test:
            var body:[String:Any] = [:]
            body[ConstsKey.UNIQUE_ID] = "abcdef"
            body[ConstsKey.LANGUAGE] = "eng"
            return body
        }
    }
    
    var requestURL:URL?{
        var endPoint = "\(ConstsKey.BASE_URL)/\(ConstsKey.IDLE)"
        switch self {
        case .PreferredLanguage:
            endPoint+="/\(ConstsKey.PREFFERED_LANGUAGE)"
        case .Register:
            endPoint+="/\(ConstsKey.REGISTER)"
        case .Update:
            endPoint+="/\(ConstsKey.UPDATE)"
        case .test:
            endPoint+="/\(ConstsKey.TEST)"
        }
        return URL(string: endPoint)
    }
}
