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
    
    public func fetch(type idle:Idle, compilation:(([String:Any]?,Error?)->Void)? = nil)
    {
        if let requestURL = idle.requestURL{
            self.activate(session: requestURL, compilation: compilation)
        }
    }
    
    public func fetch(type operative:Operative, compilation:(([String:Any]?,Error?)->Void)? = nil)
    {
        if let requestURL = operative.requestURL{
            self.activate(session: requestURL, compilation: compilation)
        }
    }
    
    private func activate(session sessionOpt:URLRequest,compilation:(([String:Any]?,Error?)->Void)?)
    {
        let session = URLSession.shared.dataTask(with: sessionOpt){ (data, response, err) in
            print("in data!!! \(data)")
            print("in err!!! \(err)")
            print("in response!!! \(response)")
            if let compilation = compilation
            {
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
        }
        session.resume()
    }
}

