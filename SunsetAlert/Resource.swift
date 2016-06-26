//
//  Resource.swift
//  SunsetAlert
//
//  Created by Paul McCartney on 2016/06/24.
//  Copyright © 2016年 shiba. All rights reserved.
//

import RealmSwift

class Resource: Object {
    
    dynamic var id: Int = 0
    dynamic var fileName:String = ""
    dynamic var created = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
