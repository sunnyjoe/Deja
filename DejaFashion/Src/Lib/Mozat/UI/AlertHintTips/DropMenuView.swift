//
//  DropMenuView.swift
//  UITools
//
//  Created by jiao qing on 1/8/16.
//  Copyright © 2016 jiao qing. All rights reserved.
//

import UIKit

@objc protocol DropMenuViewDelegate : NSObjectProtocol{
    func dropMenuViewDidClickIndex(dropMenuView: DropMenuView, index : Int)
}

class DropMenuView : UIView {
    weak var delegate : DropMenuViewDelegate?
    
    var viewHeight : CGFloat = 41
    var containerView = UIView()
    
    var containerViewFrame = CGRectZero
    var containerHideFrame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 35, 34, 22, 22)
    
    
    init(menus:[String]) {
        super.init(frame: UIScreen.mainScreen().bounds)
        
        self.userInteractionEnabled = true
        self.addTapGestureTarget(self, action: #selector(didTapContainerView))
        
        containerViewFrame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 100, 74, 90, CGFloat(menus.count) * viewHeight)
        containerView.clipsToBounds = true
        containerView.frame = containerViewFrame
        addSubview(containerView)
        
        var index = 0
        for oneMenu in menus {
            buildFunctionView(oneMenu, action: #selector(gotoMenu), index : index)
            index += 1
        }
    }
    
    func buildFunctionView(name : String, action : Selector, index : Int){
        let conView = UIView(frame: CGRectMake(0, CGFloat(index) * viewHeight, containerView.frame.size.width, viewHeight))
        conView.backgroundColor = UIColor.blackColor()
        containerView.addSubview(conView)
        conView.addTapGestureTarget(self, action: action)
        conView.tag = index
        
        let label = UILabel(frame: CGRectMake(10, 0, conView.frame.size.width - 10, conView.frame.size.height))
        conView.addSubview(label)
        
        label.text = name
        label.textColor = UIColor(fromHexString: "f1f1f1")
        label.font = DJFont.fontOfSize(15)
    }
    
    func didTapContainerView(){
        hideAnimation()
    }
    
    func gotoMenu(tap : UIGestureRecognizer){
        if let theView = tap.view {
            removeFromSuperview()
            delegate?.dropMenuViewDidClickIndex(self, index: theView.tag)
        }
    }
    
    func showAnimation(){
        self.alpha = 0
        containerView.frame = containerHideFrame
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 1
            self.containerView.frame = self.containerViewFrame
        })
    }
    
    func hideAnimation(){
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 0
            self.containerView.frame = self.containerHideFrame
            }, completion: { (Bool) -> Void in
                self.removeFromSuperview()
                self.alpha = 1
                self.containerView.frame = self.containerViewFrame
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

