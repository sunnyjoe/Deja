//
//  FindClothRefineVIew.swift
//  DejaFashion
//
//  Created by jiao qing on 11/1/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

@objc protocol FindClothRefineViewDelegate : NSObjectProtocol{
    func refineViewDone(refineView : FindClothRefineView)
    
    optional func refineViewChanged(refineView : FindClothRefineView)
}

let tagSelectedIcon : Int32 = 1111

class ArrowButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setIndicator(false)
    }
    
    func setIndicator(expand : Bool){
        if expand {
            setImage(UIImage(named:"FilterArrowUp"), forState: .Normal)
        }else{
            setImage(UIImage(named:"FilterArrowDown"), forState: .Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RefineFilterBtn : UIButton{
    var selectorIV = UIImageView()
    var filter : Filter?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, frame.size.height / 2)
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1
        clipsToBounds = true
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(UIColor.defaultRed(), forState: .Highlighted)
        layer.cornerRadius = frame.size.height / 2
        titleLabel?.numberOfLines = 0
        withFontHeletica(14)
        
        selectorIV.backgroundColor = UIColor.whiteColor()
        selectorIV.frame =  CGRectMake(8, frame.size.height / 2 - 19 / 2, 19, 19)
        setSelectedIcon(false)
        addSubview(selectorIV)
    }
    
    func setSelectedIcon(selected : Bool){
        if selected {
            selectorIV.image = UIImage(named:"RefineSelectedCircle")
        }else{
            selectorIV.image = UIImage(named:"RefineCircle")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColorFilterViewContainer : UIView {
    var colorBtns = [UIButton]()
    var whiteColorBtn : UIButton?
    unowned var refineView : FindClothRefineView
    init(frame: CGRect, refineView : FindClothRefineView) {
        self.refineView = refineView
        super.init(frame: frame)
        
        let nameLabel = UILabel(frame: CGRectMake(0, 0, frame.size.width, 39))
        nameLabel.withFontHeleticaMedium(15).withTextColor(UIColor.defaultBlack()).withText("Color")
        nameLabel.textAlignment = .Left
        addSubview(nameLabel)
        
        let colorFilter = ConfigDataContainer.sharedInstance.getConfigColorFilters()
        let cFWidth = (frame.size.width - 5) / 6
        var oX : CGFloat = 0
        var oY = CGRectGetMaxY(nameLabel.frame)
        
        for cF in colorFilter{
            let cIBtn = UIButton(frame: CGRectMake(oX, oY, cFWidth, cFWidth))
            cIBtn.property = cF
            cIBtn.backgroundColor = cF.colorValue
            addSubview(cIBtn)
            colorBtns.append(cIBtn)
            cIBtn.addTarget(self, action: #selector(ColorFilterViewContainer.colorBtnDidTapped(_:)), forControlEvents: .TouchUpInside)
            cIBtn.layer.borderWidth = 1
            cIBtn.layer.borderColor = UIColor.clearColor().CGColor
            
            if colorFilter.indexOf(cF) == colorFilter.count - 1 {
                cIBtn.layer.borderColor = UIColor(fromHexString: "cecece").CGColor
                whiteColorBtn = cIBtn
            }
            
            oX += cFWidth + 1
            if oX > frame.size.width && colorFilter.indexOf(cF) < colorFilter.count - 1{
                oX = 0
                oY += cFWidth + 1
            }
        }
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, oY + cFWidth)
    }
    
    func colorBtnDidTapped(btn : UIButton){
        if let xtmp = btn.property as? Filter {
            if !refineView.checkInSelected(xtmp) {
                for sfr in refineView.selectedFilters{
                    if sfr.isKindOfClass(ColorFilter){
                        refineView.selectedFilters.removeAtIndex(refineView.selectedFilters.indexOf(sfr)!)
                    }
                }
                refineView.selectedFilters.append(xtmp)
            }else{
                refineView.removeFilterInSelection(xtmp)
            }
        }
        resetColorFilterAndBtns()
        refineView.delegate?.refineViewChanged?(refineView)
    }
    
    func resetColorFilterAndBtns(){
        for tmpBtn in colorBtns{
            tmpBtn.removeAllSubViews()
            if whiteColorBtn == tmpBtn {
                tmpBtn.layer.borderColor = UIColor(fromHexString: "cecece").CGColor
            }else{
                tmpBtn.layer.borderColor = UIColor.clearColor().CGColor
            }
        }
        
        for tmpBtn in colorBtns{
            if let xtmp = tmpBtn.property as? Filter {
                if refineView.checkInSelected(xtmp){
                    tmpBtn.layer.borderColor = UIColor(fromHexString: "ff6854").CGColor
                    tmpBtn.removeAllSubViews()
                    refineView.addIconToSelectedView(tmpBtn)
                }else {
                    tmpBtn.removeAllSubViews()
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SubCategoryViewContainer : UIView {
    
    var categoryItemViews = [UIView]()
    var categoryIcons = [UIView]()
    let categoryScrollView = UIScrollView()
    var categoryItemWidth = 0.0 as CGFloat
    var categoryItemHeight = 0.0 as CGFloat
    
    var categoryLabelScrollView : UIScrollView?
    var categories : [ClothCategory]?
    
    var isAll = false
    
    unowned var refineView : FindClothRefineView
    
    init(frame: CGRect, refineView : FindClothRefineView) {
        self.refineView = refineView
        super.init(frame: frame)
        categoryItemWidth = (frame.size.width - 46) / 5
        categoryItemHeight = categoryItemWidth + 33 + 3
        
        var oY = 0 as CGFloat
        let divider = UIView(frame: CGRectMake(0, 42.5, frame.size.width, 0.5)).withBackgroundColor(DJCommonStyle.DividerColor)
        addSubview(divider)
        if refineView.category.categoryId == "0" {
            self.categories = ConfigDataContainer.sharedInstance.getConfigCategory()
            categoryLabelScrollView = UIScrollView(frame: CGRectMake(0, oY, frame.size.width, 43))
            categoryLabelScrollView?.showsHorizontalScrollIndicator = false
            var totalWidth = 0 as CGFloat
            for (index, c) in self.categories!.enumerate() {
                let label = DJLabel(frame: CGRectMake(totalWidth, oY, frame.size.width, 43))
                label.insets = UIEdgeInsets(top: 3, left: 5, bottom: 0, right: 15)
                label.withFontHeleticaMedium(15).withTextColor(UIColor.defaultBlack()).withText(c.name)
                label.tag = index
                label.addTapGestureTarget(self, action: #selector(SubCategoryViewContainer.chooseMainCategory(_:)))
                label.sizeToFit()
                label.frame = CGRectMake(totalWidth, oY, label.frame.width, 43)
                totalWidth += label.frame.width
                categoryLabelScrollView?.addSubview(label)
            }
            categoryLabelScrollView?.contentSize = CGSize(width: totalWidth, height: 43)
            addSubview(categoryLabelScrollView!)
            refineView.category = categories!.first!
            setCategorySelected(0)
            isAll = true
        }else {
            let categoryLabel = UILabel(frame: CGRectMake(0, oY, frame.size.width, 43))
            categoryLabel.withFontHeleticaMedium(15).withTextColor(UIColor.defaultBlack()).withText(refineView.category.name)
            categoryLabel.textAlignment = .Left
            addSubview(categoryLabel)
        }

        oY += 60
        
        categoryScrollView.frame = CGRectMake(0 as CGFloat, oY, frame.size.width - 46, 180 as CGFloat)
        categoryScrollView.showsHorizontalScrollIndicator = false
        categoryScrollView.bounces = false
        
        addCategoryViews()
        
        addSubview(categoryScrollView)
        
        oY += categoryScrollView.frame.height
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, oY)
    }
    
    func setCategorySelected(index : Int) {
        if let labels = self.categoryLabelScrollView {
            var center = 0 as CGFloat
            for (i,label) in labels.subviews.enumerate() {
                label.removeAllSubViews()
                if let l = label as? UILabel {
                    if i == index {
                        l.textColor = UIColor.defaultBlack()
                        let hightlightedView = UIView().withBackgroundColor(UIColor.defaultBlack())
                        label.addSubview(hightlightedView)
                        constrain(hightlightedView, block: { (hightlightedView) in
                            hightlightedView.bottom == hightlightedView.superview!.bottom
                            hightlightedView.height == 1
                            hightlightedView.left == hightlightedView.superview!.left
                            hightlightedView.right == hightlightedView.superview!.right - 10
                        })
                        center = label.center.x
                    }else {
                        l.textColor = UIColor.gray81Color()
                    }
                }
            }
            if labels.center.x > center {
                labels.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                return
            }
            var offsetToScroll = center - labels.center.x
            let maxOffset = labels.contentSize.width - labels.frame.width
            if offsetToScroll > maxOffset {
                offsetToScroll = maxOffset
            }
            labels.setContentOffset(CGPoint(x: offsetToScroll, y: 0), animated: true)
        }
    }
    
    func chooseMainCategory(reg : UITapGestureRecognizer) {
        if let index = reg.view?.tag {
            let c = self.categories![index]
            if c.categoryId != refineView.category.categoryId {
                refineView.category = c
                refineView.subCategoryId = nil
                refineView.filterConditionIds = []
                refineView.filterConditions = []
                refineView.selectedFilters = refineView.selectedFilters.filter{ $0.isKindOfClass(ColorFilter)}
                let lastHeight = categoryScrollView.frame.height
                addCategoryViews()
                refineView.reloadFilters()
               // refineView.delegate?.refineViewChanged?(refineView)
                self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, frame.height - lastHeight + categoryScrollView.frame.height)
                refineView.setupViewHeader()
                setCategorySelected(index)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculateOffsetX(i : Int) -> CGFloat {
        if i <= 2 {
            return 0
        }
        
        let maxOffset = categoryScrollView.contentSize.width - categoryScrollView.frame.width
        
        let offset = categoryItemWidth * CGFloat(i - 2)
        
        if offset > maxOffset {
            return maxOffset
        }
        
        return offset
    }
    
    func reset() {
        if isAll {
            if refineView.subCategoryId != nil {
                var index = -1
                let mainCategories = ConfigDataContainer.sharedInstance.getConfigCategory()
                var subCategory : ClothSubCategory?
                for (i,mainCategory) in mainCategories.enumerate() {
                    for c in mainCategory.subCategories {
                        if c.categoryId == refineView.subCategoryId {
                            index = i
                            subCategory = c
                        }
                    }
                }
                refineView.category = mainCategories[index]
                refineView.filterConditionIds = subCategory?.filterConditions
                let lastHeight = categoryScrollView.frame.height
                addCategoryViews()
                refineView.reloadFilters()
//                refineView.delegate?.refineViewChanged?(refineView)
                self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, frame.height - lastHeight + categoryScrollView.frame.height)
                refineView.setupViewHeader()
                setCategorySelected(index)
            }
        }else {
            let lastHeight = categoryScrollView.frame.height
            showAllItemsLayout()
            self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, frame.height - lastHeight + categoryScrollView.frame.height)
            refineView.setupViewHeader()
        }
        for (i,icon) in categoryIcons.enumerate() {
            icon.removeSubViewByTag(tagSelectedIcon)
            if refineView.subCategoryId == refineView.category.subCategories[i].categoryId {
                icon.layer.borderWidth = 2
                icon.layer.borderColor = UIColor(fromHexString: "ff6854").CGColor
                refineView.addIconToSelectedView(icon)
            }else {
                icon.layer.borderWidth = 1
                icon.layer.borderColor = DJCommonStyle.DividerColor.CGColor
            }
        }
    }
    
    func addCategoryViews() {
        categoryScrollView.removeAllSubViews()
        categoryItemViews.removeAll()
        categoryIcons.removeAll()
        let subCategories = refineView.category.subCategories
        
        let itemWidth = (frame.size.width) / 5
        let itemHeight = itemWidth + 33 + 3
        for (i, c) in subCategories.enumerate() {
            let item = UIView(frame: CGRectMake(0, 0, itemWidth, itemHeight))
            
            let iconUrl = c.iconURL
            let name = c.name
            let imageViewContainer = UIView(frame: CGRectMake(0, 0, itemWidth, itemWidth))
            imageViewContainer.layer.borderWidth = 1
            imageViewContainer.layer.borderColor = DJCommonStyle.DividerColor.CGColor
            
            let padding = 8 as CGFloat
            let imageView = UIImageView(frame: CGRectMake(padding, padding, itemWidth - padding * 2, itemWidth - padding * 2))
            imageViewContainer.addSubview(imageView)
            imageView.sd_setImageWithURL(NSURL(string: iconUrl!)!)
            let label = UILabel(frame: CGRectMake(0, itemWidth, itemWidth, 33))
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.withFontHeletica(13).withTextColor(UIColor.defaultBlack()).withText(name).textCentered()
            item.addSubviews(imageViewContainer, label)
            categoryScrollView.addSubview(item)
            imageViewContainer.tag = i + 1
            imageViewContainer.addTapGestureTarget(self, action: #selector(SubCategoryViewContainer.tapCategory(_:)))
            
            categoryItemViews.append(item)
            categoryIcons.append(imageViewContainer)
        }
        showAllItemsLayout()
    }
    
    func showAllItemsLayout() {
        let subCategories = refineView.category.subCategories
        
        let itemWidth = (frame.size.width) / 5
        let itemHeight = itemWidth + 33 + 3
        var offsetX = 0.0 as CGFloat
        var offsetY = 0.0 as CGFloat
        
        for i in 0..<subCategories.count {
            if i > 0 && i % 5 == 0 {
                offsetX = 0.0
                offsetY += itemHeight
            }
            categoryItemViews[i].frame = CGRectMake(offsetX, offsetY, itemWidth, itemHeight)
            offsetX += itemWidth
        }
        
        categoryScrollView.frame = CGRectMake(categoryScrollView.frame.origin.x, categoryScrollView.frame.origin.y, self.frame.width, offsetY + itemHeight)
        categoryScrollView.contentSize = categoryScrollView.frame.size
    }
    
//    func horizontalLayout() {
//        let itemWidth = (frame.size.width) / 5
//        let itemHeight = itemWidth + 33 + 3
//        for (i, item) in self.categoryItemViews.enumerate() {
//            item.frame = CGRectMake(CGFloat(i) * itemWidth, 0.0 as CGFloat, itemWidth, itemHeight)
//        }
//        categoryScrollView.scrollEnabled = true
//        categoryScrollView.contentSize = CGSize(width: CGFloat(self.categoryItemViews.count) * itemWidth, height: itemHeight)
//        categoryScrollView.frame = CGRectMake(categoryScrollView.frame.origin.x, categoryScrollView.frame.origin.y, self.frame.width, itemHeight)
//    }
    
    func tapCategory(reg : UITapGestureRecognizer) {
        if let index = reg.view?.tag {
            if index > 0 {
                for (i,icon) in categoryIcons.enumerate() {
                    icon.removeSubViewByTag(tagSelectedIcon)
                    if i == index - 1 {
                        if refineView.subCategoryId == refineView.category.subCategories[i].categoryId {
                            icon.layer.borderWidth = 1
                            icon.layer.borderColor = DJCommonStyle.DividerColor.CGColor
                            refineView.subCategoryId = nil
                            refineView.filterConditionIds = []
                            refineView.filterConditions = []
                            refineView.selectedFilters = refineView.selectedFilters.filter{ $0.isKindOfClass(ColorFilter) }
                        }else {
                            icon.layer.borderWidth = 2
                            icon.layer.borderColor = UIColor(fromHexString: "ff6854").CGColor
                            refineView.subCategoryId = refineView.category.subCategories[i].categoryId
                            refineView.filterConditionIds = refineView.category.subCategories[i].filterConditions
                            refineView.filterConditions = refineView.getFilterCondition()
                            refineView.addIconToSelectedView(icon)
                        }
                    }else {
                        icon.layer.borderWidth = 1
                        icon.layer.borderColor = DJCommonStyle.DividerColor.CGColor
                    }
                }
                
            }
            let lastHeight = categoryScrollView.frame.height
            showAllItemsLayout()
            refineView.reloadFilters()
            refineView.delegate?.refineViewChanged?(refineView)
            self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, frame.height - lastHeight + categoryScrollView.frame.height)
            refineView.setupViewHeader()
        }
    }
}

class BrandFilterViewContainer : UIView {
    unowned var refineView : FindClothRefineView
    var brandWindow : BrandListWindow?
    
    var recommandList = [BrandInfo]()
    var selectedBrand : BrandInfo?
    
    private var currentList = [BrandInfo]()

    init(frame: CGRect, refineView : FindClothRefineView) {
        self.refineView = refineView
        super.init(frame: frame)
        
        if let tmp = ConfigDataContainer.sharedInstance.getRecommendBrandList(){
            recommandList = tmp
        }
        
        let nameLabel = UILabel(frame: CGRectMake(0, 0, frame.size.width, 39))
        nameLabel.withFontHeleticaMedium(15).withTextColor(UIColor.defaultBlack()).withText("Brand")
        nameLabel.textAlignment = .Left
        addSubview(nameLabel)
        
        let viewAllLabel = UILabel(frame: CGRectMake(0, 0, frame.size.width, 39))
        viewAllLabel.withFontHeleticaMedium(15).withTextColor(UIColor.grayColor()).withText("View all")
        viewAllLabel.textAlignment = .Right
        addSubview(viewAllLabel)
        
        viewAllLabel.addTapGestureTarget(self, action: #selector(BrandFilterViewContainer.showBrandList))
        
        addImagesAndResetFrame()
    }
    
    func addImagesAndResetFrame() {
        
        for view in subviews {
            if view is UIImageView {
                view.removeFromSuperview()
            }
        }
        
        var list = recommandList
        if selectedBrand != nil {
            var selectedBrandInTheRecommandList = false
            for b in recommandList {
                if b.id == selectedBrand?.id {
                    selectedBrandInTheRecommandList = true
                    break
                }
            }
            if !selectedBrandInTheRecommandList {
                list.insert(selectedBrand!, atIndex: 0)
                if list.count > 8 {
                    list.removeLast()
                }
            }
        }
        
        let width = (frame.size.width - 5 * 3) / 4
        
        var oX : CGFloat = 0
        var oY : CGFloat = 42
        
        var lastV : UIView?
        for index in 0 ..< list.count{
            let brand = list[index]
            let imageV = UIImageView(frame: CGRectMake(oX, oY, width, 30))
            lastV = imageV
            imageV.userInteractionEnabled = true
            imageV.addTapGestureTarget(self, action: #selector(BrandFilterViewContainer.tapImage(_:)))
            imageV.tag = index
            imageV.layer.borderWidth = 0.5
            imageV.layer.borderColor = UIColor(fromHexString: "cecece").CGColor
            imageV.contentMode = .ScaleAspectFit

            addSubview(imageV)
            if let url = NSURL(string: brand.imageUrl){
                imageV.sd_setImageWithURL(url)
            }
            oX += width + 5
            if oX > frame.size.width{
                oX = 0
                oY += imageV.frame.size.height + 5
            }
            if brand.id == selectedBrand?.id {
                refineView.addIconToSelectedView(imageV)
                imageV.layer.borderColor = UIColor(fromHexString: "ff6854").CGColor
            }
        }
        if lastV != nil{
            self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, lastV!.frame.maxY)
        }
        
        currentList = list
    }
    
    func showBrandList(){
        if brandWindow == nil{
            let b = BrandListWindow(frame: UIScreen.mainScreen().bounds)
            brandWindow = b
            brandWindow?.setContentSelector(self, sel: #selector(BrandFilterViewContainer.didSelectBrand(_:)))
        }
        brandWindow!.showAnimation()
    }
    
    func tapImage(reg : UITapGestureRecognizer) {
        if let tag = reg.view?.tag {
            let brand = currentList[tag]
            if brand.id == selectedBrand?.id {
                selectedBrand = nil
            }else {
                selectedBrand = brand
            }
            addImagesAndResetFrame()
        }
//        refineView.setupViewHeader()
        refineView.delegate?.refineViewChanged?(refineView)
    }
    
    func didSelectBrand(brand : BrandInfo){
        brandWindow?.hideAnimation()
        selectedBrand = brand
        addImagesAndResetFrame()
//        refineView.setupViewHeader()
        refineView.delegate?.refineViewChanged?(refineView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PriceFilterViewContainer : View, DJRangeSilderViewDelegate {
    unowned var refineView : FindClothRefineView
    var rangeSilderView : DJRangeSilderView?
    let priceLabel = UILabel()
    var lowerPrice: Int = 0
    var higherPrice: Int = 0
    
    init(frame: CGRect, refineView : FindClothRefineView) {
        self.refineView = refineView
        super.init(frame: frame)
        
        let priceContainerView: UIView = UIView()
        priceContainerView.backgroundColor = UIColor.whiteColor()
        addSubview(priceContainerView)
        priceContainerView.frame = CGRectMake(0, 0, self.frame.size.width, 97)
        let priceLable: UILabel = UILabel(frame: CGRectMake(0, 18, 150, 10))
        priceLable.withFontHeleticaMedium(15).withTextColor(UIColor.defaultBlack()).withText(String(format: "Price (S$)", ""))
        priceLable.textAlignment = .Left
        priceContainerView.addSubview(priceLable)
        priceLable.sizeToFit()
        priceContainerView.addSubview(self.priceLabel)
        self.priceLabel.textAlignment = .Left
        self.priceLabel.font = DJFont.contentFontOfSize(14)
        self.priceLabel.textColor = DJCommonStyle.ColorRed
        self.priceLabelSetFrame(DJStringUtil.localize("All Prices", comment: ""))
        
        self.rangeSilderView = DJRangeSilderView(frame: CGRectMake(0, CGRectGetMaxY(priceLable.frame) + 10, priceContainerView.frame.size.width, priceContainerView.frame.size.height - CGRectGetMaxY(priceLable.frame)))
        self.rangeSilderView?.rangeValues = [0, 30, 50, 80, 120, 200]
        addSubview(rangeSilderView!)
        rangeSilderView?.delegate = self
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, rangeSilderView!.frame.maxY)
    }
    
    func priceLabelSetFrame(text: String) {
        self.priceLabel.text = text
        self.priceLabel.sizeToFit()
        self.priceLabel.frame = CGRectMake(frame.size.width - self.priceLabel.frame.size.width, 17, self.priceLabel.frame.size.width, self.priceLabel.frame.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rangeValueDidChanged(rangeSliderView: DJRangeSilderView, lowerValue: CGFloat, higherValue: CGFloat) {
        self.lowerPrice = Int(lowerValue)
        self.higherPrice = Int(higherValue)
        self.priceLabelShouldChange()
        refineView.delegate?.refineViewChanged?(refineView)
    }
    
    func priceLabelShouldChange() {
        var rangeValues: [CGFloat] = self.rangeSilderView!.rangeValues
        if rangeValues.count < 2 {
            return
        }
        var labelText = ""
        if self.lowerPrice == (Int(rangeValues[0])) && self.higherPrice == 0 {
            labelText = DJStringUtil.localize("ALL PRICES", comment: "")
        }
        else if self.higherPrice == 0 {
            labelText = "Above S$\(Int(self.lowerPrice))"
        }
        else if self.lowerPrice == (Int(rangeValues[0])) {
            labelText = "Under S$\(Int(self.higherPrice))"
        }
        else {
            labelText = "S$\(Int(self.lowerPrice)) - S$\(Int(self.higherPrice))"
        }
        
        self.priceLabelSetFrame(labelText)
    }
    
    func setPrice(lowerPrice : CGFloat, higherPrice : CGFloat) {
        rangeSilderView?.startPointsSlider(lowerPrice, rightValue: higherPrice)
        self.lowerPrice = Int(lowerPrice)
        self.higherPrice = Int(higherPrice)
        priceLabelShouldChange()
    }
    
    func reset() {
        self.lowerPrice = Int(rangeSilderView!.rangeValues.first!)
        self.higherPrice = 0
        priceLabelShouldChange()
        rangeSilderView?.resetSlider()
       // refineView.delegate?.refineViewChanged?(refineView)
    }
}

class FindClothRefineView: UIView {
    var category : ClothCategory
    var subCategoryId : String?
    var originSubCategoryId : String?
    
    weak var delegate : FindClothRefineViewDelegate?
    var selectedFilters = [Filter]()
    
    private var tableView : UITableView?
    private var allBtns = [RefineFilterBtn]()
    private let funcView = UIView()
    
    private var filterConditions = [FilterCondition]()
    private var filterConditionIds : [String]?
    
    private let viewHeaderHeight : CGFloat = 49
    private var rowViews = [Int : UIView]()
    private var sectionViews = [Int : UIView]()
    private var arrowBtns = [Int : ArrowButton]()
    private var containerView : UIView?
    private var expandSections = [Int : Bool]()
    
    var templateId : String?
    
    private var headerView = UIView()
    
    private var colorViewContainer : ColorFilterViewContainer?
    private var subCategoryViewContainer : SubCategoryViewContainer?
    var priceViewContainer : PriceFilterViewContainer?
    var brandViewContainer : BrandFilterViewContainer?
    
    private var priceFilterEnable = false
    private var brandFilterEnable = false
    
    convenience init(frame: CGRect, category :ClothCategory){
        self.init(frame : frame, category: category, priceFilterEnable: false, brandFilterEnable: false)
    }
    
    private var doneBtn : DJButton!
    
    init(frame: CGRect, category :ClothCategory, priceFilterEnable : Bool, brandFilterEnable : Bool){
        self.category = category
        self.priceFilterEnable = priceFilterEnable
        self.brandFilterEnable = brandFilterEnable
        super.init(frame: frame)
        
        containerView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.height))
        containerView?.backgroundColor = UIColor.whiteColor()
        addSubview(containerView!)
        tableView = UITableView(frame: CGRectMake(23, 0, containerView!.frame.size.width - 46, frame.height - 60))
        tableView!.addSubview(headerView)
        setupViewHeader()
        tableView!.delegate = self
        tableView!.separatorStyle = .None
        tableView!.dataSource = self
        tableView!.showsVerticalScrollIndicator = false
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        containerView!.addSubview(tableView!)
        containerView!.addSubview(funcView)
        containerView?.userInteractionEnabled = true
        containerView!.addTapGestureTarget(self, action: #selector(FindClothRefineView.doNoting))
        
        funcView.frame = CGRectMake(23, self.frame.height - 60, containerView!.frame.size.width - 46, 60)
        funcView.backgroundColor = UIColor.whiteColor()
        
        let divider = UIView(frame: CGRectMake(0, self.frame.height - 60, frame.size.width, 1)).withBackgroundColor(DJCommonStyle.DividerColor)
        containerView!.addSubview(divider)
        
        doneBtn = DJButton(frame: CGRectMake(0, 12, funcView.frame.size.width, 36))
        doneBtn.setWhiteTitle()
        doneBtn.withTitle("DONE")
        doneBtn.addTarget(self, action: #selector(FindClothRefineView.doneBtnDidTap), forControlEvents: UIControlEvents.TouchUpInside)
        funcView.addSubview(doneBtn)
    }
    
    func showItemNumber(number : Int){
        if number <= 0 {
            doneBtn.enabled = false
            doneBtn.withTitle("No Result Found")
            doneBtn.setBackgroundColor(DJCommonStyle.ColorCE, forState: .Normal)
        }else{
            doneBtn.enabled = true
            doneBtn.withTitle("Show All \(number) Items")
            doneBtn.setBackgroundColor(UIColor.blackColor(), forState: .Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func doNoting(){
    }
    
    func resetHeaderViewHeight(height : CGFloat) {
        tableView?.contentInset = UIEdgeInsetsMake(height, 0, 0, 0)
        headerView.frame = CGRectMake(0, -height, frame.width - 46, height)
        tableView?.contentOffset = CGPointMake(0, -height)
    }
    
    func resetFilterBtns(){
        for btn in allBtns {
            btn.setSelectedIcon(false)
        }
        if selectedFilters.count == 0 {
            return
        }
        for sF in selectedFilters{
            for btn in allBtns {
                if let tmpF = btn.filter {
                    if tmpF.id == sF.id {
                        btn.setSelectedIcon(true)
                    }
                }
            }
        }
    }
    
    func refreshLayout() {
        subCategoryViewContainer?.reset()
        brandViewContainer?.addImagesAndResetFrame()
        reloadFilters()
    }
    
    func reloadFilters() {
        if let cid = subCategoryId {
            for c in category.subCategories {
                if c.categoryId == cid {
                    filterConditionIds = c.filterConditions
                    filterConditions = getFilterCondition()
                    
                }
            }
        }
        allBtns.removeAll()
        rowViews.removeAll()
        sectionViews.removeAll()
        arrowBtns.removeAll()
        //        expandSections.removeAll()
        //        selectedFilters.removeAll()
        tableView?.reloadData()
    }
    
    func resetSelectedFiltersOrigin(newfilters : [Filter]){
        selectedFilters = newfilters
        
        resetFilterBtns()
        for cd in filterConditions{
            expandSections[filterConditions.indexOf(cd)!] = false
        }
        
        for sf in selectedFilters{
            var index = 0
            TheWhile : while index < filterConditions.count {
                for sfv in filterConditions[index].values {
                    if sfv.id == sf.id {
                        expandSections[index] = true
                        break TheWhile
                    }
                }
                index += 1
            }
        }
        
        tableView!.reloadData()
    }
    
    func checkInSelected(filter : Filter) -> Bool{
        for sfr in selectedFilters {
            if sfr.id == filter.id {
                return true
            }
        }
        return false
    }
    
    func doneBtnDidTap(){
        delegate?.refineViewDone(self)
    }
    
    func resetBtnDidTap(){
        resetSelectedFilters([Filter]())
        
        subCategoryId = originSubCategoryId
        
        subCategoryViewContainer?.reset()
        reloadFilters()
        
        priceViewContainer?.reset()
        brandViewContainer?.selectedBrand = nil
        brandViewContainer?.addImagesAndResetFrame()
        delegate?.refineViewChanged?(self)
    }
    
    func containerViewHiddenFrame() -> CGRect{
        return CGRectMake(0, -containerView!.frame.size.height, containerView!.frame.size.width, containerView!.frame.size.height)
    }
    
    func showAnimation(){
        self.hidden = false
        
        let tmp = containerView!.frame
        self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0)
        containerView!.frame = containerViewHiddenFrame()
        UIView.animateWithDuration(0.3, animations: {
            self.containerView!.frame = tmp
            self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.75)
            }, completion:  nil)
    }
    func hideAnimation(){
        let tmp = containerView!.frame
        let ret = containerViewHiddenFrame()
        
        UIView.animateWithDuration(0.2, animations: {
            self.containerView!.frame = ret
            self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0)
            }, completion: { (completion : Bool) -> Void in
                self.containerView!.frame = tmp
                self.hidden = true
        })
    }
    
    func backgroundViewDidTapped(){
        self.hideAnimation()
    }
    
    func setupViewHeader() {
        var maxY = 0 as CGFloat
//        if category.categoryId != "0" {
            if subCategoryViewContainer == nil {
                subCategoryViewContainer = SubCategoryViewContainer(frame: CGRectMake(0, 0, self.frame.size.width - 46, 0), refineView: self)
            }else {
                subCategoryViewContainer?.frame = CGRectMake(0, 0, subCategoryViewContainer!.frame.width, subCategoryViewContainer!.frame.height)
            }
            headerView.addSubview(subCategoryViewContainer!)
            maxY = subCategoryViewContainer!.frame.maxY
//        }
    
        if colorViewContainer == nil {
            colorViewContainer = ColorFilterViewContainer(frame: CGRectMake(0, maxY, self.frame.size.width - 46, 50), refineView: self)
        }else {
            colorViewContainer?.frame = CGRectMake(0, maxY, colorViewContainer!.frame.width, colorViewContainer!.frame.height)
        }
        headerView.addSubview(colorViewContainer!)
        maxY = colorViewContainer!.frame.maxY + 5
        
        if brandFilterEnable {
            if brandViewContainer == nil {
                brandViewContainer = BrandFilterViewContainer(frame: CGRectMake(0, maxY, self.frame.size.width - 46, 50), refineView: self)
            }else {
                brandViewContainer?.frame = CGRectMake(0, maxY, brandViewContainer!.frame.width, brandViewContainer!.frame.height)
            }
            headerView.addSubview(brandViewContainer!)
            maxY = brandViewContainer!.frame.maxY
        }
        
        if priceFilterEnable {
            if priceViewContainer == nil {
                priceViewContainer = PriceFilterViewContainer(frame: CGRectMake(0, maxY, self.frame.size.width - 46, 50), refineView: self)
            }else {
                priceViewContainer?.frame = CGRectMake(0, maxY, priceViewContainer!.frame.width, priceViewContainer!.frame.height)
            }
            headerView.addSubview(priceViewContainer!)
            maxY = priceViewContainer!.frame.maxY
        }
        
        resetHeaderViewHeight(maxY)
    }
    
    func filterBtnDidTap(btn : RefineFilterBtn){
        let xtmp = btn.filter
        if  xtmp == nil {
            return
        }
        
        if checkInSelected(xtmp!) {
            removeFilterInSelection(xtmp!)
        }else{
            for sfr in selectedFilters {
                if sfr.condtionId == xtmp!.condtionId {
                    selectedFilters.removeAtIndex(selectedFilters.indexOf(sfr)!)
                }
            }
            selectedFilters.append(xtmp!)
        }
        delegate?.refineViewChanged?(self)
        resetFilterBtns()
    }
    
    func addIconToSelectedView(view : View) {
        let image = UIImage(named: "FilterSelectedIcon")!
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(view.frame.width - image.size.width, view.frame.height
            - image.size.height, image.size.width, image.size.height)
        imageView.tag = Int(tagSelectedIcon)
        view.addSubview(imageView)
    }
    
    func resetSelectedFilters(newfilters : [Filter]){
        resetSelectedFiltersOrigin(newfilters)
        colorViewContainer?.resetColorFilterAndBtns()
    }
    
    func getFilterCondition() -> [FilterCondition]{
        var result = [FilterCondition]()
        if filterConditionIds == nil{
            return result
        }
        
        for id in filterConditionIds! {
            if let cd = ConfigDataContainer.sharedInstance.getFilterConditionById(id){
                result.append(cd)
            }
        }
        return result
    }
    
    func viewForFakeHeaderInSection(section: Int) -> UIView? {
        if let tmp = sectionViews[section] {
            return tmp
        }else{
            let cond = filterConditions[section]
            let headerView = UIView(frame: CGRectMake(0, 0, tableView!.frame.size.width, viewHeaderHeight))
            headerView.backgroundColor = UIColor.whiteColor()
            
            
            let nameLabel = UILabel(frame: CGRectMake(0, 0, tableView!.frame.size.width - 30, viewHeaderHeight))
            nameLabel.withFontHeleticaMedium(15).withTextColor(UIColor.defaultBlack()).withText(cond.name)
            nameLabel.textAlignment = .Left
            headerView.addSubview(nameLabel)
            
            let arrowBtn = ArrowButton(frame: CGRectMake(tableView!.frame.size.width - 22, viewHeaderHeight / 2 - 19 / 2, 22, 19))
            headerView.addSubview(arrowBtn)
            arrowBtns[section] = arrowBtn
            
            let btn = UIButton(frame: headerView.bounds)
            btn.property = NSNumber(integer: section)
            headerView.addSubview(btn)
            btn.addTarget(self, action: #selector(FindClothRefineView.arrowBtnDidClicked(_:)), forControlEvents: .TouchUpInside)
            headerView.addSubview(btn)
            
            let border = UIView(frame: CGRectMake(0, viewHeaderHeight - 1, tableView!.frame.size.width, 1))
            border.backgroundColor = UIColor(fromHexString: "eaeaea")
            headerView.addSubview(border)
            sectionViews[section] = headerView
            return headerView
        }
    }
}

extension FindClothRefineView  : UITableViewDataSource, UITableViewDelegate {
    func arrowBtnDidClicked(btn : UIButton){
        let secNS = btn.property as! NSNumber
        let section = secNS.integerValue
        
        if inExpanded(section) {
            self.collapseSection(section)
        }else{
            self.expandSection(section)
        }
    }
    
    func expandSection(section : NSInteger) {
        if section < 0 || section >= self.tableView!.numberOfSections {
            return
        }
        
        let cnt = self.tableView!.numberOfRowsInSection(section)
        if cnt == 1 {
            expandSections[section] = true
            if let tBtn = arrowBtns[section] {
                tBtn.setIndicator(true)
            }
            
            self.tableView!.beginUpdates()
            let path = NSIndexPath(forRow: 1, inSection: section)
            self.tableView!.insertRowsAtIndexPaths([path], withRowAnimation: .Top)
            self.tableView!.endUpdates()
            if section == self.tableView!.numberOfSections - 1 {
                let offSetY = self.tableView!.contentOffset.y + tableView(self.tableView!, heightForRowAtIndexPath: path)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    self.tableView!.setContentOffset(CGPointMake(0, offSetY), animated: true)
                }
            }
        }
    }
    
    func collapseSection(section : NSInteger) {
        if section < 0 || section >= self.tableView!.numberOfSections {
            return
        }
        
        let cnt = self.tableView!.numberOfRowsInSection(section)
        if cnt == 2 {
            if let tBtn = arrowBtns[section] {
                tBtn.setIndicator(false)
            }
            expandSections[section] = false
            self.tableView!.beginUpdates()
            let path = NSIndexPath(forRow: 1, inSection: section)
            self.tableView!.deleteRowsAtIndexPaths([path], withRowAnimation: .Top)
            self.tableView!.endUpdates()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inExpanded(section) {
            if let tBtn = arrowBtns[section] {
                tBtn.setIndicator(true)
            }
            return 1 + 1
        }else{
            if let tBtn = arrowBtns[section] {
                tBtn.setIndicator(false)
            }
            return 0 + 1
        }
    }
    
    func inExpanded(section : Int) -> Bool{
        if expandSections[section] != nil{
            return expandSections[section]!
        }else{
            return false
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return subCategoryId == nil ? 0 : filterConditions.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return viewHeaderHeight
        }
        if let view = rowViews[indexPath.section] {
            return view.frame.size.height
        }else{
            let view = buildRowView(indexPath.section)
            rowViews[indexPath.section] = view
            return view.frame.size.height
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if rowViews[indexPath.section] == nil {
            rowViews[indexPath.section] = buildRowView(indexPath.section)
        }
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")
            cell?.removeAllSubViews()
            if let hv = viewForFakeHeaderInSection(indexPath.section){
                cell?.addSubview(hv)
            }
            return cell!
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")
            cell?.removeAllSubViews()
            cell?.addSubview(rowViews[indexPath.section]!)
            return cell!
        }
    }
    
    func buildRowView(section : Int) -> UIView{
        let containerView = UIView()
        
        if filterConditions.count == 0 {
            return containerView
        }
        containerView.backgroundColor = UIColor.whiteColor()
        var oX : CGFloat = 0
        var oY : CGFloat = 15
        let btnWidth = (tableView!.frame.size.width - 20) / 3
        let btnHeight : CGFloat = 28
        
        let filters = filterConditions[section].values
        for filter in filters {
            let filterBtn = RefineFilterBtn(frame: CGRectMake(oX, oY, btnWidth, btnHeight))
            filterBtn.withTitle(filter.name)
            filterBtn.filter = filter
            filterBtn.titleLabel?.numberOfLines = 1
            filterBtn.sizeToFit()
            if oX + filterBtn.frame.size.width + 32 > tableView!.frame.size.width && oX > 0{
                oX = 0
                oY += btnHeight + 14
            }
            filterBtn.contentHorizontalAlignment = .Right
            filterBtn.frame = CGRectMake(oX, oY, min(filterBtn.frame.size.width + 32, tableView!.frame.size.width), btnHeight)
            filterBtn.addTarget(self, action: #selector(FindClothRefineView.filterBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            containerView.addSubview(filterBtn)
            allBtns.append(filterBtn)
            if filterInSelection(filter){
                filterBtn.setSelectedIcon(true)
            }
            oX += filterBtn.frame.size.width + 10
            if oX > tableView!.frame.size.width && filters.indexOf(filter) < filters.count - 1{
                oX = 0
                oY += btnHeight + 15
            }
        }
        containerView.frame = CGRectMake(0, 0, tableView!.frame.size.width, oY + btnHeight + 15)
        let border = UIView(frame: CGRectMake(0, containerView.frame.size.height - 1, containerView.frame.size.width, 1))
        border.backgroundColor = UIColor(fromHexString: "eaeaea")
        containerView.addSubview(border)
        
        return containerView
    }
    
    func filterInSelection(filter : Filter) -> Bool{
        for fr in selectedFilters {
            if fr.id == filter.id {
                return true
            }
        }
        return false
    }
    
    func removeFilterInSelection(filter : Filter){
        var index = 0
        for tmFilter in selectedFilters {
            if tmFilter.id == filter.id {
                selectedFilters.removeAtIndex(index)
                break
            }
            index += 1
        }
    }
}
