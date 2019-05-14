//
//  ConstsKey.swift
//  iAlert
//
//  Created by Assaf Tayouri on 26/01/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation
import UIKit

struct ConstsKey{
    static let UNIQUE_ID = "unique_id"
    static let PREV_ID = "prev_id"
    static let IS_ANDROID = "is_android"
    static let LATITUDE = "lat"
    static let LANGITUDE = "lang"
    static let CITY = "city"
    static let LANGUAGE = "language"
    static let AREA_CODE = "area_code"
    static let RED_ALERT_ID = "red_alert_id"
    static let LATITUDE2 = "latitude"
    static let LANGITUDE2 = "longitude"
    static let BASE_URL = "http://109.226.11.202:3000"
    static let IDLE = "idle"
    static let OPERATIVE = "operative"
    static let MANAGEMENT = "management"
    static let AREAS = "areas"
    static let REGISTER = "register"
    static let UPDATE = "update"
    static let DELETE_PREFFERED_AREA = "OnePreferred"
    static let PREFFERED_LANGUAGE = "preferred_language"
    static let ARRIVE = "arrive"
    static let GET_ALL_AREAS = "getAll"
    static let PREFFERD_AREA = "preferred"
    static let CLOSESTS_SHELTER = "closestSheltersAfterNotification"
    static let ALL_CLOSESTS_SHELTER = "closestShelters"
    static let BOUND:Double = 40
    static let SOUND:String = "sound"
    static let CIRCULAR_EXIT_REGION_ID:String = "GMSmap_EXIT_Region"
    static let CIRCULAR_EXIT_REGION_RADIUS:Double = 300
    static let CIRCULAR_ENTER_REGION_ID:String = "GMSmap_ENTER_Region"
    static let CIRCULAR_ENTER_REGION_RADIUS:Double = 1
    static let GMS_STREET_NUMBER = "street_number"
    static let GMS_STREET_NAME = "route"
    static let GMS_CITY = "locality"
    static let GMS_COUNTRY = "country"
    static let GMS_TYPE = "types"
    static let GMS_LONG_NAME = "long_name"
}
