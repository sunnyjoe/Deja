//
//  FittingRoomCollectionCell.swift
//  DejaFashion
//
//  Created by jiao qing on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit


class FittingRoomTableCell: UITableViewCell {
    let imageV = UIImageView()
    private let lineView = UIView()
    private let tick = UIImageView()
    
    let lockerV = UIView()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.whiteColor()
        
        imageV.clipsToBounds = true
        self.addSubview(imageV)
        
        tick.image = UIImage(named: "SelectorBlackIcon")
        self.addSubview(tick)
        
        lineView.backgroundColor = UIColor(fromHexString: "cecece")
        self.addSubview(lineView)
        
        let lokerIV = UIImageView()
        lokerIV.image = UIImage(named: "LockerIcon")
        lockerV.addSubview(lokerIV)
        lockerV.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.3)
        lokerIV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: lokerIV, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: lokerIV.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: lokerIV, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: lokerIV.superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: lokerIV, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 19).active = true
        NSLayoutConstraint(item: lokerIV, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
            attribute: .NotAnAttribute,  multiplier: 1,  constant: 16).active = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageV.frame = self.bounds
        tick.frame = CGRectMake(self.bounds.size.width - 23, 5, 18, 18)
        lineView.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)
        lockerV.frame = self.bounds
    }
    
    func showSelectedIcon(show : Bool){
        tick.hidden = !show
    }
    
    func showLocker(show : Bool){
        if show{
            self.addSubview(lockerV)
        }else{
            lockerV.removeFromSuperview()
        }
    }
    
    func setImageUrl(imageUrl : String?, colorValue : String?){
        if imageUrl == nil {
            return
        }
        
        if colorValue == nil {
            let color = UIColor(fromHexString: colorValue)
            let image =  UIImage(color: color)
            self.imageV.image = image
            self.imageV.contentMode = UIViewContentMode.ScaleToFill
        }else
        {
            self.imageV.image = UIImage(named: "LoadingLogo")
            self.imageV.contentMode = UIViewContentMode.Center
        }
        
        weak var weakSelf = self
        imageV.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: imageUrl! + "/\(ImageQuality.LOW).jpg")!), placeholderImage: nil,
            success: {(request : NSURLRequest?, response : NSHTTPURLResponse?, image : UIImage)  -> Void in
                if request == nil && response == nil {
                    weakSelf?.imageV.alpha = 1
                    weakSelf?.imageV.contentMode = UIViewContentMode.ScaleAspectFit
                    weakSelf?.imageV.image = image
                }else{
                    weakSelf?.imageV.contentMode = UIViewContentMode.ScaleAspectFit
                    weakSelf?.imageV.image = image
                    weakSelf?.imageV.alpha = 1
                }
            }, failure: nil
        )
    }
    
    func setImageViewImage(image :UIImage){
        imageV.image = image
    }
}

class FittingRoomClothTableCell: FittingRoomTableCell {
    private let label = UILabel()
    var product : Clothes?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.blackColor()
        label.withText("Recommend").withFontHeletica(8)
        self.addSubview(label)
        
        
        if debugMode{
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FittingRoomClothTableCell.imageViewDidLongPressed))
            imageV.addGestureRecognizer(longPressRecognizer)
            imageV.userInteractionEnabled = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageV.frame = CGRectMake(15, 10, self.frame.size.width - 30, self.frame.size.height - 20)
        label.frame = CGRectMake(0, self.frame.size.height - 12, 50, 12)
    }
    
    func imageViewDidLongPressed(){
        let alertView = DJAlertView(title: "Cloth Id", message: product?.uniqueID, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    
    func showRecommandLabel(show : Bool){
        label.hidden = !show
    }
}

class FittingRoomFaceTableCell: FittingRoomTableCell {
    private var scaleSize = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if scaleSize {
            imageV.frame = CGRectMake(self.frame.size.width / 2 - 65 / 2, self.frame.size.height / 2 - 65 / 2, 65, 65)
        }else{
            imageV.frame = self.bounds
        }
    }
    
    func smallerImageView(){
        scaleSize = true
    }
    
    func normalImageView(){
        scaleSize = false
    }
    
}
