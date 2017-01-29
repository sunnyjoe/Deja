//
//  ScanTagNoBrandView.swift
//  DejaFashion
//
//  Created by jiao qing on 3/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ScanTagNoBrandView: ScanTagNoResultView {

    override func buildContentView(){
        contentView.frame = CGRectMake(0, frame.size.height * 22, frame.size.width, 498)
        buildTopView()
        
        imageV.image = UIImage(named: "RocketFly")
        constrain(imageV) { imageV in
            imageV.top == imageV.superview!.top + 25
            imageV.centerX == imageV.superview!.centerX
        }
        NSLayoutConstraint(item: imageV, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 115).active = true
        NSLayoutConstraint(item: imageV, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
            attribute: .NotAnAttribute,  multiplier: 1,  constant: 155).active = true
        
        label.withText(DJStringUtil.localize("The brand that you scanned is on the way~", comment:""))
        constrain(reportedLabel, reprotLabel, reportBtn, label) { reportedLabel, reprotLabel, reportBtn, label in
            label.top == label.superview!.top + 160
            label.centerX == label.superview!.centerX
            
            reportBtn.top == label.bottom + 15
            reportBtn.centerX == reportBtn.superview!.centerX
            
            reprotLabel.top == label.top
            reprotLabel.centerX == reprotLabel.superview!.centerX
            
            reportedLabel.bottom == label.bottom + 35
            reportedLabel.centerX == reportedLabel.superview!.centerX
        }
        
        let sep = UIView(frame: CGRectMake(0, 275, frame.size.width, 26))
        sep.backgroundColor = DJCommonStyle.ColorEA
        contentView.addSubview(sep)
        let sepLabel = UILabel(frame: CGRectMake(20, 0, sep.frame.size.width - 20 * 2, 26))
        sepLabel.withTextColor(DJCommonStyle.Color81).withFontHeletica(14).withText(DJStringUtil.localize("Try following brands:", comment:""))
        sep.addSubview(sepLabel)
        
        let bOY = CGRectGetMaxY(sep.frame) + 10
        let brandView = UIScrollView(frame: CGRectMake(23, bOY, contentView.frame.size.width - 23 * 2, contentView.frame.size.height - 10 - bOY))
        contentView.addSubview(brandView)
        brandView.showsVerticalScrollIndicator = false
     
        let recBrandView = BrandImagesView(frame: CGRectMake(0, 0, brandView.frame.size.width, 10))
        var brandList = [BrandInfo]()
        if let tmp = ConfigDataContainer.sharedInstance.getAllBrandList(){
            brandList.appendContentsOf(tmp)
        }
        recBrandView.setBrandList(brandList, fullWidth: brandView.frame.size.width)
        recBrandView.frameToFit()
        brandView.contentSize = recBrandView.frame.size
        brandView.addSubview(recBrandView)
    }


}
