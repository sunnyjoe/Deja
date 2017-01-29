//
//  RefineButton.swift
//  DejaFashion
//
//  Created by DanyChen on 1/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class RefineButton: UIView {
    
    private let refineLabel = UILabel()
    private let refineIV = UIImageView()
    private var refineAnimated = false
    
    var selected : Bool = false {
        didSet {
            if selected {
                refineLabel.withTextColor(UIColor.defaultRed())
                refineIV.image = UIImage(named: "RefineRed")
            }else {
                refineLabel.withTextColor(UIColor.whiteColor())
                refineIV.image = UIImage(named: "RefineWhite")
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildRefineView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buildRefineView(){
        let rHeight : CGFloat = 35
        layer.cornerRadius = rHeight / 2
        backgroundColor = UIColor.defaultBlack()
        
        refineIV.image = UIImage(named: "RefineWhite")
        refineIV.contentMode = .ScaleAspectFit
        addSubview(refineIV)
        constrain(refineIV) { refineIV in
            refineIV.top == refineIV.superview!.top + (rHeight - 20) / 2
            refineIV.left == refineIV.superview!.left + 16
        }
        NSLayoutConstraint(item: refineIV, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: 20).active = true
        NSLayoutConstraint(item: refineIV, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: 20).active = true
        
        
        addSubview(refineLabel)
        constrain(refineLabel) { refineLabel in
            refineLabel.top == refineLabel.superview!.top + 12
            refineLabel.left == refineLabel.superview!.left + 43
            refineLabel.bottom == refineLabel.superview!.bottom - 12
        }
        refineLabel.withTextColor(UIColor.whiteColor())
        refineLabel.withText("Refine").withFontHeletica(14)
    }
}
