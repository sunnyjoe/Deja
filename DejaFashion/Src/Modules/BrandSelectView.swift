//
//  BrandSelectView.swift
//  DejaFashion
//
//  Created by jiao qing on 26/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


protocol BrandSelectViewDelegate : NSObjectProtocol{
    func brandSelectViewSelectBrand(brandSelectView : BrandSelectView, brand : BrandInfo?)
}

class BrandSelectView: UIView {
    weak var delegate : BrandSelectViewDelegate?
    
    var selectedBrand : BrandInfo?
    var names = [String]()
    var brandTableView : StringListView!
    
    init(frame: CGRect, brands : [BrandInfo]) {
        super.init(frame : frame)
       
        brandTableView = StringListView(frame : bounds)
        names.append("All Brands")
        brandTableView.textCenterAligned = false
        names.appendContentsOf(ClothesDataContainer.sharedInstance.extractBrandNames(brands))
        brandTableView.setTheContent(names)
        addSubview(brandTableView)
        brandTableView.resetSelectedName(names[0])
        brandTableView.setContentSelector(self, sel: #selector(didSelectBrandName(_:)))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        brandTableView.frame = bounds
    }
    func didSelectBrandName(str : String){
        selectedBrand = ClothesDataContainer.sharedInstance.findBrandByName(str)
        delegate?.brandSelectViewSelectBrand(self, brand: selectedBrand)
    }
    
    func resetSelectedBrand(brand : BrandInfo?){
        selectedBrand = brand
        if let tmp = brand{
            brandTableView.resetSelectedName(tmp.name)
        }else{
            brandTableView.resetSelectedName(names[0])
        }
    }
    
}
