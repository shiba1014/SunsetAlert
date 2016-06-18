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

class FirstViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var sunsetTimeLabel: UILabel!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
//        locationManager.startUpdatingLocation()
        locationManager.requestLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("緯度：\(manager.location?.coordinate.latitude)")
        print("経度：\(manager.location?.coordinate.longitude)")
        self.getSunsetTime((manager.location?.coordinate.latitude)!, lng: (manager.location?.coordinate.longitude)!)
        self.revGeocoding((manager.location)!)
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func getSunsetTime(lat:Double, lng:Double) {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year,.Month,.Day], fromDate: now)

        let url = "http://labs.bitmeister.jp/ohakon/api/?mode=sun_moon_rise_set&year=\(comp.year)&month=\(comp.month)&day=\(comp.day)&lat=\(lat)&lng=\(lng)"
        print(url)
        Alamofire.request(.POST, url)
            .response{ (request, response, data, error) in
                print(data)
                let xml = SWXMLHash.parse(data!)
                let sunsetTime = xml["result"]["rise_and_set"]["sunset_hm"].element?.text
                //TODO:xmlから取得できなくなった
                print("sunsetTimme:\(sunsetTime)")
                self.sunsetTimeLabel.text = sunsetTime
                self.getDateFromString(sunsetTime,year: comp.year,month: comp.month,day: comp.day)
                if (error != nil) {
                    print(error)
                }
        }
    }
    
    func getDateFromString(dateString: String!,year: Int!,month: Int!,day: Int!){
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm"
        let date = dateFormatter.dateFromString("\(year)/\(month)/\(day)-\(dateString)")
        print(date)
    }
    
    func revGeocoding(location: CLLocation)
    {
//        let location = CLLocammtion(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if (error == nil && placemarks!.count > 0) {
                let placemark = placemarks![0] as CLPlacemark
                print("Country = \(placemark.country)")
                print("Postal Code = \(placemark.postalCode)")
                print("Administrative Area = \(placemark.administrativeArea)")
                print("Sub Administrative Area = \(placemark.subAdministrativeArea)")
                print("Locality = \(placemark.locality)")
                print("Sub Locality = \(placemark.subLocality)")
                print("Throughfare = \(placemark.thoroughfare)")
                
                if let area = placemark.administrativeArea, locality = placemark.locality {
                        self.locationLabel.text = "\(area)\(locality)"
                }
                
            } else if (error == nil && placemarks!.count == 0) {
                print("No results were returned.")
            } else if (error != nil) {
                print("An error occured = \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func tappedUploadPhoto() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cameraButton = UIAlertAction(title: "カメラで撮る", style: .Default) { action in
            self.openCamera()
        }
        let libraryButton = UIAlertAction(title: "ライブラリを開く", style: .Default) { action in
            self.openLibrary()
        }
        let cancelButton = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        actionSheet.addAction(cameraButton)
        actionSheet.addAction(libraryButton)
        actionSheet.addAction(cancelButton)
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    func openLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}
