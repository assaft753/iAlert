//
//  Area.swift
//  iAlert
//
//  Created by Assaf Tayouri on 11/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation

class Area:CustomStringConvertible{
    var description: String{
        return citiesNames.count == 1 ? citiesNames.first!.localized : citiesNames.map{ $0.localized }.joined(separator: ", ")
    }
    
    var areaCode:Int
    var citiesNames:[String]
    var isPreffered:Bool
    
    init(areaCode:Int,citiesNames:[String]) {
        self.areaCode = areaCode
        self.citiesNames = citiesNames
        self.isPreffered = false
    }
    
    func containsInCity(keyWord:String)->Bool
    {
        return citiesNames.map({$0.localized}).filter{
            return $0.lowercased().contains(keyWord)
        }.count > 0
    }
}
