
//
//  ClothNotFindView.swift
//  DejaFashion
//
//  Created by jiao qing on 17/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

class ClothNotFindView: UIView {
    var reportTarget : AnyObject?
    var reportSelector : Selector?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    init(frame: CGRect, text : String = "Sorry, no match available.", showNotFoundButton : Bool = true){
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        let imageView = UIImageView(frame: CGRectMake(frame.size.width / 2 - 50, 118, 100, 100))
        imageView.image = UIImage(named: "NotFindImage")
        self.addSubview(imageView)
        
        let infoLabel = UILabel(frame: CGRectMake(0, CGRectGetMaxY(imageView.frame) + 33, frame.size.width, 20))
        infoLabel.numberOfLines = 0
        infoLabel.withText(text).withFontHeleticaMedium(17)
        infoLabel.textAlignment = .Center
        self.addSubview(infoLabel)
        
        let notfindBtn = DJButton(frame: CGRectMake(frame.size.width / 2 - 71.5, CGRectGetMaxY(infoLabel.frame) + 20, 143, 35))
        notfindBtn.backgroundColor = UIColor.defaultBlack()
        notfindBtn.setWhiteTitle()
        notfindBtn.addTarget(self, action: #selector(notFindBtnDidTapped), forControlEvents: .TouchUpInside)
        notfindBtn.withTitle(DJStringUtil.localize("REPORT", comment:"")).withFontHeleticaMedium(14)
        self.addSubview(notfindBtn)
        
        if !showNotFoundButton {
            notfindBtn.hidden = true
        }
    }
    
    func setReportSelector(target : AnyObject, sel : Selector){
        reportTarget = target
        reportSelector = sel
    }
    
    func notFindBtnDidTapped(){
        if reportTarget != nil && reportSelector != nil{
            if reportTarget!.respondsToSelector(reportSelector!){
                reportTarget!.performSelector(reportSelector!)
            }
        }
    }

}


