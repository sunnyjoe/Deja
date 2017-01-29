//
//  TryOnClothCollectionCell.swift
//  DejaFashion
//
//  Created by jiao qing on 7/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class TryOnClothCollectionCell: FindClothCollectionCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        brandLabel.hidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func imageViewLayout(){
        constrain(imageView, block: { (v) in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.top == v.superview!.top
            v.bottom == v.superview!.bottom - 30
        })
    }
    
    override class func calculateCellSize(clothSummary : Clothes) -> CGSize {
//        let imageWidth = (UIScreen.mainScreen().bounds.width - 19 - 46) / 2
//        var imageHeight : CGFloat = 0
//        if clothSummary.thumbUrl == nil ||  clothSummary.thumbHeight == nil || clothSummary.thumbWidth == nil || clothSummary.thumbHeight == 0 {
//            imageHeight = imageWidth
//        }else{
//            imageHeight = (imageWidth) * CGFloat(clothSummary.thumbHeight!) / CGFloat(clothSummary.thumbWidth!)
//            // some old clothes
//            if Int(clothSummary.uniqueID!) < 30000 {
//                imageHeight = (imageWidth - 60) * CGFloat(clothSummary.thumbHeight!) / CGFloat(clothSummary.thumbWidth!) + 60
//            }
//            if imageHeight > imageWidth * 1.65 {
//                imageHeight = imageWidth * 1.65
//            }
//        }
        let size = FindClothCollectionCell.calculateCellSize(clothSummary)
        
        return CGSizeMake(size.width, size.height - 30)
    }
    

}
