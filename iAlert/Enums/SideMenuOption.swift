//
//  SideMenuOptions.swift
//  iAlert
//
//  Created by Assaf Tayouri on 02/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation
import UIKit


enum SideMenuOption:Int,CustomStringConvertible
{
    case Language
    case Areas
    case Sound
    
    var description: String{
        switch self{
        case .Language: return "Language".localized
        case .Areas: return "Areas".localized
        case .Sound: return  "Sound".localized
        }
    }
    
    var optionImage:UIImage
    {
        switch self{
        case .Language: return #imageLiteral(resourceName: "language_icon")
        case .Areas: return #imageLiteral(resourceName: "areas_icon")
        case .Sound: return #imageLiteral(resourceName: "sound_icon")
        }
    }
    
    static let numberOfOptions = 3
    
}
