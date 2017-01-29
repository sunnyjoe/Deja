//
//  MissionCreatedViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 5/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

class MissionCreatedViewController : DJBasicViewController {
    
    var desc : String = DJStringUtil.localize("Please help me to make an outfit.", comment:"")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let icon = UIImageView(image: UIImage(named: "MissionCreatedIcon"))
        let label = UILabel().withFontHeleticaMedium(16).withTextColor(DJCommonStyle.BackgroundColor).textCentered()
        label.text = DJStringUtil.localize("Task Published!", comment: "")
        let descLabel = UILabel().withFontHeletica(14).withTextColor(UIColor.gray81Color())
        descLabel.text = DJStringUtil.localize("Share the style task on other platforms to get more ideas!", comment: "")
        descLabel.numberOfLines = 0
        
        let shareButton = DJButton().whiteTitleBlackStyle()
        shareButton.setTitle("Share", forState: .Normal)
        
        shareButton.addTarget(self, action: #selector(MissionCreatedViewController.share), forControlEvents: .TouchUpInside)
        
        view.addSubviews(icon, label, descLabel, shareButton)
        
        constrain(icon, label, descLabel, shareButton) { (icon, label, descLabel, shareButton) in
            icon.top == icon.superview!.top + 50
            icon.width == 100
            icon.height == 100
            icon.centerX == icon.superview!.centerX
            
            label.top == icon.bottom + 25
            label.centerX == label.superview!.centerX
            
            descLabel.top == label.bottom + 50
            descLabel.left == descLabel.superview!.left + 30
            descLabel.right == descLabel.superview!.right - 30
            
            shareButton.top == descLabel.bottom + 25
            shareButton.left == descLabel.left
            shareButton.right == descLabel.right
            shareButton.height == 36

        }
        
        setCloseLeftBarItem()
    }
    
    func share() {
        let text = desc + ConfigDataContainer.sharedInstance.getSharedMissionUrl(AccountDataContainer.sharedInstance.userID!)
        let v = UIActivityViewController(activityItems: ["Deja",text], applicationActivities: nil)
        presentViewController(v, animated: true, completion: nil)
    }
    
    override func cancelBtnDidTap() {
        super.goBack()
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            appDelegate.registerForAPN(DJStringUtil.localize("Task was posted!", comment: ""),withDesc:DJStringUtil.localize("Would you like to be alerted when you get outfits?", comment: ""))
        }
    }
}
