//
//  CollectionViewCell.swift
//  SunsetAlert
//
//  Created by Paul McCartney on 2016/06/24.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    var imageView = UIImageView()
    var fileName: String!
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.backgroundColor = UIColor.whiteColor()
        
        imageView.frame = CGRectMake(0, 0, frame.width, frame.height)
        imageView.layer.masksToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.contentView.addSubview(imageView)

    }
    
}
