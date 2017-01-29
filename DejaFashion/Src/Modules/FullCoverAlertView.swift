//
//  FullCoverAlertView.swift
//  DejaFashion
//
//  Created by jiao qing on 23/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class FullCoverAlertView: UIView {
    let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(fromHexString: "262729", alpha: 0.7)
        
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.frame = CGRectMake(frame.size.width / 2 - 286 / 2, 161, 286, 243)
        addSubview(contentView)
        
        buildContentView()
    }
    
    func buildContentView(){
        
    }
    
    func showAnimation(){
        contentView.transform = CGAffineTransformMakeScale(0.2, 0.2)
        backgroundColor = UIColor(fromHexString: "262729", alpha: 0.1)
        UIView.animateWithDuration(0.3, animations: {
            self.contentView.transform = CGAffineTransformIdentity
            self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.7)
        })
    }
    
    func hideAnimation(){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
