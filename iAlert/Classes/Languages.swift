//
//  Languages.swift
//  iAlert
//
//  Created by Assaf Tayouri on 03/02/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation


enum Languages {
    case English
    case Hebrew
    
    var languageIdentifier:String{
        switch self {
        case .English:
            return ConstsKey.ENGLISH_ID
        case.Hebrew:
            return ConstsKey.HEBREW_ID
        }
    }
}
