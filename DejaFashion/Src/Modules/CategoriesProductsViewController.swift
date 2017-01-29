
//
//  CategoriesProductsViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 25/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class CategoryDataStates {
    var categoryId = ""
    var brandId : String?
    var subCategoryId : String?
    var products : [Clothes]?
    var filters : [Filter]?
    var lowerPrice : Int = 0
    var higherPrice : Int = 0
    
    var page : Int?
    var loadEnd = false
    var inLoading = false
    
    init(categoryId : String){
        self.categoryId = categoryId
    }
}

class CategoriesProductsViewController: DJBasicViewController, MONetTaskDelegate {
    private let titleIV = UIImageView()
    private var initBrandInfo : BrandInfo?
    private let refineView = RefineButton()
    private var refineAnimated = false
    
    var afterRefine = false
    var initialCategoryId = "0"
    
    lazy private var contentV: ScrollableProductCollectionView = {
        return ScrollableProductCollectionView(frame: self.view.bounds)
    }()
    
    private var categories = [String]()
    
    let cateNetTask = BrandGetCategoryNetTask()
    var filterTask = FindClothesNetTask()
    var categoryStates = [String : CategoryDataStates]()
    var currentCateId = ""
    
    init(brandIf : BrandInfo?) {
        super.init(nibName: nil, bundle: nil)
        
        self.initBrandInfo = brandIf
        if let tmp = brandIf{
            cateNetTask.brandId = tmp.id
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        if initBrandInfo != nil {
            if let url = NSURL(string: initBrandInfo!.imageUrl){
                titleIV.backgroundColor = UIColor.defaultBlack()
                titleIV.sd_setImageWithURL(url)
                titleIV.contentMode = .ScaleAspectFit
                titleIV.frame = CGRectMake(60, 27, view.frame.size.width - 60 * 2, 30)
            }
        }else{
            title = DJStringUtil.localize("All Brands", comment:"")
        }
        
        contentV.delegate = self
        view.addSubview(contentV)
        constrain(contentV) { contentV in
            contentV.top == contentV.superview!.top
            contentV.left == contentV.superview!.left
            contentV.right == contentV.superview!.right
            contentV.bottom == contentV.superview!.bottom
        }
        
        view.addSubview(refineView)
        self.refineView.frame = CGRectMake(self.view.frame.size.width, self.view.frame.size.height - 35 - 25, 110, 35)
        refineView.addTapGestureTarget(self, action: #selector(CategoriesProductsViewController.refineBtnDidTapped))
        

        MONetTaskQueue.instance().addTask(cateNetTask)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: cateNetTask.uri())
        MBProgressHUD.showHUDAddedTo(view, animated: true)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = false
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Float(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.navigationController?.view.addSubview(self.titleIV)
        }

        showHomeButton(true)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            titleIV.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if refineView.layer.animationKeys() != nil{
            return
        }
        if refineAnimated{
            return
        }
        refineAnimated = true
        
        self.refineView.frame = CGRectMake(self.view.frame.size.width, self.view.frame.size.height - 35 - 25, 110, 35)
        UIView.animateWithDuration(0.3, animations: {
            self.refineView.frame = CGRectMake(self.view.frame.size.width - 110 + 35 / 2, self.view.frame.size.height - 35 - 25, 110, 35)
        })
        
        
        DJStatisticsLogic.instance().addTraceLog(.Findresult_appear)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        titleIV.removeFromSuperview()
    }
    
    func refineBtnDidTapped(){
        let cateS = categoryStates[currentCateId]
        if cateS == nil{
            return
        }
        
        let fvc = FilterViewController()
        fvc.delegate = self
        fvc.brandFilterEnabled = (initBrandInfo == nil ? true : false)
        fvc.priceFilterEnabled = true
        if let tmp = cateS!.brandId{
            fvc.brandInfo = ConfigDataContainer.sharedInstance.getBrandInfoById(tmp)
        }
        resetRefineView(cateS!, filterVC: fvc)
        let task = FindClothesNetTask()
        fvc.fetchNetTask = task
        task.brandID = self.initBrandInfo?.id
        self.presentViewController(UINavigationController(rootViewController: fvc), animated: true, completion: nil)
        DJStatisticsLogic.instance().addTraceLog(.Findresult_Click_Refine)
    }
    
    func resetRefineView(cateS : CategoryDataStates, filterVC : FilterViewController){
        if let cate = ConfigDataContainer.sharedInstance.getConfigCategoryById(cateS.categoryId){
            filterVC.category = cate
        }
        
        filterVC.subCategoryId = cateS.subCategoryId
        if let filters = cateS.filters{
            filterVC.selectedFilters = filters
        }else{
            filterVC.selectedFilters = [Filter]()
        }
        filterVC.lowerPrice = cateS.lowerPrice
        filterVC.higherPrice = cateS.higherPrice
    }
    
    func sendFilterNetTask(cate : String, loading : Bool = true){
        let cateState = categoryStates[cate]!
        
        if cateState.loadEnd || cateState.inLoading{
            return
        }
        cateState.inLoading = true
        
        filterTask = FindClothesNetTask()
        if let page = cateState.page{
            filterTask.pageIndex = page + 1
            cateState.page! += 1
        }else{
            filterTask.pageIndex = 0
            cateState.page = 0
        }
        
        filterTask.brandID = cateState.brandId
        filterTask.categoryID = cate
        filterTask.subcategoryID = cateState.subCategoryId
        filterTask.filterIds = ConfigDataContainer.sharedInstance.getFilterIdsFromFilter(cateState.filters)
        filterTask.priceMin = cateState.lowerPrice
        filterTask.priceMax = cateState.higherPrice
        MONetTaskQueue.instance().addTask(filterTask)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: filterTask.uri())
        
        if loading{
            showOrHideLoadingIfNeed(true)
        }
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == cateNetTask{
            categories = cateNetTask.categoryIds
            if categories.count > 0{
                categories.insert("0", atIndex: 0)
                var cateNames = [String]()
                for oneId  in categories{
                    if let cate = ConfigDataContainer.sharedInstance.getConfigCategoryById(oneId){
                        cateNames.append(cate.name)
                    }
                    
                    let cateS = CategoryDataStates(categoryId: oneId)
                    categoryStates[oneId] = cateS
                    if initBrandInfo != nil{
                        cateS.brandId = initBrandInfo!.id
                    }
                }
                //                contentV.setCategory(cateNames)
                //                currentCateId = categories[0]
                //                sendFilterNetTask(currentCateId, loading : false)
                
                if let index = categories.indexOf(initialCategoryId)
                {
                    contentV.setCategory(cateNames, defaultCateIndex: index)
                    currentCateId = initialCategoryId
                }
                else
                {
                    contentV.setCategory(cateNames)
                    currentCateId = categories[0]
                }
                
                if currentCateId == "0" && cateNetTask.newItemsCount > 0
                {
//                    if let brandname = self.initBrandInfo?.name
//                    {
//                        let text =  NSString(format: DJStringUtil.localize("%d new arrivals have been added!", comment:""), cateNetTask.newItemsCount, brandname)
//                        if currentPromo == nil
//                        {
//                            UITips.showSlideDownTip(text as String, icon: UIImage(named:"Speaker"), duration: 3, offsetY: 45, insideParentView: self.view)
//                        }
//                    }
                }
                sendFilterNetTask(currentCateId, loading : false)
            }
        }else if task == filterTask{
            showOrHideLoadingIfNeed(false)
            
            let cateS = categoryStates[filterTask.categoryID!]
            if cateS == nil{
                return
            }
            cateS!.inLoading = false
            if filterTask.pageIndex == 0 || cateS!.products == nil{
                cateS!.products = [Clothes]()
            }
            cateS!.products!.appendContentsOf(filterTask.clothesList)
            cateS!.loadEnd = filterTask.ended
            
            var text : String?
            if self.afterRefine {
                self.afterRefine = false
                if filterTask.total > 0 {
                    text =  NSString(format: DJStringUtil.localize("%d items found.", comment:""), filterTask.total) as String
                    if let brandNumber = filterTask.fromBrandNumber{
                        if brandNumber > 1 {
                            text =  NSString(format: DJStringUtil.localize("%d items found from %d brands.", comment:""), filterTask.total, brandNumber) as String
                        }
                    }
                    // UITips.showSlideDownTip(text! as String, duration: 2, offsetY: 45, insideParentView: self.view)
                }
            }
            
            var index = 0
            while index < categories.count{
                if categories[index] == filterTask.categoryID{
                    let toTop = (filterTask.pageIndex == 0)
                    contentV.setCategoryScrollView(index, products: cateS!.products!, scrollToTop: toTop, headerInfo: text)
                    break
                }
                index += 1
            }
            
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == cateNetTask{
            showOrHideLoadingIfNeed(false)
        }else if task == filterTask{
            showOrHideLoadingIfNeed(false)
        }
    }
    
    func showOrHideLoadingIfNeed(show : Bool){
        if show{
            MBProgressHUD.showHUDAddedTo(view, animated: true)
        }else{
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension CategoriesProductsViewController :FilterViewControllerDelegate {
    func filterDone(controller: FilterViewController) {
        if let cateS = categoryStates[currentCateId]{
            cateS.page = nil
            cateS.loadEnd = false
            if let bif = controller.brandInfo{
                cateS.brandId = bif.id
                title = bif.name
            }else{
                if initBrandInfo == nil{
                    title = DJStringUtil.localize("All Brands", comment:"")
                    cateS.brandId = nil
                }
            }
            
            cateS.subCategoryId = controller.subCategoryId
            cateS.filters = controller.selectedFilters
            cateS.lowerPrice = controller.lowerPrice
            cateS.higherPrice = controller.higherPrice
            sendFilterNetTask(currentCateId)
            resetRefineStatus(cateS)
            self.afterRefine = true
        }
    }
    
    func resetRefineStatus(cateS : CategoryDataStates){
        if cateS.subCategoryId != nil || (cateS.filters != nil && cateS.filters!.count > 0) || (cateS.brandId != nil && initBrandInfo == nil) ||  (cateS.lowerPrice + cateS.higherPrice  > 0){
            refineView.selected = true
        }else{
            refineView.selected = false
        }
    }
}

extension CategoriesProductsViewController : ScrollableProductCollectionViewDelegate{
    func scrollableProductCollectionViewDidSelect(spcv: ScrollableProductCollectionView, product: Clothes) {
        pushClothDetailVC(product)
    }
    
    func scrollableProductCollectionViewDidScrollToIndex(spcv: ScrollableProductCollectionView, index: Int) {
        if !categories.indices.contains(index){
            return
        }
        
        currentCateId = categories[index]
        if let cateS = categoryStates[currentCateId]{
            resetRefineStatus(cateS)
            if cateS.products == nil{
                sendFilterNetTask(currentCateId)
            }
        }
        DJStatisticsLogic.instance().addTraceLog(.Brandspage_Click_Category)
        
    }
    
    func scrollableProductCollectionViewNeedLoadMore(spcv: ScrollableProductCollectionView, index : Int) {
        if !categories.indices.contains(index){
            return
        }
        
        sendFilterNetTask(categories[index])
    }
    
    func swichToCategory(cateId : String)
    {
        if let cateS = categoryStates[currentCateId]{
            resetRefineStatus(cateS)
            if cateS.products == nil{
                sendFilterNetTask(currentCateId)
            }
        }
    }
}
