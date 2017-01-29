//
//  FindClothSelecWindow.swift
//  DejaFashion
//
//  Created by jiao qing on 19/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol FindClothPriceSelecWindowDelegate : NSObjectProtocol{
    func findClothPriceSelecWindowSelectPrice(findClothPriceSelecWindow : FindClothPriceSelecWindow, lowPrice : Int, highPrice : Int)
}

class FindClothPriceSelecWindow: SlideWindow {
    let topView = UIView()
    
    weak var delegate : FindClothPriceSelecWindowDelegate?
    var priceSV : PriceSelectView!
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backView.backgroundColor = UIColor(fromHexString: "272629", alpha: 0.5)
        
        contentNormalFrame = CGRectMake(0, frame.size.height - 223, frame.size.width, 223)
        contentHiddenFrame = CGRectMake(0, frame.size.height, frame.size.width, 223)
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.frame = contentHiddenFrame
        
        topView.backgroundColor = DJCommonStyle.ColorEA
        topView.frame = CGRectMake(0, 0, frame.size.width, 40)
        contentView.addSubview(topView)
        buildTopView()
        topView.addBorder()
        
  
        priceSV = PriceSelectView(frame: CGRectMake(20, 70, frame.size.width - 40, 104))
        priceSV.rangeSilderView.rangeValues = [0, 30, 50, 80, 120, 200]
        contentView.addSubview(priceSV)
    }
    
    func buildTopView(){
        let cancelLabel = UILabel(frame : CGRectMake(20, 5, 100, 30))
        cancelLabel.withTextColor(UIColor.defaultBlack()).withFontHeletica(14).withText("Cancel")
        cancelLabel.addTapGestureTarget(self, action: #selector(cancelDidClicked))
        topView.addSubview(cancelLabel)
        
        let doneLabel = UILabel(frame : CGRectMake(frame.size.width - 100 - 20, 5, 100, 30))
        doneLabel.withTextColor(UIColor.defaultBlack()).withFontHeletica(14).withText("Done")
        doneLabel.addTapGestureTarget(self, action: #selector(doneDidClicked))
        doneLabel.textAlignment = .Right
        topView.addSubview(doneLabel)
    }
    
    
    func resetPrice(low : Int, high : Int){
         priceSV.resetPrice(low, high: high)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelDidClicked(){
        hideAnimation()
    }
    
    func doneDidClicked(){
        delegate?.findClothPriceSelecWindowSelectPrice(self, lowPrice: priceSV.lowerPrice, highPrice: priceSV.highPrice)
        hideAnimation()
    }
}
