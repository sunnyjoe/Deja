//
//  ScanTagNotClearView.swift
//  DejaFashion
//
//  Created by jiao qing on 3/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ScanTagNotClearView: ScanTagNoResultView {
    
    override func buildContentView(){
        contentView.frame = CGRectMake(0, frame.size.height * 22, frame.size.width, 498)
        buildTopView()
        
        imageV.image = UIImage(named: "ScanNotClear")
        constrain(imageV) { imageV in
            imageV.top == imageV.superview!.top + 25
            imageV.centerX == imageV.superview!.centerX
        }
        NSLayoutConstraint(item: imageV, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 115).active = true
        NSLayoutConstraint(item: imageV, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
            attribute: .NotAnAttribute,  multiplier: 1,  constant: 155).active = true
        
        
        label.withText(DJStringUtil.localize("The price tag that you scanned is not clear enough, please try again.", comment:""))
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
        sepLabel.withTextColor(DJCommonStyle.Color81).withFontHeletica(14).withText(DJStringUtil.localize("Place the complete and clear price tag in the scan area.", comment:""))
        sep.addSubview(sepLabel)
        
        
        let image1Width : CGFloat = (150 - 5) * 185 / (135 + 185)
        let imageHeight : CGFloat = image1Width * 335 / 185
        let imageV1 = UIImageView(frame: CGRectMake(contentView.frame.size.width / 2 - 75, CGRectGetMaxY(sep.frame) + 20, image1Width, imageHeight))
        contentView.addSubview(imageV1)
        imageV1.image = UIImage(named: "CorrectTag")
        
        let image2Width : CGFloat = 150 - 5 - image1Width
        let imageV2 = UIImageView(frame: CGRectMake(CGRectGetMaxX(imageV1.frame) + 5, imageV1.frame.origin.y, image2Width, imageHeight))
        contentView.addSubview(imageV2)
        imageV2.image = UIImage(named: "WrongTag")
      
        imageV1.contentMode = .ScaleAspectFill
        imageV2.contentMode = .ScaleAspectFill
    }


}
