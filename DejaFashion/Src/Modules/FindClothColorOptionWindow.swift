//
//  FindClothColorOptionWindow.swift
//  DejaFashion
//
//  Created by jiao qing on 19/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol FindClothColorOptionWindowDelegate : NSObjectProtocol{
    func findClothColorOptionWindowSelectColor(findClothColorOptionWindow : FindClothColorOptionWindow, colorFilter : ColorFilter?)
}

class FindClothColorOptionWindow: SlideWindow {
    let topView = UIView()
    let infoLabel = UILabel()
    let cFWidth : CGFloat = 30
    var column : CGFloat = 6
    var colorBtns = [UIButton]()
    
    weak var delegate : FindClothColorOptionWindowDelegate?
    var selectedColor : ColorFilter?
    
    let colorFilter = ConfigDataContainer.sharedInstance.getConfigColorFilters()
    
    let circleIV = UIImageView()
    var allBtn : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backView.backgroundColor = UIColor(fromHexString: "272629", alpha: 0.5)
        contentView.backgroundColor = UIColor.whiteColor()
        
        topView.backgroundColor = DJCommonStyle.ColorEA
        topView.frame = CGRectMake(0, 0, frame.size.width, 40)
        contentView.addSubview(topView)
        buildTopView()
        topView.addBorder()
        
        infoLabel.frame = CGRectMake(0, 63, frame.size.width, 17)
        infoLabel.withText(DJStringUtil.localize("All Color", comment:"")).withFontHeleticaMedium(16).withTextColor(UIColor.defaultRed()).textCentered()
        contentView.addSubview(infoLabel)
        
        if frame.size.width > 375 {
            column = 7
        }
        var totalHeight = ceil(CGFloat(colorFilter.count + 1) / column) * 52 - 23
        totalHeight += 100 + 41
        
        contentNormalFrame = CGRectMake(0, frame.size.height - totalHeight, frame.size.width, totalHeight)
        contentHiddenFrame = CGRectMake(0, frame.size.height, frame.size.width, totalHeight)
        contentView.frame = contentHiddenFrame
        
        buildColorPanel()
    }
    
    func buildColorPanel(){
        var oX : CGFloat = 23 + 10
        var oY : CGFloat = 100
        let space = (frame.size.width - oX * 2 - cFWidth * column) / (column - 1)
        
        allBtn = UIButton(frame : CGRectMake(oX, oY, cFWidth, cFWidth))
        allBtn.layer.cornerRadius = cFWidth / 2
        allBtn.backgroundColor = DJCommonStyle.ColorEA
        allBtn.withTitle(DJStringUtil.localize("ALL", comment:"")).withFontHeletica(12).withTitleColor(DJCommonStyle.Color81)
        colorBtns.append(allBtn)
        allBtn.addTarget(self, action: #selector(ColorFilterViewContainer.colorBtnDidTapped(_:)), forControlEvents: .TouchUpInside)
        contentView.addSubview(allBtn)
        
        circleIV.frame = CGRectMake(oX - 5, oY - 5, 40, 40)
        circleIV.layer.cornerRadius = 20
        circleIV.layer.borderWidth = 1
        circleIV.layer.borderColor = UIColor.defaultRed().CGColor
        
        oX += cFWidth + space
        for cF in colorFilter{
            let cIBtn = UIButton(frame: CGRectMake(oX, oY, cFWidth, cFWidth))
            cIBtn.property = cF
            cIBtn.backgroundColor = cF.colorValue
            contentView.addSubview(cIBtn)
            colorBtns.append(cIBtn)
            cIBtn.addTarget(self, action: #selector(ColorFilterViewContainer.colorBtnDidTapped(_:)), forControlEvents: .TouchUpInside)
            cIBtn.layer.cornerRadius = cFWidth / 2
            
            if colorFilter.indexOf(cF) == colorFilter.count - 1 {
                cIBtn.layer.borderColor = UIColor(fromHexString: "818181").CGColor
                cIBtn.layer.borderWidth = 0.5
            }
            
            oX += cFWidth + space
            if oX > frame.size.width - 33 - cFWidth + 1{
                oX = 23 + 10
                oY += 23 + cFWidth
            }
        }
        
        contentView.addSubview(circleIV)
    }
    
    func colorBtnDidTapped(btn : UIButton){
        for oneBtn in colorBtns{
            if oneBtn == btn{
                selectedColor = nil
                if let cfilter = btn.property as? ColorFilter {
                    selectedColor = cfilter
                }
                
                doneDidClicked()
                circleIV.frame = CGRectMake(oneBtn.frame.origin.x - 5, oneBtn.frame.origin.y - 5, 40, 40)
                changeInfoLabel()
            }
        }
    }
    
    func resetSelectedColor(color : ColorFilter?){
        selectedColor = color
        
        var theBtn : UIButton = allBtn
        if selectedColor != nil {
            for oneBtn in colorBtns{
                if let cfilter = oneBtn.property as? ColorFilter {
                    if cfilter.name == selectedColor!.name {
                        theBtn = oneBtn
                        break
                    }
                }
            }
        }
        circleIV.frame = CGRectMake(theBtn.frame.origin.x - 5, theBtn.frame.origin.y - 5, 40, 40)
        changeInfoLabel()
    }
    
    func changeInfoLabel(){
        if let tmp = selectedColor{
            infoLabel.withText(tmp.name)
        }else{
            infoLabel.withText(DJStringUtil.localize("All Color", comment:""))
        }
    }
    
    func buildTopView(){
        let cancelLabel = UILabel(frame : CGRectMake(20, 5, 100, 30))
        cancelLabel.withTextColor(UIColor.defaultBlack()).withFontHeletica(14).withText(DJStringUtil.localize("Cancel", comment:""))
        cancelLabel.addTapGestureTarget(self, action: #selector(cancelDidClicked))
        topView.addSubview(cancelLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelDidClicked(){
        hideAnimation()
    }
    
    func doneDidClicked(){
        self.delegate?.findClothColorOptionWindowSelectColor(self, colorFilter: self.selectedColor)
        self.hideAnimation()
    }
}
