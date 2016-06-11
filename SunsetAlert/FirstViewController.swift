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

class FirstViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var sunsetTimeLabel: UILabel!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //LocationModel().getLocation()
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
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("緯度：\(manager.location?.coordinate.latitude)")
        print("経度：\(manager.location?.coordinate.longitude)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}
