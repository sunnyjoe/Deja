//
//  FindClothPBCView.swift
//  DejaFashion
//
//  Created by jiao qing on 19/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol FindClothPBCViewDelegate : NSObjectProtocol{
    func findClothPBCViewClickPrice(findClothPBCView : FindClothPBCView)
    func findClothPBCViewClickBrand(findClothPBCView : FindClothPBCView)
    func findClothPBCViewClickColor(findClothPBCView : FindClothPBCView)
}

class FindClothPBCView: UIView{
    weak var delegate : FindClothPBCViewDelegate?
    
    var priceLabel : UILabel!
    var brandLabel : UILabel!
    var colorLabel : UILabel!
    
    var sWidth : CGFloat = 100
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sWidth = frame.size.width / 3
        
        priceLabel = buildCell("Price(S$)", content: "All Price", index: 0)
        brandLabel = buildCell("Brands", content: "All Brands", index: 1)
        colorLabel = buildCell("Color", content: "All Color", index: 2)
    }
    
    func buildCell(title : String, content : String, index : CGFloat) -> UILabel{
        let titleLabel = UILabel(frame : CGRectMake(index * sWidth, 8.5, sWidth, 12))
        titleLabel.withText(title).withFontHeleticaThin(10).withTextColor(DJCommonStyle.Color41).textCentered()
        addSubview(titleLabel)
        
        let contentLabel = UILabel(frame : CGRectMake(index * sWidth + 3, 16, sWidth - 6, 33))
        contentLabel.withText(content).withFontHeletica(15).withTextColor(UIColor.defaultBlack()).textCentered()
        addSubview(contentLabel)
        contentLabel.addTapGestureTarget(self, action: #selector(contentLabelDidClicked(_:)))
        
        contentLabel.adjustsFontSizeToFitWidth = true
        
        if index < 2{
            let lineV = UIView(frame : CGRectMake(CGRectGetMaxX(contentLabel.frame) - 0.5, 4, 0.5, frame.size.height - 8))
            lineV.backgroundColor = DJCommonStyle.ColorCE
            addSubview(lineV)
        }
        
        return contentLabel
    }
    
    func contentLabelDidClicked(sender : UITapGestureRecognizer){
        guard let label = sender.view else{
            return
        }
        if label == priceLabel{
            delegate?.findClothPBCViewClickPrice(self)
        }else if label == brandLabel{
            delegate?.findClothPBCViewClickBrand(self)
        }else if label == colorLabel{
            delegate?.findClothPBCViewClickColor(self)
        }
    }
    
    func resetColor(name : String?){
        if name == nil{
            colorLabel.withText("All Color")
        }else{
            colorLabel.withText(name!)
        }
    }
    
    func resetBrand(name : String?){
        if name == nil{
            brandLabel.withText("All Brands")
        }else{
            brandLabel.withText(name!)
        }
    }
    
    func resetPrice(lowerPrice : Int, _ highPrice : Int){
        var str = ""
        if highPrice <= 0 && lowerPrice <= 0{
            str = "All Price"
        }else if highPrice > 0 && lowerPrice > 0{
            str = "\(lowerPrice) - \(highPrice)"
        }else if highPrice <= 0{
            str = "Above \(lowerPrice)"
        }else{
            str = "Within \(highPrice)"
        }
        priceLabel.withText(str)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
