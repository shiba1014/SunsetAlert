//
//  FirstViewController.swift
//  SunsetAlert
//
//  Created by Paul McCartney on 2016/06/11.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SWXMLHash

class FirstViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var sunsetTimeLabel: UILabel!
    
    var locationManager: CLLocationManager!
//    var locationModel = LocationModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        LocationModel().getLocation()
        self.getLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
        
        sunsetTimeLabel.text = ""
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("緯度：\(manager.location?.coordinate.latitude)")
        print("経度：\(manager.location?.coordinate.longitude)")
        self.getSunsetTime((manager.location?.coordinate.latitude)!, lng: (manager.location?.coordinate.longitude)!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func getSunsetTime(lat:Double, lng:Double) {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year,.Month,.Day], fromDate: now)

        let url = "http://labs.bitmeister.jp/ohakon/api/?mode=sun_moon_rise_set&year=\(comp.year)&month=\(comp.month)&day=\(comp.day)&lat=\(lat)&lng=\(lng)"
        
        Alamofire.request(.POST, url)
            .response{ (request, response, data, error) in
                print(data)
                let xml = SWXMLHash.parse(data!)
                let sunsetTime = xml["result"]["rise_and_set"]["sunset_hm"].element?.text
                print(sunsetTime)
                self.sunsetTimeLabel.text = sunsetTime
        }
    }

}
