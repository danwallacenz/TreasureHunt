//
//  GeoLocation.swift
//  TreasureHunt
//
//  Created by Daniel Wallace on 4/11/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import MapKit

struct GeoLocation {
    var latitude: Double
    var longitude: Double
    // structs can have methods just like classes can.
    func distanceBetween(other: GeoLocation) -> Double {
        let locationA = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let locationB = CLLocation(latitude: other.latitude,
        longitude: other.longitude)
        return locationA.distanceFromLocation(locationB)
    }
    
}

// structs can have extensions too
extension GeoLocation {
    var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(self.latitude, self.longitude)
    }
    
    var mapPoint: MKMapPoint {
        return MKMapPointForCoordinate(self.coordinate)
    }
}