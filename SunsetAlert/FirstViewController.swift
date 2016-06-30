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
import Photos

class FirstViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var sunsetTimeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var lat: Double = 0
    var lng: Double = 0
    
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        sunsetTimeLabel.text = "Loading..."
        locationLabel.text = "-----"
        dateLabel.text = "今日の日の入り時刻"
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.viewController = self
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
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
            locationManager.requestAlwaysAuthorization()
        } else if(status == CLAuthorizationStatus.Denied){
            //設定画面へ
            let alert = UIAlertController(title: nil, message: "位置情報を許可してください", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "設定画面へ", style: .Default, handler: { action in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .Default, handler: nil)
//            alert.addAction(okAction)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.distanceFilter = 10000
//        locationManager.startUpdatingLocation()
//        locationManager.requestLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updated!")
//        print("緯度：\(manager.location?.coordinate.latitude)")
//        print("経度：\(manager.location?.coordinate.longitude)")
        self.revGeocoding((manager.location)!)
        lat = (manager.location?.coordinate.latitude)!
        lng = (manager.location?.coordinate.longitude)!
        self.getSunsetTimeAt(NSDate())
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func getSunsetTimeAt(date:NSDate) {
        
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year,.Month,.Day], fromDate: date)
        let url = "http://labs.bitmeister.jp/ohakon/api/?mode=sun_moon_rise_set&year=\(comp.year)&month=\(comp.month)&day=\(comp.day)&lat=\(lat)&lng=\(lng)"
        
        Alamofire.request(.POST, url)
            .response{ (request, response, data, error) in
                let xml = SWXMLHash.parse(data!)
                let sunsetTime = xml["result"]["rise_and_set"]["sunset_hm"].element?.text
                self.sunsetTimeLabel.text = sunsetTime
                self.getDateFromString(sunsetTime,year: comp.year,month: comp.month,day: comp.day)
                if (error != nil) {
                    print(error)
                }
        }
    }
    
    func getDateFromString(dateString: String!,year: Int!,month: Int!,day: Int!){
        if(dateString == nil){
            return;
        }
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd-HH:m"
        let date = dateFormatter.dateFromString("\(year)/\(month)/\(day)-\(dateString)")
        let result = date?.compare(NSDate())
        let calendar = NSCalendar.currentCalendar()
        if(result == NSComparisonResult.OrderedAscending){
            //日の入り時刻が過ぎていたら翌日の日の入りを取得
            dateLabel.text = "明日の日の入り時刻"
            let tommorow = calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate(), options: NSCalendarOptions())
            let flag: NSCalendarUnit = [ .Year, .Month, .Day]
            let comp: NSDateComponents = calendar.components(flag, fromDate: tommorow!)
            let zero = calendar.dateFromComponents(comp)
            self.getSunsetTimeAt(zero!)
        } else {
            //日の入りがまだだったら通知を設定
            let ud = NSUserDefaults.standardUserDefaults()
            print(ud.stringForKey("notifSetDate"))
            print("\(year)/\(month)/\(day)-\(dateString)")
            if(ud.stringForKey("notifSetDate") == "\(year)/\(month)/\(day)-\(dateString)"){
                print("hasSetNotification")
                return
            }
            self.setLocalNotif(date!)
        }
    }
    
    func setLocalNotif(sunsetDate: NSDate){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification: UILocalNotification = UILocalNotification()
        notification.alertBody = "日の入り時刻です。空を見てみませんか？"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.fireDate = sunsetDate
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year,.Month,.Day,.Hour,.Minute], fromDate: sunsetDate)
        var dateStr: String
        if(comp.minute < 10){
            dateStr = "\(comp.year)/\(comp.month)/\(comp.day)-\(comp.hour):0\(comp.minute)"
        } else {
            dateStr = "\(comp.year)/\(comp.month)/\(comp.day)-\(comp.hour):\(comp.minute)"
        }
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(dateStr, forKey: "notifSetDate")
        ud.synchronize()
        print("setLocalNotif!")
    }
    
    func revGeocoding(location: CLLocation)
    {
//        let location = CLLocammtion(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if (error == nil && placemarks!.count > 0) {
                let placemark = placemarks![0] as CLPlacemark
//                print("Country = \(placemark.country)")
//                print("Postal Code = \(placemark.postalCode)")
//                print("Administrative Area = \(placemark.administrativeArea)")
//                print("Sub Administrative Area = \(placemark.subAdministrativeArea)")
//                print("Locality = \(placemark.locality)")
//                print("Sub Locality = \(placemark.subLocality)")
//                print("Throughfare = \(placemark.thoroughfare)")
                
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if(info[UIImagePickerControllerOriginalImage] != nil){
            
            var url: NSURL = NSURL()
            
            if info[UIImagePickerControllerReferenceURL] != nil {
                //ライブラリから洗濯
                url = info[UIImagePickerControllerReferenceURL] as! NSURL
                let fetchResult = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil)
                if (fetchResult.count != 0) {
                    let asset: PHAsset = fetchResult.firstObject as! PHAsset
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .HighQualityFormat
                    options.resizeMode = .Exact
                    
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(CGFloat(asset.pixelWidth),CGFloat(asset.pixelHeight)), contentMode: .AspectFill, options: options) { (result: UIImage?, info: [NSObject : AnyObject]?) -> Void in
                        let isDegraded:Bool  = info![PHImageResultIsDegradedKey] as! Bool
                        if(!isDegraded){
                            FileManager.saveImagePath(result!,createdDate: asset.creationDate!)
                        }
                    }
                    
                    picker.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    //フォトストリーム上の写真を選択
                    picker.dismissViewControllerAnimated(true, completion: {
                        let alert:UIAlertController = UIAlertController(title: "Sorry...", message: "フォトストリーム上の写真はアップロードできません", preferredStyle: .Alert)
                        let action:UIAlertAction = UIAlertAction(title: "しょうがない", style: .Default, handler:nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            } else {
                //カメラで撮影
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(FirstViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                
                picker.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.fetchLimit = 1
        let assets: PHFetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        assets.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            let options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Exact
            
            PHImageManager.defaultManager().requestImageForAsset(asset as! PHAsset, targetSize: CGSizeMake(CGFloat(asset.pixelWidth),CGFloat(asset.pixelHeight)), contentMode: .AspectFill, options: options) { (result: UIImage?, info: [NSObject : AnyObject]?) -> Void in
                let isDegraded:Bool = info![PHImageResultIsDegradedKey] as! Bool
                if(!isDegraded){
                    FileManager.saveImagePath(result!,createdDate: asset.creationDate!!)
                }
            }
        }
    }

    
    @IBAction func tappedMyPhotos() {
        let vc = MyPhotosViewController()
        let navi = UINavigationController(rootViewController: vc)
        self.presentViewController(navi, animated: true, completion: nil)
    }
    
}
