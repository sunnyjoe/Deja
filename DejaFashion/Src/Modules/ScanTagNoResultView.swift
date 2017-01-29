//
//  ScanTagNoResultView.swift
//  DejaFashion
//
//  Created by jiao qing on 16/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


class ScanTagNoResultView: PullUpHideShowBasicView {
    let imageV = UIImageView()
    let label = UILabel()
    let reprotLabel = UILabel()
    let reportBtn = DJButton()
    let reportedLabel = UILabel()
    
    func buildTopView(){
        contentView.addSubview(imageV)
        label.numberOfLines = 0
        imageV.contentMode = .ScaleAspectFit
        label.withTextColor(UIColor.defaultBlack()).withFontHeleticaMedium(16).textCentered()
        contentView.addSubview(label)
        
        reprotLabel.hidden = true
        reprotLabel.numberOfLines = 0
        reprotLabel.withText(DJStringUtil.localize("We'll try our best to improve our database", comment:"")).withTextColor(UIColor.gray81Color()).withFontHeletica(14).textCentered()
        contentView.addSubview(reprotLabel)
        
        constrain(label, reprotLabel) { label, reprotLabel in
            label.left == label.superview!.left + 23
            label.right == label.superview!.right - 23
            
            reprotLabel.left == reprotLabel.superview!.left + 23
            reprotLabel.right == reprotLabel.superview!.right - 23
        }

        reportedLabel.hidden = true
        reportedLabel.withText(DJStringUtil.localize("Reported", comment:"")).withTextColor(UIColor.defaultBlack()).withFontHeletica(14)
        contentView.addSubview(reportedLabel)
        
        contentView.addSubview(reportBtn)
        reportBtn.withTitle(DJStringUtil.localize("Report", comment:""))
        reportBtn.setWhiteTitle()
        reportBtn.addTarget(self, action: #selector(ScanTagNoResultView.reportBtnDidClicked), forControlEvents: .TouchUpInside)
        
        NSLayoutConstraint(item: reportBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 35).active = true
        NSLayoutConstraint(item: reportBtn, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
            attribute: .NotAnAttribute,  multiplier: 1,  constant: 150).active = true
    }
    
    override func buildContentView(){
        contentView.frame = CGRectMake(0, frame.size.height * 22, frame.size.width, 377)
        buildTopView()
        
        imageV.image = UIImage(named: "ScanNotFind")
        constrain(imageV) { imageV in
            imageV.top == imageV.superview!.top + 50 * kIphoneSizeScale
            imageV.centerX == imageV.superview!.centerX
        }
        NSLayoutConstraint(item: imageV, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 145).active = true
        NSLayoutConstraint(item: imageV, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
            attribute: .NotAnAttribute,  multiplier: 1,  constant: 105).active = true
        
        
        label.withText(DJStringUtil.localize("Opps, Cannot find the item you scanned", comment:""))
        constrain(reportedLabel, reprotLabel, reportBtn, label) { reportedLabel, reprotLabel, reportBtn, label in
            label.top == label.superview!.top + 202 * kIphoneSizeScale
            label.centerX == label.superview!.centerX
            
            reportBtn.bottom == reportBtn.superview!.bottom - 88
            reportBtn.centerX == reportBtn.superview!.centerX
            
            reprotLabel.top == reprotLabel.superview!.top + 202 * kIphoneSizeScale
            reprotLabel.centerX == reprotLabel.superview!.centerX
            
            reportedLabel.bottom == reportedLabel.superview!.bottom - 88
            reportedLabel.centerX == reportedLabel.superview!.centerX
        }
    }
    
    func reportBtnDidClicked(){
//        DJStatisticsLogic.instance().addTraceLog(kStatisticsID_scan_result_click_report)
        imageV.image = UIImage(named: "BigCorrectWithCircle")
        reportBtn.hidden = true
        label.hidden = true
        reprotLabel.hidden = false
        reportedLabel.hidden = false
        label.withText(DJStringUtil.localize("Reported", comment:""))
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            self.closeViewAction()
        }
    }
}







