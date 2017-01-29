//
//  TutorialWindow.swift
//  DejaFashion
//
//  Created by DanyChen on 23/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

protocol TutorialWindowDelegate : class{
    func tutorialWindowContentDidTapped(point : CGPoint)
}

class TutorialWindow: UIWindow {
    let contentView = UIView()
    
    weak var delegate : TutorialWindowDelegate?

    init() {
        super.init(frame: UIScreen.mainScreen().bounds)
        windowLevel = UIWindowLevelStatusBar + 1
        contentView.frame = bounds
        addSubview(contentView)
        contentView.addTapGestureTarget(self, action: #selector(TutorialWindow.hideTutorial(_:)))
    }
    
    func dim() {
        contentView.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.85)
    }
    
    func hollowArea(area : CGRect) {
        if frame.width == 0 || frame.height == 0 {
            dim()
            return
        }
 
        let x = area.origin.x
        let y = area.origin.y
        let width = area.width
        let height = area.height
        
        removeAllSubViews()
        contentView.removeAllSubViews()
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: y))
        let leftView = UIView(frame: CGRect(x: 0, y: y, width: x, height: height))
        let rightView = UIView(frame: CGRect(x: x + width, y: y, width: frame.width - x - width, height: height))
        let bottomView = UIView(frame: CGRect(x: 0, y: y + height, width: frame.width, height: frame.height - y - height))
        
        [topView,leftView,rightView,bottomView].forEach { (view) -> () in
            view.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.85)
            addSubview(view)
        }
        addSubview(contentView)
    }
    
    func hideTutorial(rec: UITapGestureRecognizer) {
        hidden = true
    
        let point = rec.locationInView(contentView)
        
        if self.delegate != nil {
            self.delegate!.tutorialWindowContentDidTapped(point)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
