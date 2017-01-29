//
//  DistanceView.swift
//  DejaFashion
//
//  Created by Sun lin on 29/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

class DistanceView: UIView {
    
    private let distanceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = UIColor(fromHexString: "f2f2f2")
        let iconIV = UIImageView()
        iconIV.image = UIImage(named : "MapMakerIcon")
        iconIV.contentMode = UIViewContentMode.Center
        
        
        distanceLabel.withTextColor(UIColor.defaultBlack()).withFontHeletica(15)
        addSubviews(distanceLabel, iconIV)
//        nameLabel.numberOfLines = 2
        distanceLabel.numberOfLines = 1
        constrain(distanceLabel, iconIV) {distanceLabel, iconIV in
            iconIV.left == iconIV.superview!.left + 11
            iconIV.top == iconIV.superview!.top
            iconIV.bottom == iconIV.superview!.bottom
            
            distanceLabel.top == iconIV.top
            distanceLabel.left == iconIV.right + 5
            distanceLabel.bottom == distanceLabel.superview!.bottom
        }
        
        layer.shadowRadius = 1
        layer.shadowOffset = CGSizeMake(0, 0)
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        
    }
    
    
    func setDistance(str : String){
        distanceLabel.withText(str)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}