//
//  GenaralClass.swift
//  AppleMapB1
//
//  Created by Jakkawad Chaiplee on 2/10/2560 BE.
//  Copyright © 2560 Jakkawad Chaiplee. All rights reserved.
//

import Foundation

func convertDistance(distance: Double) -> Double {
    let km = distance / 1000
    return km
}

func deg2rad(deg:Double) -> Double {
    return deg * (M_PI/180)
}

func getBetweenPoint(p1Lati:Double, p1Long:Double, p2Lati:Double, p2Long:Double) -> Double {
    let r:Double = 6371.0
    let dLat = deg2rad(deg: p2Lati - p1Lati)
    let dLon = deg2rad(deg: p2Long - p2Long)
    let a = sin(dLat/2) * sin(dLat/2) + cos(deg2rad(deg: p1Lati)) * cos(deg2rad(deg: p1Lati)) * sin(dLon/2) * sin(dLon/2)
    let c = 2 * atan2(sqrt(a), sqrt(1-a))
    let d = r * c
    return d
}
