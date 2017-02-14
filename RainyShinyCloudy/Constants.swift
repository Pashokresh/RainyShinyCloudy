//
//  Constants.swift
//  RainyShinyCloudy
//
//  Created by Павел Мартыненков on 13.12.16.
//  Copyright © 2016 Pavel Martynenkov. All rights reserved.
//

import Foundation


var latitudeValue = Location.sharedInstance.latitude!
var longtitudeValue = Location.sharedInstance.longtitude!

typealias DownloadComplete = () -> ()

let CURRENT_WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitudeValue)&lon=\(longtitudeValue)&appid=ea2e4e853eb17c9705607c1e4bfae7fb"
let FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitudeValue)&lon=\(longtitudeValue)&cnt=10&mode=json&appid=ea2e4e853eb17c9705607c1e4bfae7fb"
