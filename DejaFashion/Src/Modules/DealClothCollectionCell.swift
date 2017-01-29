//
//  DealClothCollectionCell.swift
//  DejaFashion
//
//  Created by DanyChen on 6/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class DealClothCollectionCell: FindClothCollectionCell {
    
    var discount = UILabel()
    var off = UILabel()
    var discountBg = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        alwaysHideUsualPrice = false
        discountBg.image = UIImage(named: "DiscountBg")
        discount = UILabel().withTextColor(UIColor.whiteColor()).withFontHeleticaBold(10).textCentered()
        off = UILabel().withTextColor(UIColor.whiteColor()).withFontHeleticaBold(10).withText("OFF").textCentered()
        
        addSubview(discountBg)
        addSubview(discount)
        addSubview(off)
        
        constrain(imageView, discountBg, discount, off, block: { (imageView, discountBg, discount, off) in
            discountBg.right == imageView.right - 3
            discountBg.top == imageView.top + 3
            discountBg.width == 30
            discountBg.height == 30
            
            discount.centerX == discountBg.centerX
            discount.top == discountBg.top + 4.5
            discount.bottom == discountBg.centerY
            
            off.centerX == discount.centerX
            off.top == discountBg.centerY
            off.bottom == discountBg.bottom - 4.5
        })
    }
    
    override func numberDigitals() -> Int {
        return 1
    }
    
    override func brandLabelRightPadding() -> CGFloat {
        return 54
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDiscount(discountPercent : Int?){
        discount.hidden = false
        if let value = discountPercent {
            discount.text = "\(value)%"
        }
    }


}
