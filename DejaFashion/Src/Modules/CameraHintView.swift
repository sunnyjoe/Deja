//
//  CameraHintView.swift
//  DejaFashion
//
//  Created by jiao qing on 16/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class CameraHintView: UIView {
    private let label = UILabel()
    private let imageView = UIImageView()
    private let doneBtn = DJButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.defaultBlack()
        
        addSubview(label)
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.withFontHeleticaMedium(17).withTextColor(UIColor.gray81Color()).withText("Place your object in the template")
        
        imageView.image = UIImage(named: "CameraHint")
        imageView.contentMode = .ScaleAspectFit
        addSubview(imageView)
        
        doneBtn.setWhiteTitle().withTitle(DJStringUtil.localize("Got it!", comment:"")).withFontHeleticaBold(14).withTitleColor(UIColor(fromHexString: "f1f1f1"))
        doneBtn.setBackgroundColor(UIColor(fromHexString: "414141"), forState: .Normal)
        doneBtn.layer.borderWidth = 0
        doneBtn.addTarget(self, action: #selector(CameraHintView.doneBtnDidClick), forControlEvents: .TouchUpInside)
        addSubview(doneBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let scale = frame.size.width / 375
        label.frame = CGRectMake(23, 90 * scale, frame.size.width - 46, 44)
        
        imageView.frame = CGRectMake(31 * scale, 150 * scale, 313 * scale, 336 * scale)
        doneBtn.frame = CGRectMake(31, CGRectGetMaxY(imageView.frame) + 15, self.frame.size.width - 31 * 2, 35)
    }
    
    func setTitle(text : String){
        label.withText(text)
    }
    
    func setDisplayImage(theImage : UIImage){
        imageView.image = theImage
    }
    
    func doneBtnDidClick(){
        removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

