//
//  MissionInfoView.swift
//  DejaFashion
//
//  Created by DanyChen on 27/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class MissionInfoView: UIView {
    
    let helpButton = DJButton().whiteTitleTransparentStyle()

    init(frame: CGRect, user: DejaFriend, missionInfo: StylingMission) {
        super.init(frame: frame)
        withBackgroundColor(UIColor(fromHexString: "262729", alpha: 0.95))
        let avatarImageView = UIImageView()
        avatarImageView.backgroundColor = UIColor.whiteColor()
        if let image = user.avatar {
            if let url = NSURL(string: image) {
                avatarImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "MeDefaultAvatar"))
            }else {
                avatarImageView.image = UIImage(named: "MeDefaultAvatar")
            }
        }else {
            avatarImageView.image = UIImage(named: "MeDefaultAvatar")
        }
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        
        let nameLabel = UILabel().withTextColor(DJCommonStyle.ColorEA).withFontHeleticaMedium(14).textCentered()
        nameLabel.text = user.name
        
        let occasionLabel = UILabel().withTextColor(DJCommonStyle.ColorEA).withFontHeleticaMedium(14).textCentered()
        if let occasionName = missionInfo.occasion?.name {
            occasionLabel.text = DJStringUtil.localize("Occasion: ", comment: "") + occasionName
        }else {
            occasionLabel.text = DJStringUtil.localize("Occasion: Any", comment: "")
        }
        
        let descLabel = UILabel(frame: CGRectMake(0, 0, 199, 0)).withTextColor(UIColor.gray81Color()).withFontHeletica(14).textCentered()
        descLabel.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .Center
        let desc = missionInfo.desc == nil ? "" : missionInfo.desc!
        let attrString = NSMutableAttributedString(string: desc)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        descLabel.attributedText = attrString
        descLabel.sizeToFit()
        var height = descLabel.frame.height
        
        if height < 20 {
            height = 20
        }else {
            self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height - 20 + height)
        }
        
        if let desc = missionInfo.desc {
            user.missionDesc = desc
        }
        helpButton.withTitle(DJStringUtil.localize("Style for ", comment: "") + user.name)
        
        helpButton.layer.cornerRadius = 17.5
        helpButton.property = missionInfo.id
        helpButton.property = user
        
        addSubviews(avatarImageView, nameLabel, descLabel, occasionLabel, helpButton)
        
        constrain(avatarImageView, nameLabel, descLabel, occasionLabel, helpButton) { (avatarImageView, nameLabel, descLabel, occasionLabel, helpButton) in
            avatarImageView.top == avatarImageView.superview!.top + 25
            avatarImageView.centerX == avatarImageView.superview!.centerX
            avatarImageView.width == 40
            avatarImageView.height == 40
            
            nameLabel.top == avatarImageView.bottom + 10
            nameLabel.centerX == nameLabel.superview!.centerX
            
            descLabel.top == nameLabel.bottom + 15
            descLabel.width == 199
            descLabel.height == height
            descLabel.centerX == descLabel.superview!.centerX
            
            occasionLabel.top == descLabel.bottom + 20
            occasionLabel.centerX == occasionLabel.superview!.centerX

            helpButton.top == occasionLabel.bottom + 20
            helpButton.width == 199
            helpButton.height == 35
            helpButton.centerX == helpButton.superview!.centerX
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
