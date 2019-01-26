//
//  iAlertService.swift
//  iAlert
//
//  Created by Assaf Tayouri on 26/01/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation

class iAlertService{
    static var shared = iAlertService()
    
    public func fetch(type idle:Idle, compilation:@escaping ([String:Any]?,Error?)->Void)
    {
        let requestBody = idle.requestBody
        let requestURL = idle.requestURL
        if let url = requestURL{
            var sessionOpt = URLRequest(url: url)
            sessionOpt.httpMethod = "POST"
            sessionOpt.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {return}
            sessionOpt.httpBody = bodyData
            self.activate(session: sessionOpt, compilation: compilation)
        }
    }
    
    public func fetch(type operative:Operative, compilation:@escaping ([String:Any]?,Error?)->Void)
    {
        let requestBody = operative.requestBody
        let requestURL = operative.requestURL
        if let url = requestURL{
            var sessionOpt = URLRequest(url: url)
            sessionOpt.httpMethod = "POST"
            sessionOpt.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {return}
            sessionOpt.httpBody = bodyData
            self.activate(session: sessionOpt, compilation: compilation)
        }
    }
    
    private func activate(session sessionOpt:URLRequest,compilation:@escaping ([String:Any]?,Error?)->Void)
    {
        let session = URLSession.shared.dataTask(with: sessionOpt){ (data, response, err) in
            if let error = err
            {
                compilation(nil,error)
            }
            if let data = data
            {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    compilation(json, nil)
                }
                catch let jsonErr
                {
                    compilation(nil,jsonErr)
                }
            }
        }
        session.resume()
    }
}

