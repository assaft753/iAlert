//
//  UIFontExtension.swift
//  iAlert
//
//  Created by Assaf Tayouri on 30/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit

extension UIFont{
    static var DEFAULT_FONT: UIFont{
        if let rubikFont = UIFont(name: "Rubik-Regular", size: UIFont.labelFontSize) {
            guard #available(iOS 11.0, *) else{return rubikFont}
            return UIFontMetrics.default.scaledFont(for: rubikFont)
        }
        else{
            return UIFont.systemFont(ofSize: UIFont.labelFontSize)
        }
    }
    
    static func printAllFontFamilies()
    {
        for family in UIFont.familyNames.sorted() {
         let names = UIFont.fontNames(forFamilyName: family)
         print("Family: \(family) Font names: \(names)")
         }
    }
}
