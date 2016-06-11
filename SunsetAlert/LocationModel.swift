//
//  LocationModel.swift
//  SunsetAlert
//
//  Created by Paul McCartney on 2016/06/11.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit
import CoreLocation

class LocationModel:NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    func getLocation() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.NotDetermined) {
            print("didChangeAuthorizationStatus:\(status)");
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("緯度：\(manager.location?.coordinate.latitude)")
        print("経度：\(manager.location?.coordinate.longitude)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}
