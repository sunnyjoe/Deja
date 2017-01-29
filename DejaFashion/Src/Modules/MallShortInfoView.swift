//
//  MallShortInfoView.swift
//  DejaFashion
//
//  Created by jiao qing on 22/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class MallShortInfoView: UIView {
    private let nameLabel = UILabel()
    private let distanceLabel = UILabel()
    private let RandomMallBg = ["RandomMallBg1","RandomMallBg2","RandomMallBg3","RandomMallBg4","RandomMallBg5","RandomMallBg6"]
    private let bgView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.frame = self.bounds
        addSubview(bgView)
        
        let iconIV = UIImageView()
        iconIV.image = UIImage(named : "MapMakerIcon")
        NSLayoutConstraint(item: iconIV, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15).active = true
        NSLayoutConstraint(item: iconIV, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 11.5).active = true

        addSubviews(nameLabel, distanceLabel, iconIV)
        
        nameLabel.numberOfLines = 2
        distanceLabel.numberOfLines = 1
        constrain(nameLabel, distanceLabel, iconIV) { nameLabel, distanceLabel, iconIV in
            nameLabel.centerX == nameLabel.superview!.centerX
            nameLabel.top == nameLabel.superview!.top + 20
            nameLabel.left == nameLabel.superview!.left + 20
            nameLabel.right == nameLabel.superview!.right - 20
            
            iconIV.left == nameLabel.left
            iconIV.bottom == iconIV.superview!.bottom - 21
            distanceLabel.top == iconIV.top - 3
            distanceLabel.left == iconIV.right + 5
        }
        nameLabel.withTextColor(UIColor.whiteColor()).withFontHeleticaMedium(15)
        distanceLabel.withTextColor(UIColor.whiteColor()).withFontHeletica(15)
    }
    
    func mallName(str : String){
        nameLabel.withText(str)
        let len = str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        let bgIndex = len % 6
        let name = RandomMallBg[bgIndex]
        bgView.image = UIImage(named: name)
    }
    
    func distance(str : String){
        distanceLabel.withText(str)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
