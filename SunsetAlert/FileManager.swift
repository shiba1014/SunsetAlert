//
//  FileManager.swift
//  SunsetAlert
//
//  Created by Paul McCartney on 2016/06/24.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit

class FileManager: NSObject {
    static var documentRoot = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    class func getFilePath(fileName: String) -> String{
        return documentRoot.stringByAppendingString(fileName)
    }
    
    class func saveImagePath(image:UIImage, createdDate:NSDate){
        
        let now:NSDate = NSDate()
        let df:NSDateFormatter = NSDateFormatter()
        df.dateFormat = "yyyyMMddHHmmSS"
        
        let fileName = "/" + df.stringFromDate(now) + ".jpg"
        
        //　ファイルのパス
        let filePath = documentRoot.stringByAppendingString(fileName)
        let myfile:NSData = UIImageJPEGRepresentation(image, 0.5)!
        myfile.writeToFile(filePath, atomically: true)
        
        ResourceModel.sharedInstance.setResource(fileName)
    }
}
