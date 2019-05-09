//
//  Languages.swift
//  iAlert
//
//  Created by Assaf Tayouri on 03/02/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation



enum Language{
    static let ENGLISH_ID = "en"
    private static let ENGLISH_ID_GMS = "en"
    private static let ENGLISH_STR = "English"
    private static let ENGLISH_PRESENTAION = "english"
    
    static let HEBREW_ID = "he"
    private static let HEBREW_ID_GMS = "iw"
    private static let HEBREW_STR = "עברית"
    private static let HEBREW_PRESENTAION = "hebrew"
    
    static let LANGUAGE_STRS = [ENGLISH_STR,HEBREW_STR]
    static let LANGUAGE_IDS = [ENGLISH_ID,HEBREW_ID]
    static let LANGUAGE_PRESENTAION = [ENGLISH_ID:ENGLISH_PRESENTAION,HEBREW_ID:HEBREW_PRESENTAION]
    
    static let PREFFERED_LANGUAGE = "preferred_language"
    
    typealias RawValue = (direction:Direction,languageId:String,GMSLanguageId:String)
    
    case English(RawValue)
    case Hebrew(RawValue)
    
    var languageIdentifier:String{//TODO: delete
        switch self {
        case .English:
            return Language.ENGLISH_ID
        case.Hebrew:
            return Language.HEBREW_ID
        }
    }
    
    
    static func getLanguage(of languageId:String)->Language?
    {
        switch languageId {
        case ENGLISH_ID:
            return Language.English((direction:.LTR,languageId:ENGLISH_ID,GMSLanguageId:ENGLISH_ID_GMS))
        case HEBREW_ID:
            return Language.Hebrew((direction:.RTL,languageId:HEBREW_ID,GMSLanguageId:HEBREW_ID_GMS))
        default:
            return nil
        }
    }
    
    var associatedValues:RawValue
    {
        switch self {
        case .English(let direction, let languageId, let GMSLanguageId):
            return (direction:direction,languageId:languageId,GMSLanguageId:GMSLanguageId)
        case .Hebrew(let direction, let languageId, let GMSLanguageId):
            return RawValue(direction,languageId,GMSLanguageId)
        }
    
    }
    
    static var DEFAULT_LANGUAGE:Language{
        return Language.English((direction:.LTR,languageId:ENGLISH_ID,GMSLanguageId:ENGLISH_ID_GMS))
    }
}
