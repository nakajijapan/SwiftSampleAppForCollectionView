//
//  CollectionViewCell.swift
//  sample-app-for-collectionview
//
//  Created by nakajijapan on 10/11/14.
//  Copyright (c) 2014 net.nakajijapan. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBackGroundImage(image: UIImage) {
        
        let clip: CGImageRef! = CGImageCreateWithImageInRect(image.CGImage, self.frame)
        let clippedImage = UIImage(CGImage: clip)
        
        self.mainImageView.image = clippedImage;
    }
}
