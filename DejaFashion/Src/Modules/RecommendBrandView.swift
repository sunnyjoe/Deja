//
//  RecommendBrandView.swift
//  DejaFashion
//
//  Created by jiao qing on 21/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class RecommendBrandView: UIView {
    private let bgView = UIImageView()
    
    private let nameLabel = UILabel()
    private let descLabel = UILabel()
    private let numberLabel = UILabel()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.backgroundColor = DJCommonStyle.Color2F
        bgView.frame = self.bounds
        bgView.contentMode = .ScaleAspectFill
        addSubview(bgView)
        
        nameLabel.numberOfLines = 1
        descLabel.numberOfLines = 1
        numberLabel.numberOfLines = 1
        
        bgView.addSubviews(nameLabel, numberLabel, descLabel)
        
        nameLabel.withTextColor(UIColor.whiteColor()).withFontHeleticaMedium(18)
        descLabel.withTextColor(UIColor(fromHexString: "cccccc")).withFontHeletica(14)
        numberLabel.withTextColor(UIColor.defaultRed()).withFontHeletica(17)
        
        constrain(nameLabel, descLabel, numberLabel) { nameLabel, descLabel, numberLabel in
            nameLabel.centerX == nameLabel.superview!.centerX
            nameLabel.top == nameLabel.superview!.top + 34
            
            descLabel.top == descLabel.superview!.top + 64
            numberLabel.top == descLabel.top - 1
            
            descLabel.left == numberLabel.right + 5
            
            descLabel.centerX == descLabel.superview!.centerX + 13
        }

    }
    
    func setInfos(name : String, number : String, desc : String){
        nameLabel.text = name
        numberLabel.text = number
        descLabel.text = desc
    }
    
    func brandBackgroundImage(urlStr : String){
        bgView.sd_setImageWithURLStr(urlStr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
