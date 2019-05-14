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
    case Update(latitude:Double,langitude:Double,city:String,uniqueId:String,language:String)
    case PreferredLanguage(uniqueId:String,language:String)
    
    private var requestBody:[String:Any]{
        switch self {
        case .Register(let uniqueId,let prevId):
            var body:[String:Any] = [:]
            if let prev = prevId{
                body[ConstsKey.PREV_ID] = prev
            }
            body[ConstsKey.UNIQUE_ID] = uniqueId
            return body
            
        case .Update(let latitude,let langitude,let city,let uniqueId,let language):
            var body:[String:Any] = [:]
            body[ConstsKey.CITY] = city
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
        }
    }
    
    var requestURL:URLRequest?{
        var endPoint = "\(ConstsKey.BASE_URL)/\(ConstsKey.IDLE)"
        var method:String
        switch self {
        case .PreferredLanguage:
            endPoint+="/\(ConstsKey.PREFFERED_LANGUAGE)"
            method = "PUT"
        case .Register:
            endPoint+="/\(ConstsKey.REGISTER)"
            method = "POST"
        case .Update:
            endPoint+="/\(ConstsKey.UPDATE)"
            method = "PUT"
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
