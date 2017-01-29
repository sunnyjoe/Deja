//
//  DJUserDescView.swift
//  DejaFashion
//
//  Created by DanyChen on 1/10/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

@objc protocol DJUserDescViewDelegate {
    func creditLabelDidClick()
    func followingLabelDidClick()
    func followerLabelDidClick()
}

class DJUserDescView: UIView {

    var styleCount = 0 {
        didSet {
            styleLabel.text = "\(styleCount)"
        }
    }
    var followingCount = 0 {
        didSet {
            followingLabel.text = "\(followingCount)"
        }
    }
    var followerCount = 0 {
        didSet {
            followerLabel.text = "\(followerCount)"
        }
    }
    
    private var styleLabel = UILabel()
    private var followingLabel = UILabel()
    private var followerLabel = UILabel()
    
    weak var delegate : DJUserDescViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let styleTitle = UILabel().withText("styles")
        let followingTitle = UILabel().withText("following")
        let followerTitle = UILabel().withText("followers")
        
        addSubviews(styleLabel, followingLabel, followerLabel, styleTitle, followingTitle, followerTitle)
        
        [styleLabel, followingLabel, followerLabel].forEach { (label) -> () in
            label.withText("0").withFontHeleticaMedium(17).withTextColor(UIColor.whiteColor()).textCentered()
        }
        
        [styleTitle, followingTitle, followerTitle].forEach { (label) -> () in
            label.withFontHeletica(15).withTextColor(DJCommonStyle.ColorCE).textCentered()
        }
        
        styleLabel.frame = CGRectMake(0, 0, 41, 17)
        styleTitle.frame = CGRectMake(0, 20, 41, 18)
        followerLabel.frame = CGRectMake(styleLabel.frame.width + 16, 0, 70, 17)
        followerTitle.frame = CGRectMake(styleLabel.frame.width + 16, 20, 70, 18)
        followingLabel.frame = CGRectMake(followerLabel.frame.width + 70, 0, 70, 17)
        followingTitle.frame = CGRectMake(followerLabel.frame.width + 70, 20, 70, 18)
        
        [followingLabel, followingTitle].forEach { (label) -> () in
            label.addTapGestureTarget(self, action: #selector(DJUserDescView.followingLabelDidClick(_:)))
        }
        [followerLabel , followerTitle].forEach { (label) -> () in
            label.addTapGestureTarget(self, action: #selector(DJUserDescView.followerLabelDidClick(_:)))
        }
    }
    
    func followingLabelDidClick(tap : UITapGestureRecognizer) {
        delegate?.followingLabelDidClick()
    }
    
    func followerLabelDidClick(tap : UITapGestureRecognizer) {
        delegate?.followerLabelDidClick()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
