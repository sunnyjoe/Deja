//
//  BrandListWindow.swift
//  DejaFashion
//
//  Created by jiao qing on 23/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class BrandListWindow: SlideWindow {
    private weak var selectTarget : AnyObject?
    private var selectSelector : Selector?
 
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        contentNormalFrame = CGRectMake(frame.size.width - 255, 0, 255, frame.size.height)
        contentHiddenFrame = CGRectMake(frame.size.width, 0, 255, frame.size.height)
        contentView.frame = contentHiddenFrame
        
        let brandList = ConfigDataContainer.sharedInstance.getAllBrandList()
        if brandList == nil{
            return
        }
        let names = ClothesDataContainer.sharedInstance.extractBrandNames(brandList!)
        
        let label = UILabel(frame: CGRectMake(22, 20, contentView.frame.size.width - 23, 44))
        label.withFontHeleticaMedium(14).withTextColor(UIColor(fromHexString: "eaeaea")).withText("Brand List")
        contentView.addSubview(label)
        
        let line = UIView(frame: CGRectMake(0, CGRectGetMaxY(label.frame) - 0.5, contentView.frame.size.width, 0.5))
        contentView.addSubview(line)
        line.backgroundColor = UIColor(fromHexString: "f1f1f1")
        
        let brandTable = AlphabetTableView()
        brandTable.setTheContent(names)
        brandTable.setBlackColorStyle()
        contentView.addSubview(brandTable)
        constrain(brandTable) { brandTable in
            brandTable.top == brandTable.superview!.top + 64
            brandTable.left == brandTable.superview!.left
            brandTable.right == brandTable.superview!.right
            brandTable.bottom == brandTable.superview!.bottom
        }
        brandTable.setContentSelector(self, sel: #selector(BrandListWindow.didSelectBrandName(_:)))
    }
    
    func didSelectBrandName(str : String){
        if let brand = ClothesDataContainer.sharedInstance.findBrandByName(str){
            if selectTarget != nil && selectSelector != nil{
                if selectTarget!.respondsToSelector(selectSelector!){
                    selectTarget!.performSelector(selectSelector!, withObject: brand)
                }
            }
        }
    }
    
    func setContentSelector(target : AnyObject, sel : Selector){
        selectTarget = target
        selectSelector = sel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
