//
//  Location.swift
//  RainyShinyCloudy
//
//  Created by Павел Мартыненков on 07.02.17.
//  Copyright © 2017 Pavel Martynenkov. All rights reserved.
//

import CoreLocation

class Location {
    
    static var sharedInstance = Location()
    
    private init() {
        
    }
    
    var latitude: Double!
    var longtitude: Double!
}
