//
//  FindClothCollectionCell.swift
//  DejaFashion
//
//  Created by jiao qing on 16/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit
import AFNetworking

class FindClothCollectionCell: UICollectionViewCell {
    let imageView = UIImageView()
//    private let backFrame = UIView()
    // hide temporary
    let descIcon = UIImageView(image: nil)
    let brandLabel = UILabel()
    
    private let curPriceLabel = UILabel()
    private let uPriceLabel = UILabel()
    private let nameLabel = UILabel()
    let newAddedLabel = UILabel()
    
    weak var product : Clothes?
    
    var alwaysHideUsualPrice = true
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        backFrame.layer.borderColor = Colors.DividerColor.CGColor
        //        backFrame.layer.borderWidth = 0.5
        
        if debugMode{
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FindClothCollectionCell.imageViewDidLongPressed))
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(longPressRecognizer)
        }
//        self.contentView.layer.borderColor = UIColor.redColor().CGColor
//        self.contentView.layer.borderWidth = 0.5
//        
//        
//        self.layer.borderColor = UIColor.redColor().CGColor
//        self.layer.borderWidth = 0.5
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.clipsToBounds = true
//        imageView.layer.borderColor = UIColor.redColor().CGColor
        //        imageView.layer.borderWidth = 0.5
//        addSubviews(backFrame,imageView)
        addSubviews(imageView)
        
        addSubview(descIcon)
        addSubview(brandLabel)
        addSubview(curPriceLabel)
        addSubview(uPriceLabel)
        addSubview(nameLabel)
        addSubview(newAddedLabel)
        
        brandLabel.withFontHeletica(13).withTextColor(UIColor.defaultBlack())
        brandLabel.lineBreakMode = .ByTruncatingTail
        nameLabel.withFontHeletica(13).withTextColor(UIColor.defaultBlack())
        nameLabel.lineBreakMode = .ByTruncatingTail
        curPriceLabel.withFontHeletica(13).withTextColor(UIColor.defaultBlack())
        uPriceLabel.withFontHeletica(13).withTextColor(DJCommonStyle.ColorCE)
        
        newAddedLabel.textCentered().withTextColor(UIColor.whiteColor()).withText(DJStringUtil.localize("New", comment: ""))
        newAddedLabel.font = DJFont.condensedHelveticaFontOfSize(9)
        newAddedLabel.withBackgroundColor(UIColor(fromHexString: "9ccf99"))
        newAddedLabel.layer.cornerRadius = 13.5
        newAddedLabel.clipsToBounds = true
        newAddedLabel.hidden = true
        
//        constrain(backFrame) { backFrame in
//            backFrame.top == backFrame.superview!.top
//            backFrame.left == backFrame.superview!.left
//            backFrame.right == backFrame.superview!.right
//            backFrame.bottom == backFrame.superview!.bottom - 30
//        }
        
        constrain(nameLabel, imageView) { name, imageView in
            name.top == imageView.bottom + 7
            name.left == name.superview!.left
            name.right == name.superview!.right
        }
        
        constrain(nameLabel, brandLabel) { name, brand in
            brand.top == name.bottom + 3
            brand.left == brand.superview!.left
            brand.right == brand.superview!.right - brandLabelRightPadding()
        }
        
        constrain(brandLabel, curPriceLabel) { brandLabel, curPriceLabel in
            curPriceLabel.top == brandLabel.bottom + 3
            curPriceLabel.left == curPriceLabel.superview!.left
        }
        
        constrain(uPriceLabel, curPriceLabel) { uPriceLabel, curPriceLabel in
            uPriceLabel.top == curPriceLabel.top
            uPriceLabel.left == curPriceLabel.right + 5
        }
        
       imageViewLayout()
        
        constrain(descIcon) { (descIcon) in
            descIcon.left == descIcon.superview!.left
            descIcon.top == descIcon.superview!.top
        }
        
        constrain(newAddedLabel, block: { (label) in
            label.width == 27
            label.height == 27
            label.right == label.superview!.right - 12
            label.top == label.superview!.top + 12
        })
        
        if debugMode {
            imageView.addLongPressGestureTarget(self, action: #selector(FindClothCollectionCell.showPid))
        }
    }
    
    func imageViewLayout(){
        constrain(imageView, block: { (v) in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.top == v.superview!.top
            v.bottom == v.superview!.bottom - 60
        })
    }
    
    func showPid() {
        if let p = product {
            if let id = p.uniqueID {
                MBProgressHUD.showHUDAddedTo(self.viewController().view, text: id, animated: true)
            }
        }
    }
    
    func brandLabelRightPadding() -> CGFloat{
        return 0
    }

    func imageViewDidLongPressed(){
        let alertView = DJAlertView(title: "Cloth Id", message: product?.uniqueID, cancelButtonTitle: DJStringUtil.localize("OK", comment:""))
        alertView.show()
    }
    
    func setBrandName(brandName : String?){
        var value = brandName
        if value == nil{
            value = "N.A"
        }
        brandLabel.text = value!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func numberDigitals() -> Int {
        return 2
    }
    
    func setPriceInfo(curPrice : Int?, uprice : Int?, currency : String?){
        curPriceLabel.hidden = false
        uPriceLabel.hidden = false
        
        var price : String?
        var usualPrice : String?
        if currency != nil && curPrice != nil{
            let priceF : Float = Float(curPrice!) / 100
            let priceText = String(format: "%.\(numberDigitals())f", priceF)
            price = "\(currency!) \(priceText)"
            
            if uprice != nil && uprice! > curPrice!{
                let priceF : Float = Float(uprice!) / 100
                usualPrice = String(format: "%.\(numberDigitals())f", priceF)
            }
        }
        
        curPriceLabel.text = price
        uPriceLabel.text = usualPrice
        
        if alwaysHideUsualPrice {
            uPriceLabel.hidden = true
        }else {
            uPriceLabel.hidden = (usualPrice == nil)
        }
        if uPriceLabel.hidden == false{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: uPriceLabel.text!)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            uPriceLabel.attributedText = attributeString
        }
    }
    
    func setClothName(name : String?){
        nameLabel.hidden = false
        nameLabel.text = name?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func setImageUrl(imageUrl : String?, colorValue : String?){
        if imageUrl == nil {
            return
        }
        
//        backFrame.backgroundColor = UIColor.clearColor()
        self.imageView.image = nil
        //self.imageView.image = UIImage(named: "LoadingLogo")
        //self.imageView.contentMode = UIViewContentMode.Center
        
        weak var weakSelf = self
        imageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: imageUrl!)!), placeholderImage: nil,
            success: {(request : NSURLRequest?, response : NSHTTPURLResponse?, image : UIImage)  -> Void in
              //  weakSelf?.imageView.alpha = 0
             //   weakSelf?.backFrame.backgroundColor = UIColor.clearColor()
             //   UIView.animateWithDuration(0.7, animations: { () -> Void in
                    weakSelf?.imageView.image = image
             //       weakSelf?.imageView.alpha = 1
             //   })
            }, failure: nil
        )
    }
    
}

extension FindClothCollectionCell {
    class func calculateCellSize(clothSummary : Clothes) -> CGSize {
        let imageWidth = (UIScreen.mainScreen().bounds.width - 19 - 46) / 2
        var imageHeight : CGFloat = 0
        if clothSummary.thumbUrl == nil ||  clothSummary.thumbHeight == nil || clothSummary.thumbWidth == nil || clothSummary.thumbHeight == 0 {
            imageHeight = imageWidth
        }else{
            imageHeight = (imageWidth) * CGFloat(clothSummary.thumbHeight!) / CGFloat(clothSummary.thumbWidth!)
            // some old clothes
            if Int(clothSummary.uniqueID!) < 30000 {
                imageHeight = (imageWidth - 60) * CGFloat(clothSummary.thumbHeight!) / CGFloat(clothSummary.thumbWidth!) + 60
            }
            if imageHeight > imageWidth * 1.65 {
                imageHeight = imageWidth * 1.65
            }
        }
        
        return CGSizeMake(imageWidth, imageHeight + 60)
    }
}
