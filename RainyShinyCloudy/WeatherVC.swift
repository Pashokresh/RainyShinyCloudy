//
//  WeatherVC.swift
//  RainyShinyCloudy
//
//  Created by Павел Мартыненков on 06.12.16.
//  Copyright © 2016 Pavel Martynenkov. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class WeatherVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentWeatherTypeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var currentWeather: CurrentWeather!
    var forecast: Forecast!
    var forecasts = [Forecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(getWeatherInfo), for: .valueChanged)
        tableView.addSubview(refreshControl)
        currentWeather = CurrentWeather()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationAuthStatus()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getWeatherInfo() {
        currentWeather.downloadWeatherDetails {
            self.downloadForecastData {
                self.updateMainUI()
                self.tableView.reloadData()
                if self.refreshControl.isRefreshing {self.refreshControl.endRefreshing()}
                
            }
        }
    }
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            currentLocation = locationManager.location
            
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longtitude = currentLocation.coordinate.longitude
            
            self.getWeatherInfo()
        }
    }
    
    func downloadForecastData(completed: @escaping DownloadComplete) {
        
        let forecastURL = URL(string: FORECAST_URL)!
        
        
        Alamofire.request(forecastURL, method: .get).responseJSON { response in
            
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    self.forecasts.removeAll()
                    for obj in list {
                        let forecast = Forecast(weatherDict: obj)
                        self.forecasts.append(forecast)
                    }
                    self.forecasts.remove(at: 0)
                }
            }
            completed()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as? WeatherCell {

            cell.configureCell(forecast: forecasts[indexPath.row])
            
            return cell
        } else {
            
            return WeatherCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func updateMainUI() {
        
        dateLabel.text = currentWeather.date
        currentTempLabel.text = "\(Int(round(currentWeather.currentTemp)) > 0 ? "+" : "")\(Int(currentWeather.currentTemp))°C"
        locationLabel.text = currentWeather.cityName
        currentWeatherTypeLabel.text = currentWeather.weatherType
        currentWeatherImage.image = UIImage(named: currentWeather.weatherType)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationAuthStatus()
        } else if status == .denied {
            let alert = UIAlertController(title: "Вы запретили определение местоположения", message: "Включите определение местоположения в настройках", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default, handler: { [weak self](_) in
                self?.locationManager.requestWhenInUseAuthorization()
                alert.dismiss(animated: true, completion: nil)
                
                guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                UIApplication.shared.openURL(settingsURL)
            })
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = locations.first {
            
            locationManager.stopUpdatingLocation()
        }
    }
    
}

