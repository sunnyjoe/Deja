//
//  PullUpHideShowBasicView.swift
//  DejaFashion
//
//  Created by jiao qing on 16/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


class PullUpHideShowBasicView: UIView {
    let contentView = UIView()
    weak var closeTarget : AnyObject?
    var closeSelector : Selector?
    let closeBtn = UIButton(frame: CGRectMake(23, 23, 30, 30))
    
    override init(frame: CGRect){
        super.init(frame : frame)
  
        backgroundColor = UIColor(fromHexString: "262729", alpha: 0.5)
        clipsToBounds = true
        
        let bgView = UIView(frame: bounds)
        self.addSubview(bgView)
        bgView.addTapGestureTarget(self, action: #selector(closeViewAction))
        
        contentView.userInteractionEnabled = true
        contentView.backgroundColor = UIColor.whiteColor()
        addSubview(contentView)
        contentView.frame = CGRectMake(0, frame.size.height * 0.44, frame.size.width, frame.size.height * 0.56)
        
        buildContentView()
        
        let imageV = UIImageView(frame: CGRectMake(0 , 0, 23, 19))
        imageV.image = UIImage(named: "CloseIcon")
        closeBtn.addSubview(imageV)
        contentView.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(closeViewAction), forControlEvents: .TouchUpInside)
    }
    
    func buildContentView(){
        
    }
    
    func setCloseSelector(target : AnyObject, sel : Selector){
        closeTarget = target
        closeSelector = sel
    }
    
    func showAnimation() {
        layer.removeAllAnimations()
        
        self.alpha = 0
        let tmpSize = contentView.frame.size
        contentView.frame = CGRectMake(0, frame.size.height, tmpSize.width, tmpSize.height)
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 1
            self.contentView.frame = CGRectMake(0, self.frame.size.height - tmpSize.height, tmpSize.width, tmpSize.height)
        })
    }
    
    func hideAnimation() {
        layer.removeAllAnimations()
        
        self.alpha = 1
        let tmpSize = contentView.frame.size
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 0
            self.contentView.frame = CGRectMake(0, self.frame.size.height, tmpSize.width, tmpSize.height)
            },completion: {(Bool) -> Void in
                self.removeFromSuperview()
        })
    }
    
    func closeViewAction(){
        if closeTarget != nil && closeSelector != nil{
            if closeTarget!.respondsToSelector(closeSelector!){
                closeTarget!.performSelector(closeSelector!)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
