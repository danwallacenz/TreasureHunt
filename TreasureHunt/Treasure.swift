//
//  Treasure.swift
//  TreasureHunt
//
//  Created by Daniel Wallace on 4/11/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation

class Treasure {
    let what: String
    let location: GeoLocation
    
    init(what: String, location: GeoLocation) {
        self.what = what
        self.location = location
    }
    
    convenience init(what:String, latitude: Double, longitude: Double)
    {
        let location = GeoLocation(latitude: latitude, longitude: longitude)
        self.init(what: what, location: location)
    }
}

class HistoryTreasure: Treasure {
    let year: Int
    
    init(what: String, year: Int, latitude: Double, longitude: Double)
    {
        self.year = year
        let location = GeoLocation(latitude: latitude, longitude: longitude)
        super.init(what: what, location: location)
    }
}

class FactTreasure: Treasure {
    let fact: String
    
    init(what:String, fact: String, latitude: Double, longitude: Double)
    {
        self.fact = fact
        let location = GeoLocation(latitude: latitude, longitude: longitude)
        super.init(what: what, location: location)
    }
}

class HQTreasure: Treasure {
    let company: String
    
    init(company: String, latitude: Double, longitude: Double)
    {
        self.company = company
        let location = GeoLocation(latitude: latitude, longitude: longitude)
        super.init(what: company + " headquarters", location: location)
    }
}