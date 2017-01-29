//
//  FindClothBannerView.swift
//  DejaFashion
//
//  Created by jiao qing on 21/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class FindClothBannerView: UIView {
    private let bgView = UIImageView()
    
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let thirdLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.backgroundColor = DJCommonStyle.Color2F
        bgView.frame = self.bounds
        bgView.contentMode = .ScaleAspectFill
        addSubview(bgView)
    
        firstLabel.withTextColor(UIColor.whiteColor())
        firstLabel.font = DJFont.thinHelveticaFontOfSize(17)
        bgView.addSubview(firstLabel)
        
        var offSet : CGFloat = 0
        if kIphoneSizeScale < 1 {
            offSet = 6
        }
        constrain(firstLabel) { (label) in
            label.top == label.superview!.top + 156 * kIphoneSizeScale - offSet
            label.centerX == label.superview!.centerX
        }
        
        secondLabel.withTextColor(UIColor.whiteColor()).withFontHeletica(30)
        bgView.addSubview(secondLabel)
        constrain(secondLabel) { secondLabel in
            secondLabel.top == secondLabel.superview!.top + 178 * kIphoneSizeScale - offSet
            secondLabel.centerX == secondLabel.superview!.centerX
        }
 
        thirdLabel.withTextColor(UIColor.whiteColor())
        thirdLabel.font = DJFont.thinHelveticaFontOfSize(15)
        bgView.addSubview(thirdLabel)
        
        constrain(thirdLabel) {thirdLabel in
            thirdLabel.top == thirdLabel.superview!.top + 215 * kIphoneSizeScale - offSet
            thirdLabel.centerX == thirdLabel.superview!.centerX
        }
    }
    
    func setInfos(first : String?, second : String?, third : String?){
        firstLabel.text = first
        secondLabel.text = second
        thirdLabel.text = third
    }
    
    func brandBackgroundImage(urlStr : String?){
        bgView.sd_setImageWithURLStr(urlStr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
