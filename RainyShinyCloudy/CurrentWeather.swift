//
//  CurrentWeather.swift
//  RainyShinyCloudy
//
//  Created by Павел Мартыненков on 13.12.16.
//  Copyright © 2016 Pavel Martynenkov. All rights reserved.
//

import Foundation
import Alamofire

class CurrentWeather {
    
    var _cityName: String!
    var _date: String!
    var _weatherType: String!
    var _currentTemp: Double!
    
    var cityName: String {
        if _cityName == nil {
            _cityName = ""
        }
        return _cityName
    }
    
    var date: String {
        if _date == nil {
            _date = ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let currentDate = dateFormatter.string(from: Date())
        self._date = "Сегодня, \(currentDate)"
        
        return _date
    }

    var weatherType: String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
    }
    
    var currentTemp: Double {
        if _currentTemp == nil {
            _currentTemp = 0.0
        }
        return _currentTemp
 }
    
    
    func downloadWeatherDetails(completed: @escaping DownloadComplete) {
        //Alamofire download
        
        let currentWeatherURL = URL(string: CURRENT_WEATHER_URL)!
        
        Alamofire.request(currentWeatherURL, method: .get).responseJSON { response in
            
            if let dict = response.result.value as? Dictionary <String, AnyObject> {
               
                if let name = dict["name"] as? String {
                    self._cityName = name.capitalized
                }
                
                if let weather = dict["weather"] as? [Dictionary<String, AnyObject>] {
        
                    if let main = weather[0]["main"] as? String {
                        self._weatherType = main.capitalized
                    }
                }
                
                if let mainTemp = dict["main"] as? Dictionary<String, AnyObject> {
                    
                    if let temp = mainTemp["temp"] as? Double {
                        
                        self._currentTemp = CurrentWeather.kelvinToCelseus(kelvin: temp)
                    }
                }
            }
            completed()
        }
        
    }
   
    
    static func kelvinToCelseus(kelvin: Double) -> Double {
        
        return round(kelvin - 273.15)
    }
}

