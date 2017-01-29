//
//  FindClothBrandOptionWindow.swift
//  DejaFashion
//
//  Created by jiao qing on 19/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol FindClothBrandOptionWindowDelegate : NSObjectProtocol{
    func findClothBrandOptionWindowSelectBrand(findClothBrandOptionWindow : FindClothBrandOptionWindow, brand : BrandInfo?)
}

class FindClothBrandOptionWindow: SlideWindow {
    let topView = UIView()
    weak var delegate : FindClothBrandOptionWindowDelegate?
    
    var selectedBrand : BrandInfo?
    var names = [String]()
    var brandTableView : StringListView!
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        
        backView.backgroundColor = UIColor(fromHexString: "272629", alpha: 0.5)
        
        contentNormalFrame = CGRectMake(0, frame.size.height - 413, frame.size.width, 413)
        contentHiddenFrame = CGRectMake(0, frame.size.height, frame.size.width, 413)
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.frame = contentHiddenFrame
        
        topView.frame = CGRectMake(0, 0, frame.size.width, 40)
        topView.backgroundColor = DJCommonStyle.ColorEA
        contentView.addSubview(topView)
        buildTopView()
        topView.addBorder()
        
        var brandList = [BrandInfo]()
        if let tmp = ConfigDataContainer.sharedInstance.getAllBrandList(){
            brandList = tmp
        }
        
        brandTableView = StringListView(frame : CGRectMake(0, 40, contentView.frame.size.width, contentView.frame.size.height - 40))
        names.append(DJStringUtil.localize("All Brands", comment:""))
        names.appendContentsOf(ClothesDataContainer.sharedInstance.extractBrandNames(brandList))
        brandTableView.setTheContent(names)
        contentView.addSubview(brandTableView)
        brandTableView.resetSelectedName(names[0])
        brandTableView.setContentSelector(self, sel: #selector(didSelectBrandName(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didSelectBrandName(str : String){
        selectedBrand = ClothesDataContainer.sharedInstance.findBrandByName(str)
        doneDidClicked()
    }
    
    func buildTopView(){
        let cancelLabel = UILabel(frame : CGRectMake(20, 5, 100, 30))
        cancelLabel.withTextColor(UIColor.defaultBlack()).withFontHeletica(14).withText(DJStringUtil.localize("Cancel", comment:""))
        cancelLabel.addTapGestureTarget(self, action: #selector(cancelDidClicked))
        topView.addSubview(cancelLabel)
    }
    
    func resetBrand(brand : BrandInfo?){
        selectedBrand = brand
        if let tmp = brand{
            brandTableView.resetSelectedName(tmp.name)
        }else{
            brandTableView.resetSelectedName(names[0])
        }
    }
    
    func cancelDidClicked(){
        hideAnimation()
    }
    
    func doneDidClicked(){
        self.delegate?.findClothBrandOptionWindowSelectBrand(self, brand: self.selectedBrand)
        self.hideAnimation()
    }
}
