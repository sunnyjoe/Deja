//
//  Dialog.swift
//  DejaFashion
//
//  Created by Sun lin on 7/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation
import KLCPopup

class Dialog: KLCPopup
{
    var parentVC : UIViewController?
    var icon : UIImage?
    var text : String?
    var cancelBtnText : String?
    var okBtnText : String?
//    var popup :KLCPopup?
    
    var cancelBtn = UIButton()
    var blk1 : (() -> Void)?
    var blk2 : (() -> Void)?
    var blkDismiss : (() -> Void)?
    
    func withParentViewController(vc : UIViewController) -> Dialog
    {
        parentVC = vc
        return self
    }
    
    func withIcon(img : UIImage?) -> Dialog
    {
        icon = img
        return self
    }
    
    
    func withText(txt : String) -> Dialog
    {
        text = txt
        return self
    }
    
    
    func withCancelBtnText(txt : String?) -> Dialog
    {
        cancelBtnText = txt
        return self
    }
    
    
    func withOkBtnText(txt : String) -> Dialog
    {
        okBtnText = txt
        return self
    }
    
//  func fetchClothResource(products : [Clothes], fullBodyShape : String, success : (() -> Void)?, failed : (() -> Void)?){
    
    
    func show(didClickOK : (() -> Void)?, didClickCancel : (() -> Void)?)
    {
        self.show(didClickOK, didClickCancel: didClickCancel, didDismiss: nil)
    }
    
    func show(didClickOK : (() -> Void)?, didClickCancel : (() -> Void)?, didDismiss : (() -> Void)?)
    {
        blk1 = didClickOK
        blk2 = didClickCancel
        blkDismiss = didDismiss
 
        let contentView = UIView().withBackgroundColor(UIColor(fromHexString: "262729", alpha: 0.95))
        contentView.frame = CGRectMake(0.0, 0.0, 256.0, 249.0);
        
        let iconImgView = UIImageView()
        iconImgView.contentMode = UIViewContentMode.Center
        iconImgView.image = icon
        
        let textLabel = UILabel().withTextColor(UIColor.whiteColor()).withFontHeletica(14).withText(text!)
        textLabel.sizeToFit()
        textLabel.numberOfLines = 0
        
        cancelBtn = DJButton().whiteTitleTransparentStyle()
        if let value = cancelBtnText
        {
            cancelBtn.withTitle(value)
        }
        cancelBtn.layer.cornerRadius = 17.5
        cancelBtn.addTarget(self, action: #selector(Dialog.didClickCancel), forControlEvents: .TouchUpInside)
        
        let okBtn = DJButton().whiteTitleTransparentStyle()
        
        if let value = okBtnText
        {
            okBtn.withTitle(value)
        }
        okBtn.layer.cornerRadius = 17.5
        okBtn.addTarget(self, action:  #selector(Dialog.didClickOK), forControlEvents: .TouchUpInside)
        
        contentView.addSubviews(iconImgView, textLabel, cancelBtn, okBtn)
        
        self.contentView = contentView
        parentVC?.view.addSubview(self)
        self.shouldDismissOnBackgroundTouch = true
        self.maskType = .Clear
        
        constrain(contentView, iconImgView, textLabel, cancelBtn, okBtn) { (contentView, iconImgView, textLabel, cancelBtn, okBtn) in
            
            
            iconImgView.top == iconImgView.superview!.top + 25
            iconImgView.centerX == iconImgView.superview!.centerX
            iconImgView.width == iconImgView.superview!.width
            iconImgView.height == 58
            
            textLabel.top == iconImgView.bottom + 10
            textLabel.width == 199
            textLabel.centerX == textLabel.superview!.centerX
            
            okBtn.bottom == okBtn.superview!.bottom - 37
            okBtn.height == 35
            okBtn.top == textLabel.bottom + 21
            okBtn.right == textLabel.right
            
            if cancelBtnText != nil
            {
                cancelBtn.bottom == cancelBtn.superview!.bottom - 37
                cancelBtn.width == 86
                cancelBtn.height == 35
                cancelBtn.top == textLabel.bottom + 21
                cancelBtn.left == textLabel.left
                
                
                okBtn.width == 100
            }
            else
            {
                
                okBtn.left == textLabel.left
            }
        }
        self.show()
        
    }
    
    override func didFinishDismissing()
    {
        if let blk = blkDismiss
        {
            blk()
        }
    }
    
    func didClickCancel()
    {
        dismiss(true)
        if let blk = blk2
        {
            blk()
        }
    }
    
    func didClickOK()
    {
        dismiss(true)
        
        if let blk = blk1
        {
            blk()
        }

    }
}