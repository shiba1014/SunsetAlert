//
//  ResourceModel.swift
//  SunsetAlert
//
//  Created by Paul McCartney on 2016/06/24.
//  Copyright © 2016年 shiba. All rights reserved.
//

import RealmSwift

class ResourceModel: NSObject {

    private var resources: [Resource] = []
    
    let realm = try! Realm()
    
    //シングルトン
    class var sharedInstance: ResourceModel {
        struct Singleton {
            static let instance: ResourceModel = ResourceModel()
        }
        return Singleton.instance
    }

    func getResources() -> [Resource] {
        return self.resources
    }
    
    func setResource(fileName:String) {
        let resource = Resource()
        resource.fileName = fileName
        
        if realm.objects(Resource).last != nil{
            resource.id = (realm.objects(Resource).last?.id)! + 1
        }else{
            resource.id = 0
        }
        try! realm.write{
            realm.add(resource, update: true)
        }
        self.updateResource()
    }
    
    func deleteResource(fileName:String)
    {
        
        let deleteData = realm.objects(Resource).filter("fileName = '\(fileName)'")
        try! realm.write {
            realm.delete(deleteData)
        }
        self.updateResource()
        
    }
    
    func updateResource(){
        
        let results = realm.objects(Resource)
        var temp: [Resource] = []
        
        for result in results {
            temp.append(result)
        }
        resources.removeAll()
        resources = temp
    }
}
