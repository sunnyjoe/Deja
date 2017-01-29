//
//  BrandListWindow.swift
//  DejaFashion
//
//  Created by jiao qing on 23/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class SlideWindow: UIWindow {
    var contentView = UIView()
    var backView = UIView()
    
    var contentHiddenFrame = CGRectZero
    var contentNormalFrame = CGRectZero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        windowLevel = UIWindowLevelAlert
        
        backView.frame = bounds
        addSubview(backView)
        backView.backgroundColor = UIColor(fromHexString: "272629", alpha: 0.8)
        backView.addTapGestureTarget(self, action: #selector(hideAnimation))
        backView.userInteractionEnabled = true
        
        contentView.backgroundColor = UIColor.defaultBlack()
        addSubview(contentView)
    }
    
    func showAnimation(){
        self.makeKeyAndVisible()
        
        contentView.frame = contentHiddenFrame
        backView.alpha = 0
        
        UIView.animateWithDuration(0.3, animations: {
            self.backView.alpha = 1
            self.contentView.frame = self.contentNormalFrame
        })
    }
    
    func hideAnimation(){
        backView.alpha = 1
        
        UIView.animateWithDuration(0.3, animations: {
            self.backView.alpha = 0
            self.contentView.frame = self.contentHiddenFrame
            }, completion: {(Bool) -> Void in
                self.hidden = true
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
