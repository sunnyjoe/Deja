//
//  ShopListTableViewCell.swift
//  DejaFashion
//
//  Created by jiao qing on 21/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ShopListTableViewCell: UITableViewCell {
    private let shopIV = UIImageView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let distanceLabel = DJLabel()
    private let mayLikeLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        mayLikeLabel.hidden = true
        
        shopIV.contentMode = .ScaleAspectFit
        NSLayoutConstraint(item: shopIV, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 55).active = true
        NSLayoutConstraint(item: shopIV, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 55).active = true
        
        NSLayoutConstraint(item: addressLabel, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: (frame.size.width - 115)).active = true
        
        titleLabel.withTextColor(UIColor.defaultBlack()).withFontHeleticaMedium(15)
        mayLikeLabel.withText("You may like").withFontHeletica(12).withTextColor(DJCommonStyle.Color81).backgroundColor = DJCommonStyle.ColorCE
        addressLabel.withTextColor(DJCommonStyle.Color81).withFontHeletica(13)
        distanceLabel.withFontHeletica(13).withTextColor(UIColor(fromHexString: "b5b7b6"))
        
        let underLine = UIView()
        underLine.backgroundColor = DJCommonStyle.ColorCE
        NSLayoutConstraint(item: underLine, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0.5).active = true
        
        addSubviews(shopIV, titleLabel, addressLabel, distanceLabel, mayLikeLabel, underLine)
        titleLabel.numberOfLines = 1
        addressLabel.numberOfLines = 2
        
        distanceLabel.textAlignment = .Right
        
        constrain(titleLabel, addressLabel, shopIV, mayLikeLabel) { titleLabel, addressLabel, shopIV, mayLikeLabel in
            shopIV.left == shopIV.superview!.left + 23
            shopIV.top == shopIV.superview!.top + 5
            
            titleLabel.right == titleLabel.superview!.right - 23
            titleLabel.top == titleLabel.superview!.top + 15
            titleLabel.left == shopIV.right + 10
            
            mayLikeLabel.top == titleLabel.top
            mayLikeLabel.right == mayLikeLabel.superview!.right - 23
            
            addressLabel.left == titleLabel.left
            addressLabel.top == titleLabel.bottom + 8.5
        }
        
        if DeviceType.IS_IPHONE_5 {
            constrain(addressLabel, distanceLabel) { addressLabel, distanceLabel in
                addressLabel.right == addressLabel.superview!.right - 23 - 60
                distanceLabel.left == distanceLabel.superview!.right - 23 - 60
                
                distanceLabel.bottom == distanceLabel.superview!.bottom - 12
                distanceLabel.right == distanceLabel.superview!.right - 23
            }
        }else{
            constrain(addressLabel, distanceLabel) { addressLabel, distanceLabel in
                distanceLabel.left == addressLabel.right + 3
                
                distanceLabel.bottom == distanceLabel.superview!.bottom - 12
                distanceLabel.right == distanceLabel.superview!.right - 23
            }
        }
        
        constrain(underLine) { underLine in
            underLine.left == underLine.superview!.left + 23
            underLine.right == underLine.superview!.right - 23
            underLine.bottom == underLine.superview!.bottom
        }
    }
    
    func shopName(name : String?, address : String?, distance : String?, showMayLike : Bool){
        titleLabel.text = name
        addressLabel.text = address
        distanceLabel.text = distance
        mayLikeLabel.hidden = !showMayLike
    }
    
    func setShopImageUrl(imageUrl : String?){
        self.shopIV.image = nil
        
        if imageUrl == nil {
            return
        }
        weak var weakSelf = self
        self.shopIV.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: imageUrl!)!), placeholderImage: nil, success: {(request : NSURLRequest?, response : NSHTTPURLResponse?, image : UIImage)  -> Void in
            weakSelf?.shopIV.image = image
            }, failure: nil
        )
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
