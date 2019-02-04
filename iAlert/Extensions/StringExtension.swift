//
//  StringExtension.swift
//  iAlert
//
//  Created by Assaf Tayouri on 03/02/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation


extension String {
    var localized: String {
        var language:String!
       
        if let currentLanguage = UserDefaults.standard.string(forKey: ConstsKey.PREFFERED_LANGUAGE) {
            language = currentLanguage
        }
        else {
            UserDefaults.standard.set(Languages.English.languageIdentifier, forKey: ConstsKey.PREFFERED_LANGUAGE)
            UserDefaults.standard.synchronize()
            language = Languages.English.languageIdentifier
        }
        
        print("the preffered language is \(language!)")
        
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
