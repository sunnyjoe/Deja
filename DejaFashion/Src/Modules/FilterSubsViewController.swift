//
//  FilterSubsViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 26/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

enum FilterType {
    case Brand
    case Color
    case Price
    case Category
    case Cutting
}

protocol FilterSubsViewControllerDelegate : NSObjectProtocol{
    func filterSubsViewControllerDidSelectBrand(filterSubsViewController : FilterSubsViewController, brand : BrandInfo?)
    func filterSubsViewControllerDidSelectColor(filterSubsViewController : FilterSubsViewController, color : ColorFilter?)
    func filterSubsViewControllerDidSelectPrice(filterSubsViewController : FilterSubsViewController, lowPrice : Int, highPrice : Int)
    func filterSubsViewControllerDidSelectSubCategory(filterSubsViewController : FilterSubsViewController, subCate : ClothSubCategory?)
    func filterSubsViewControllerDidSelectCuttingFilter(filterSubsViewController : FilterSubsViewController, filter : Filter?, filterCondtion: FilterCondition)
}

class FilterSubsViewController: DJBasicViewController {
    private var contentView : UIView?
    
    private var filterType = FilterType.Brand
    private var filterIds = [String]()
    private var selectedId : String?
    private var filerCondition : FilterCondition?
    
    private var lowPrice = 0
    private var highPrice = 0
    private var selectedLowPrice = 0
    private var selectedHighPrice = 0
    
    weak var delegate : FilterSubsViewControllerDelegate?
    
    private var priceSV : PriceSelectView?
    
    init(filterType : FilterType, filterIds : [String] = [String](), selectedId : String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.filterType = filterType
        self.filterIds = filterIds
        self.selectedId = selectedId
    }
    
    init(lowPrice : Int = 0, highPrice : Int = 0, selectedLowPrice : Int, selectedHighPrice : Int) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.filterType = .Price
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.selectedLowPrice = selectedLowPrice
        self.selectedHighPrice = selectedHighPrice
    }
    
    
    init(filterCondtion : FilterCondition, filterIds : [String] = [String](), selectedId : String? = nil ) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.filterType = .Cutting
        self.filterIds = filterIds
        self.selectedId = selectedId
        self.filerCondition = filterCondtion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if filterType == .Brand {
            showBrandSelectionView()
            title = DJStringUtil.localize("Filter by Brand", comment: "")
        }else if filterType == .Color{
            showColorSelectionView()
            title = DJStringUtil.localize("Filter by Color", comment: "")
        }else if filterType == .Price{
            showPriceSelectionView()
            title = DJStringUtil.localize("Filter by Price", comment: "")
        }else if filterType == .Category {
            showCategorySelectionView()
            title = DJStringUtil.localize("Filter by Category", comment: "")
        }else if filterType == .Cutting{
            showCuttingSelectionView()
            title = DJStringUtil.localize("Filter by \(filerCondition!.name)", comment: "")
        }
        
        addWhiteBackButton()
    }
    
    private func showColorSelectionView(){
        var colorFilters = [ColorFilter]()
        var selectedColor : ColorFilter?
        for one in filterIds {
            if let oneF = ConfigDataContainer.sharedInstance.getColorFilterById(one) {
                colorFilters.append(oneF)
                if oneF.id == selectedId {
                    selectedColor = oneF
                }
            }
        }
        
        let cSV = ColorSelectView(frame: view.bounds, filters : colorFilters)
        cSV.resetSelected(selectedColor)
        cSV.delegate = self
        view.addSubview(cSV)
        contentView = cSV
    }
    
    private func showPriceSelectionView(){
        priceSV = PriceSelectView(frame: CGRectMake(20, 20, view.frame.size.width - 40, 104))
        var range = [CGFloat]()
        
        if highPrice > 0 {
            let distance = (highPrice - lowPrice) / 5
            for index in 0...5{
                range.append(CGFloat(lowPrice + index * distance))
            }
            range[5] = CGFloat(highPrice)
            priceSV!.rangeSilderView.rangeValues = range
        }
        priceSV!.resetPrice(selectedLowPrice, high: selectedHighPrice)
        view.addSubview(priceSV!)
    }
    
    private func showCategorySelectionView(){
        let cateSV = CategorySelectView(frame : view.bounds)
        view.addSubview(cateSV)
        cateSV.delegate = self
        
        let allCates = ConfigDataContainer.sharedInstance.getConfigCategory()
       
        var slimedCates = [ClothCategory]()
        for one in allCates {
            let onePy = ClothCategory()
            onePy.categoryId = one.categoryId
            onePy.iconURL = one.iconURL
            onePy.name = one.name
            onePy.subCategories = [ClothSubCategory]()
            
            for oneSub in one.subCategories{
                if filterIds.contains(oneSub.categoryId) {
                    onePy.subCategories.append(oneSub.copy() as! ClothSubCategory)
                }
            }
            if onePy.subCategories.count > 0 {
                slimedCates.append(onePy)
            }
        }
        cateSV.resetData(slimedCates)
        
        var selected : ClothSubCategory?
        for one in allCates {
            for oneSub in one.subCategories{
                if oneSub.categoryId == selectedId {
                    selected = oneSub
                    break
                }
            }
            if selected != nil {
                cateSV.setSelectedCatagory(selected!)
                break
            }
        }
        contentView = cateSV
    }
    
    private func showCuttingSelectionView(){
        let cutSV = CuttingSelectView(frame: view.bounds, filterCondition: self.filerCondition!, choice: filterIds)
        cutSV.delegate = self
        cutSV.resetSelected(selectedId)
        view.addSubview(cutSV)
        contentView = cutSV
    }
    
    private func showBrandSelectionView(){
        var brandList = [BrandInfo]()
        var selectedBrand : BrandInfo?
        if let tmp = ConfigDataContainer.sharedInstance.getAllBrandList(){
            for oneBrand in tmp {
                if filterIds.contains(oneBrand.id) {
                    brandList.append(oneBrand)
                }
                if selectedId != nil && oneBrand.id == selectedId! {
                    selectedBrand = oneBrand
                }
            }
        }
        let brandSV = BrandSelectView(frame: view.bounds, brands: brandList)
        view.addSubview(brandSV)
        contentView = brandSV
        brandSV.delegate = self
        brandSV.resetSelectedBrand(selectedBrand)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        contentView?.frame = view.bounds
    }
    
    @objc override func goBack() {
        if filterType == .Price && priceSV != nil{
            delegate?.filterSubsViewControllerDidSelectPrice(self, lowPrice: priceSV!.lowerPrice, highPrice: priceSV!.highPrice)
        }else{
            super.goBack()
        }
    }
}

extension FilterSubsViewController: BrandSelectViewDelegate, ColorSelectViewDelegate, CategorySelectViewDelegate, CuttingSelectViewDelegate{
    func brandSelectViewSelectBrand(brandSelectView: BrandSelectView, brand: BrandInfo?) {
        delegate?.filterSubsViewControllerDidSelectBrand(self, brand: brand)
    }
    
    func colorSelectViewSelectColor(colorSelectView: ColorSelectView, color: ColorFilter?) {
        delegate?.filterSubsViewControllerDidSelectColor(self, color: color)
    }
    
    func categorySelectViewDidSelectSubCategory(categorySelectView: CategorySelectView, subCategory: ClothSubCategory?) {
        delegate?.filterSubsViewControllerDidSelectSubCategory(self, subCate: subCategory)
    }
    
    func cuttingSelectViewSelectFilter(cuttingSelectView: CuttingSelectView, filter: Filter?) {
        delegate?.filterSubsViewControllerDidSelectCuttingFilter(self, filter: filter, filterCondtion: filerCondition!)
    }
}

