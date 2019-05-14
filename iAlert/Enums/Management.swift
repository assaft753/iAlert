//
//  Manangment.swift
//  iAlert
//
//  Created by Assaf Tayouri on 11/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation
enum Management {
    case GetAllAreas
    case SetPrefferedArea(areaCode:Int,uniqueId:String)
    case GetPrefferedAreas(uniqueId:String)
    case DeletePrefferedArea(areaCode:Int,uniqueId:String)
    
    private var requestBody:[String:Any]{
        var body:[String:Any]=[:]
        switch self {
        case .SetPrefferedArea(let areaCode,let uniqueId):
            body[ConstsKey.AREA_CODE] = areaCode
            body[ConstsKey.UNIQUE_ID] = uniqueId
        default: break
        }
        return body
    }
    
    private func pramas(of urlStr:String)->URL?
    {
        if var paramsURL:URLComponents = URLComponents(string: urlStr)
        {
            switch self {
            case .GetAllAreas:
                return paramsURL.url
            case .GetPrefferedAreas(let uniqueId):
                paramsURL.queryItems = [URLQueryItem(name: ConstsKey.UNIQUE_ID, value: uniqueId)]
                return paramsURL.url
            case .DeletePrefferedArea(let areaCode, let uniqueId):
                paramsURL.queryItems = [URLQueryItem(name: ConstsKey.UNIQUE_ID, value: uniqueId),
                                        URLQueryItem(name: ConstsKey.AREA_CODE, value: "\(areaCode)")]
                return paramsURL.url
            default:
                return nil
            }
        }
        return nil
    }
    
    var requestURL:URLRequest?{
        var endPoint = "\(ConstsKey.BASE_URL)/\(ConstsKey.MANAGEMENT)/\(ConstsKey.AREAS)"
        var method:String
        switch self {
        case .GetAllAreas:
            endPoint+="/\(ConstsKey.GET_ALL_AREAS)"
            method = "GET"
        case .SetPrefferedArea:
            endPoint+="/\(ConstsKey.PREFFERD_AREA)"
            method = "POST"
        case .GetPrefferedAreas:
            endPoint+="/\(ConstsKey.PREFFERD_AREA)"
            method = "GET"
        case .DeletePrefferedArea:
            endPoint+="/\(ConstsKey.DELETE_PREFFERED_AREA)"
            method = "DELETE"
        }
        
        if method == "POST"
        {
            if let url = URL(string: endPoint)
            {
                var sessionOpt = URLRequest(url: url)
                sessionOpt.httpMethod = method
                sessionOpt.setValue("Application/json", forHTTPHeaderField: "Content-Type")
                guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {return nil}
                sessionOpt.httpBody = bodyData
                return sessionOpt
            }
        }
        else if method == "GET" || method == "DELETE"
        {
            if let url = pramas(of: endPoint){
                var sessionOpt = URLRequest(url: url)
                sessionOpt.httpMethod = method
                return sessionOpt
            }
            return nil
        }
        return nil
    }
}
