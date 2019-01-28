//
//  Utilities.swift
//  iAlert
//
//  Created by Assaf Tayouri on 28/01/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Foundation

class Utilities{
    typealias XY = (x:Double,y:Double)
   /* static func calculateDerivedPosition(latitude:Double,longitude:Double,range:Double,bearing:Double) -> (lat:Double, lon: Double)
    {
        let EarthRadius:Double = 6371000
        
        let latA = Measurement(value: latitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let lonA = Measurement(value: longitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let trueCourse = Measurement(value: bearing, unit: UnitAngle.degrees).converted(to: .radians).value
        
        let angularDistance = range / EarthRadius
        
        var lat = asin(sin(latA) * cos(angularDistance) + cos(latA) * sin(angularDistance) * cos(trueCourse));
        
        let dlon = atan2(
            sin(trueCourse) * sin(angularDistance) * cos(latA),cos(angularDistance) - sin(latA) * sin(lat))
        
        var lon = (lonA + dlon + Double.pi).truncatingRemainder(dividingBy: (Double.pi * 2)) - Double.pi;
        
        lat = Measurement(value: lat, unit: UnitAngle.radians).converted(to: .degrees).value
        lon = Measurement(value: lon, unit: UnitAngle.radians).converted(to: .degrees).value
        
        return (lat: lat,lon: lon)
        
    }*/
    
    static func degreeToXY(latitude:Double,longitude:Double)->XY
    {
        let R = 6371.0
        let latx = Measurement(value: latitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let lonx = Measurement(value: longitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let x = R * cos(latx) * cos(lonx)
        
        let laty = Measurement(value: latitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let lony = Measurement(value: longitude, unit: UnitAngle.degrees).converted(to: .radians).value
        let y = R * cos(laty) * sin(lony)
        
        return (x,y)
    }
    
    static func distanceBetweenTwoPoints(point1:XY,point2:XY)->Double
    {
        return pow(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2), 0.5)
    }
    
    
}
