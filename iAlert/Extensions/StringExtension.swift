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
        let languageId:String = Settings.shared.languageId
       
        /*if let currentLanguage = UserDefaults.standard.string(forKey: Language.PREFFERED_LANGUAGE) {
            language = currentLanguage
        }
        else {
            let defaultLanguageId:String = Language.DEFAULT_LANGUAGE.associatedValues.languageId UserDefaults.standard.set(defaultLanguageId, forKey: Language.PREFFERED_LANGUAGE)
            UserDefaults.standard.synchronize()
            language = defaultLanguageId
        }*/
        
        print("the preffered language is \(languageId)")
        
        let path = Bundle.main.path(forResource: languageId, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
