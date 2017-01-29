//
//  LocationAlertView.swift
//  DejaFashion
//
//  Created by jiao qing on 23/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class LocationAlertView: FullCoverAlertView {
    weak var btnTarget : AnyObject?
    var noThanksSelector : Selector?
    var settingSelector : Selector?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.frame = CGRectMake(frame.size.width / 2 - 286 / 2, 161, 286, 243)
    }
    
    override func buildContentView(){
        let topImage = UIImageView()
        topImage.image = UIImage(named: "LocationRed")
        topImage.frame = CGRectMake(contentView.frame.size.width / 2 - 110, 18, 220, 75)
        contentView.addSubview(topImage)
        
        let label = UILabel()
        label.withText(DJStringUtil.localize("Please turn on Location Services in your device settings to find shops nearby.", comment:""))
        label.numberOfLines = 0
        label.withTextColor(UIColor.defaultBlack()).withFontHeletica(15)
        contentView.addSubview(label)
        constrain(label, topImage) { label, topImage in
            label.left == label.superview!.left + 33
            label.right == label.superview!.right - 28
            label.top == topImage.bottom + 18
        }
        
        let noBtn = getOneBtn(DJStringUtil.localize("No Thanks", comment:""))
        contentView.addSubview(noBtn)
        noBtn.addTarget(self, action: #selector(noThanksBtnDidTapped), forControlEvents: .TouchUpInside)
        constrain(noBtn, label) { noBtn, label in
            noBtn.left == noBtn.superview!.left + 28
            noBtn.top == label.bottom + 25
        }
        
        let settingBtn = getOneBtn(DJStringUtil.localize("Go To Setting", comment:""))
        contentView.addSubview(settingBtn)
        settingBtn.addTarget(self, action: #selector(settingBtnDidTapped), forControlEvents: .TouchUpInside)
        constrain(noBtn, settingBtn) { noBtn, settingBtn in
            settingBtn.right == settingBtn.superview!.right - 28
            settingBtn.top == noBtn.top
        }
    }

    func setTargetSelector(target : AnyObject, noThanksSel : Selector, settingSel : Selector){
        btnTarget = target
        noThanksSelector = noThanksSel
        settingSelector = settingSel
    }
    
    func noThanksBtnDidTapped(){
        removeFromSuperview()
        if btnTarget != nil && noThanksSelector != nil{
            if btnTarget!.respondsToSelector(noThanksSelector!){
                btnTarget!.performSelector(noThanksSelector!)
            }
        }
    }
    
    func settingBtnDidTapped(){
        removeFromSuperview()
        if btnTarget != nil && settingSelector != nil{
            if btnTarget!.respondsToSelector(settingSelector!){
                btnTarget!.performSelector(settingSelector!)
            }
        }
    }
    
    func getOneBtn(title : String) -> UIButton{
        let btn = DJButton()
        btn.setWhiteTitle()
        btn.withTitle(title).withFontHeleticaMedium(14)
        
        NSLayoutConstraint(item: btn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 35).active = true
        NSLayoutConstraint(item: btn, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 112).active = true
        return btn
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
