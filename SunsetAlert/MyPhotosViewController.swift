//
//  MyPhotosViewController.swift
//  SunsetAlert
//
//  Created by Paul McCartney on 2016/06/24.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class MyPhotosViewController: UIViewController,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {

    var collectionView: UICollectionView!
    var resources: [Resource] = []
    var images = [SKLocalPhoto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ResourceModel.sharedInstance.addObserver(self, forKeyPath: "resources", options: [.New], context: nil)
        
        //collectionview
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake((self.view.frame.width - 8) / 4, (self.view.frame.width - 8) / 4)
        layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 2.0
        collectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height), collectionViewLayout: layout)
        collectionView.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)

        let closeButton = UIBarButtonItem(image: UIImage.init(named: "closeButton"), style: .Plain, target: self, action: #selector(self.back))
        self.navigationItem.rightBarButtonItem = closeButton
        
        ResourceModel.sharedInstance.updateResource()
        self.resources = ResourceModel.sharedInstance.getResources()
        
        self.images = []
        for i in resources {
            let photo = SKLocalPhoto.photoWithImageURL(FileManager.getFilePath(i.fileName))
            images.append(photo)
        }
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(contentsOfFile: FileManager.getFilePath(resources[indexPath.row].fileName))
        cell.backgroundColor = UIColor.orangeColor()
        cell.fileName = resources[indexPath.row].fileName
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resources.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(indexPath.row)
        presentViewController(browser, animated: true, completion: {})
    }

    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "resources"{
            //ゲッタを使って変更を取得
            self.resources = ResourceModel.sharedInstance.getResources()
            self.images = []
            for i in resources {
                let photo = SKLocalPhoto.photoWithImageURL(FileManager.getFilePath(i.fileName))
                images.append(photo)
            }
            self.collectionView.reloadData()
        }
    }
}
