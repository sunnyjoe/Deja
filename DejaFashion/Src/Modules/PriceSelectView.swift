//
//  PriceSelectView.swift
//  DejaFashion
//
//  Created by jiao qing on 26/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


class PriceSelectView: UIView, DJRangeSilderViewDelegate {
    var lowerPrice : Int = 0
    var highPrice : Int = 0 //max
    
    let rangeSilderView = DJRangeSilderView()
    private let priceLabel = UILabel()
    private let infoLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
  
        priceLabel.frame = CGRectMake(0, 0, frame.size.width, 17)
        priceLabel.withText("All Price").withFontHeleticaMedium(16).withTextColor(UIColor.defaultRed()).textCentered()
        addSubview(priceLabel)
        
        rangeSilderView.rangeValues = [0, 30, 50, 80, 120, 200]
        rangeSilderView.delegate = self
        addSubview(rangeSilderView)
        
        infoLabel.withText(DJStringUtil.localize("Price (S$)", comment:"")).withFontHeletica(14).withTextColor(UIColor.defaultBlack()).textCentered()
        addSubview(infoLabel)
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        
        priceLabel.frame = CGRectMake(0, 0, frame.size.width, 17)
        rangeSilderView.frame = CGRectMake(20, 45, frame.size.width - 40, 60)
        infoLabel.frame = CGRectMake(0, CGRectGetMaxY(rangeSilderView.frame), frame.size.width, 17)
    }
    
    func rangeValueDidChanged(rangeSliderView: DJRangeSilderView, lowerValue: CGFloat, higherValue: CGFloat){
        lowerPrice = Int(lowerValue)
        highPrice = Int(higherValue)
        
        changePriceLabel()
    }
    
    func changePriceLabel(){
        let str = PriceSelectView.getCombinedPriceString(lowerPrice, highPrice: highPrice)
        priceLabel.withText(str)
    }
    static func getCombinedPriceString(lowerPrice : Int, highPrice : Int) -> String{
        var str = ""
        if highPrice <= 0 && lowerPrice <= 0{
            str = DJStringUtil.localize("All Price", comment:"")
        }else if highPrice > 0 && lowerPrice > 0{
            str = "\(lowerPrice) - \(highPrice)"
        }else if highPrice <= 0{
            str = DJStringUtil.localize("Above ", comment:"") + String(lowerPrice)
        }else{
            str = DJStringUtil.localize("Within ", comment:"") + String(highPrice)
        }
        return str
    }
    
    func resetPrice(low : Int, high : Int){
        if rangeSilderView.rangeValues.count == 0{
            return
        }
        
        lowerPrice = low
        highPrice = high
        changePriceLabel()
        
        rangeSilderView.startPointsSlider(CGFloat(lowerPrice), rightValue: CGFloat(highPrice))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
