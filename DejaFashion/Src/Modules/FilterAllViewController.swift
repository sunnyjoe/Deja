//
//  FilterAllViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 26/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class FilterableConditions: NSObject, NSCopying {
    var categoryId : String?
    var subCategory : ClothSubCategory?
    var lowPrice : Int = 0
    var highPrice : Int = 0
    var colorFilter : ColorFilter?
    var brand : BrandInfo?
    var filters : [Filter]?//cuting related filters
    
    
    var keyWords : String?
    var isNewArrival = false
    var position : (longitude : Double, latitude : Double)?
    var bodyIssues : String?
    var occasion : String?
    var onSale = false
    
    var photoMark : String?

    func copyWithZone(zone: NSZone) -> AnyObject {
        let one = FilterableConditions()
        one.categoryId = categoryId
        one.subCategory = subCategory?.copyWithZone(zone) as? ClothSubCategory
        one.lowPrice = lowPrice
        one.highPrice = highPrice
        one.colorFilter = colorFilter?.copyWithZone(zone) as? ColorFilter
        one.brand = brand?.copyWithZone(zone) as? BrandInfo
        
        if let tmp = filters {
            var resultFiltes = [Filter]()
            for onef in tmp {
                let f = onef.copyWithZone(zone) as! Filter
                resultFiltes.append(f)
            }
            one.filters = resultFiltes
        }
        
        one.keyWords = keyWords
        one.isNewArrival = isNewArrival
        one.position = position
        one.bodyIssues = bodyIssues
        one.occasion = occasion
        one.onSale = onSale
        one.photoMark = photoMark
        
        return one
    }

}

protocol FilterAllViewControllerDelegate : NSObjectProtocol{
    func filterAllViewControllerDone(filterAllViewController : FilterAllViewController, filterVCCondition : FilterableConditions)
}

class FilterAllViewController: DJBasicViewController, MONetTaskDelegate {
    private var filterInfo : FilterableConditions!
    private var getFilterNetTask = DynamicGetFiltersNetTask()
    
    private var brandLabel : UILabel?
    private var colorLabel : UILabel?
    private var priceLabel : UILabel?
    private var categoryLabel : UILabel?
    private var cuttingLabels = [UILabel]()
    
    private var cuttingViews = [UIView]()
    
    private var dyBrandIds = [String]()
    private var dyColorIds = [String]()
    private var dySubCategoryIds = [String]()
    private var dyFilterCondtions = [String : [String]]()
    private var dyLowerPrice = 0
    private var dyHighPrice = 0
    private var doneBtn = DJButton()
    
    private let contentScrollView = UIScrollView()
    
    weak var delegate : FilterAllViewControllerDelegate?
    
    init(filterInfo : FilterableConditions) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.filterInfo = filterInfo
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentScrollView)
        setCancelLeftBarItem()
        addRightResetButton()
        
        brandLabel = buildCell(DJStringUtil.localize("Brand", comment:""), sel : #selector(brandDidClicked), oY : 0)
        colorLabel = buildCell(DJStringUtil.localize("Color", comment:""), sel : #selector(colorDidClicked), oY : 50)
        priceLabel = buildCell(DJStringUtil.localize("Price", comment:""), sel : #selector(priceDidClicked), oY : 100)
        categoryLabel = buildCell(DJStringUtil.localize("Category", comment:""), sel : #selector(categoryDidClicked), oY : 150)
        
        contentScrollView.contentSize = CGSizeMake(view.frame.size.width, 200)
        
        doneBtn = DJButton()
        view.addSubview(doneBtn)
        constrain(doneBtn) { bottomView in
            bottomView.bottom == bottomView.superview!.bottom - 40
            bottomView.height == 36
            bottomView.left == bottomView.superview!.left + 23
            bottomView.right == bottomView.superview!.right - 23
        }
        doneBtn.setWhiteTitle()
        doneBtn.withTitle(DJStringUtil.localize("DONE", comment:""))
        doneBtn.addTarget(self, action: #selector(doneBtnDidTap), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        resetLabel()
        sendGetFilterNetTask()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        contentScrollView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - 76 - 15)
    }
    
    func doneBtnDidTap(){
        delegate?.filterAllViewControllerDone(self, filterVCCondition: filterInfo)
    }
    
    func showItemNumber(number : Int){
        if number <= 0 {
            doneBtn.enabled = false
            doneBtn.withTitle(DJStringUtil.localize("No Result Found", comment:""))
            doneBtn.setBackgroundColor(DJCommonStyle.ColorCE, forState: .Normal)
        }else{
            doneBtn.enabled = true
            doneBtn.withTitle("Show All \(number) Items")
            doneBtn.setBackgroundColor(UIColor.blackColor(), forState: .Normal)
        }
    }
    
    
    func cuttingLabelDidClicked(tapg : UITapGestureRecognizer){
        guard let theLabel = tapg.view else{
            return
        }
        
        guard let cond = theLabel.property as? FilterCondition else{
            return
        }
        
        if let ids = dyFilterCondtions[cond.id] {
            var selected : String?
            if let tmp = filterInfo.filters{
                for one in tmp{
                    if one.condtionId != nil && one.condtionId == cond.id{
                        selected = one.id
                    }
                }
            }
            let subVC = FilterSubsViewController(filterCondtion: cond, filterIds: ids, selectedId: selected)
            subVC.delegate = self
            navigationController?.pushViewController(subVC, animated: true)
        }
    }
    
    func brandDidClicked(){
        var selected : String?
        if let tmp = filterInfo.brand{
            selected = tmp.id
        }
        let subVC = FilterSubsViewController(filterType: .Brand, filterIds: dyBrandIds, selectedId: selected)
        subVC.delegate = self
        navigationController?.pushViewController(subVC, animated: true)
    }
    
    func colorDidClicked(){
        var selected : String?
        if let tmp = filterInfo.colorFilter{
            selected = tmp.id
        }
        let subVC = FilterSubsViewController(filterType: .Color, filterIds: dyColorIds, selectedId: selected)
        subVC.delegate = self
        navigationController?.pushViewController(subVC, animated: true)
    }
    
    func priceDidClicked(){
        let subVC = FilterSubsViewController(lowPrice: dyLowerPrice, highPrice: dyHighPrice, selectedLowPrice: filterInfo.lowPrice, selectedHighPrice: filterInfo.highPrice)
        subVC.delegate = self
        navigationController?.pushViewController(subVC, animated: true)
    }
    
    func categoryDidClicked(){
        var selected : String?
        if let tmp = filterInfo.subCategory{
            selected = tmp.categoryId
        }
        let subVC = FilterSubsViewController(filterType: .Category, filterIds: dySubCategoryIds, selectedId: selected)
        subVC.delegate = self
        navigationController?.pushViewController(subVC, animated: true)
    }
    
    func resetFilter() {
        filterInfo.subCategory = nil
        filterInfo.lowPrice = 0
        filterInfo.highPrice = 0
        filterInfo.colorFilter = nil
        filterInfo.brand = nil
        filterInfo.filters = nil
        
        rebuildCuttingLabel()
        resetLabel()
        sendGetFilterNetTask()
    }
    
    func sendGetFilterNetTask(){
        MONetTaskQueue.instance().cancelTask(getFilterNetTask)
        
        getFilterNetTask = DynamicGetFiltersNetTask()
        getFilterNetTask.extractFilterCondition(filterInfo)
        
        MONetTaskQueue.instance().addTask(getFilterNetTask)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: getFilterNetTask.uri())
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func netTaskDidEnd(task: MONetTask!) {
      
        if task == getFilterNetTask{
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
            
            dyBrandIds = getFilterNetTask.retBrandIds
            dyLowerPrice = getFilterNetTask.retMinPrice
            dyHighPrice = getFilterNetTask.retMaxPrice
            dyFilterCondtions = getFilterNetTask.retCuttingIds
            dyColorIds = getFilterNetTask.retColorIds
            dySubCategoryIds = getFilterNetTask.retSubCategoryIds
            
            if let change = getFilterNetTask.retSelectedBrandId {
                filterInfo.brand = ConfigDataContainer.sharedInstance.getBrandInfoById(change)
            }else{
                filterInfo.brand = nil
            }
            if let change = getFilterNetTask.retSelectedColorId {
                filterInfo.colorFilter = ConfigDataContainer.sharedInstance.getColorFilterById(change)
            }else{
                filterInfo.colorFilter = nil
            }
            
            if let change = getFilterNetTask.retSelectedMinPrice {
                filterInfo.lowPrice = change
            }
            if let change = getFilterNetTask.retSelectedMaxPrice {
                filterInfo.highPrice = change
            }
            
            if let change = getFilterNetTask.retSelectedSubCategoryId {
                filterInfo.subCategory = ConfigDataContainer.sharedInstance.getConfigSubCategoryById(change)
            }else{
                filterInfo.subCategory = nil
            }
            
            filterInfo.filters = ConfigDataContainer.sharedInstance.getFiltersByIds(getFilterNetTask.retSelectedCuttingIds)
            
            showItemNumber(getFilterNetTask.retTotalItems)
            rebuildCuttingLabel()
            resetLabel()
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == getFilterNetTask{
           MBProgressHUD.hideAllHUDsForView(view, animated: true)
        }
    }
    
}

extension FilterAllViewController: FilterSubsViewControllerDelegate{
    func filterSubsViewControllerDidSelectBrand(filterSubsViewController: FilterSubsViewController, brand: BrandInfo?) {
        filterInfo.brand = brand
        filterValueDidFinishSelection(filterSubsViewController)
    }
    
    func filterSubsViewControllerDidSelectColor(filterSubsViewController : FilterSubsViewController, color : ColorFilter?){
        filterInfo.colorFilter = color
        filterValueDidFinishSelection(filterSubsViewController)
    }
    
    func filterSubsViewControllerDidSelectPrice(filterSubsViewController : FilterSubsViewController, lowPrice : Int, highPrice : Int){
        filterInfo.lowPrice = lowPrice
        filterInfo.highPrice = highPrice
        filterValueDidFinishSelection(filterSubsViewController)
    }
    
    func filterSubsViewControllerDidSelectSubCategory(filterSubsViewController : FilterSubsViewController, subCate : ClothSubCategory?){
        filterInfo.subCategory = subCate
        filterValueDidFinishSelection(filterSubsViewController)
    }
    
    func filterSubsViewControllerDidSelectCuttingFilter(filterSubsViewController : FilterSubsViewController, filter : Filter?, filterCondtion: FilterCondition){
        if filterInfo.filters != nil{
            for (index, one) in filterInfo.filters!.enumerate() {
                if one.condtionId == filterCondtion.id {
                    filterInfo.filters!.removeAtIndex(index)
                    break
                }
            }
        }
        
        if let f = filter {
            if filterInfo.filters == nil {
                filterInfo.filters = [f]
            }else{
                filterInfo.filters!.append(f)
            }
        }
        
        filterValueDidFinishSelection(filterSubsViewController)
    }
    
    func filterValueDidFinishSelection(subVC : FilterSubsViewController){
        navigationController?.popViewControllerAnimated(true)
        resetLabel()
        sendGetFilterNetTask()
    }
}

extension FilterAllViewController{
    func resetLabel(){
        if let brand = filterInfo.brand{
            brandLabel?.withTextColor(UIColor.defaultRed()).withText("Brand: \(brand.name)")
        }else{
            brandLabel?.withTextColor(UIColor.defaultBlack()).withText(DJStringUtil.localize("Brand", comment:""))
        }
        
        if let color = filterInfo.colorFilter{
            colorLabel?.withTextColor(UIColor.defaultRed()).withText("Color: \(color.name)")
        }else{
            colorLabel?.withTextColor(UIColor.defaultBlack()).withText(DJStringUtil.localize("Color", comment:""))
        }
        
        if let subcate = filterInfo.subCategory{
            categoryLabel?.withTextColor(UIColor.defaultRed()).withText("Category: \(subcate.name)")
        }else{
            categoryLabel?.withTextColor(UIColor.defaultBlack()).withText(DJStringUtil.localize("Category", comment:""))
        }
        
        if filterInfo.lowPrice > 0 || filterInfo.highPrice > 0 {
            let str = PriceSelectView.getCombinedPriceString(filterInfo.lowPrice, highPrice: filterInfo.highPrice)
            priceLabel?.withTextColor(UIColor.defaultRed()).withText("Price: \(str)")
        }else{
            priceLabel?.withTextColor(UIColor.defaultBlack()).withText(DJStringUtil.localize("Price", comment:""))
        }
        
        for oneLabel in cuttingLabels{
            if let cond = oneLabel.property as? FilterCondition{
                oneLabel.withText("\(cond.name)").withTextColor(UIColor.defaultBlack())
            }
        }
        
        if let filters = filterInfo.filters{
            for onefilter in filters{
                if let label = getFilterCondtionLabel(onefilter){
                    if let cond = label.property as? FilterCondition{
                        label.withText("\(cond.name): \(onefilter.name)").withTextColor(UIColor.defaultRed())
                    }
                }
            }
        }
    }
    
    func getFilterCondtionLabel(filter : Filter) -> UILabel?{
        guard let cid = filter.condtionId else{
            return nil
        }
        
        for oneLabel in cuttingLabels{
            if let cond = oneLabel.property as? FilterCondition{
                if cond.id == cid{
                    return oneLabel
                }
            }
        }
        return nil
    }
    
    func rebuildCuttingLabel(){
        var filterCIds = Array(dyFilterCondtions.keys) as [String]
        filterCIds.sortInPlace({$0 > $1})

        for oneV in cuttingViews{
            oneV.removeFromSuperview()
        }
        cuttingViews.removeAll()
        cuttingLabels.removeAll()
        var offSet : CGFloat = 200
        
        for oneId in filterCIds{
            if let filterCondition = ConfigDataContainer.sharedInstance.getFilterConditionById(oneId){
                let oneLabel = buildCell(filterCondition.name, sel: #selector(cuttingLabelDidClicked(_:)), oY: offSet, isCutting: true)
                oneLabel.property = filterCondition
                cuttingLabels.append(oneLabel)
                offSet += 50
            }
        }
        
        contentScrollView.contentSize = CGSizeMake(view.frame.size.width, offSet)
    }
    
    func addRightResetButton() {
        let rightIcon = UIControl(frame: CGRectMake(0, 0, 60, 44))
        let rightLabel = DJButton(frame: CGRect(x: 10, y: 9, width: 60, height: 25)).withFontHeletica(15).withTitle(DJStringUtil.localize("Reset", comment: "")).withHighlightTitleColor(UIColor.gray81Color())
        rightIcon.addSubview(rightLabel)
        rightLabel.addTapGestureTarget(self, action: #selector(resetFilter))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightIcon)
    }
    
    func buildCell(name : String, sel : Selector, oY : CGFloat, isCutting : Bool = false) -> UILabel{
        let conV = UIView(frame : CGRectMake(0, oY, view.frame.size.width, 50))
        contentScrollView.addSubview(conV)
        if isCutting{
            cuttingViews.append(conV)
        }
        
        let label = UILabel(frame: CGRectMake(25, 0, conV.frame.size.width - 50, conV.frame.size.height))
        conV.addSubview(label)
        label.withText(name).withTextColor(UIColor.defaultBlack()).withFontHeleticaMedium(15)
        label.addTapGestureTarget(self, action: sel)
        
        let arrow = UIImageView(frame : CGRectMake(conV.frame.size.width - 23 - 6, conV.frame.size.height / 2 - 12 / 2, 6, 12))
        conV.addSubview(arrow)
        arrow.image = UIImage(named: "ArrowRight2")
        
        conV.addBorder()
        return label
    }
}

