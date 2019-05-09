//
//  NSManagedObjectContextExtension.swift
//  iAlert
//
//  Created by Assaf Tayouri on 30/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit
import CoreData

extension NSManagedObjectContext{
    static var context:NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
