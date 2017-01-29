//
//  ByPhotoResultViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 2/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ByPhotoResultViewController: DJBasicViewController, MONetTaskDelegate {
    private var searchResultEmptyView : ClothNotFindView?
    private let refineView = RefineButton()
    private let pdtCollectionView = ProductCollectionView()
    
    private var clothesList = [Clothes]()
    
    private var byPhotoMoreOrFilterNetTask = AddByPhotoMoreOrFilterNetTask()
    private var theInitNetTask : AddByPhotoInitNetTask!
    private var isLoadingMore = false
    
    private var selectedFilter = [Filter]()
    private var selectedSubCategoryId : String?
    private var lowerPrice : Int = 0
    private var higherPrice : Int = 0
    private var brandInfo : BrandInfo?
    
    init(clothes : [Clothes], initNetTask : AddByPhotoInitNetTask) {
        super.init(nibName: nil, bundle: nil)
        self.clothesList = clothes
        self.theInitNetTask = initNetTask
        byPhotoMoreOrFilterNetTask.pageIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = DJStringUtil.localize("Search Results", comment:"")
        
        let empty = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44 + 140))
        empty.addTapGestureTarget(self, action: #selector(goBack))
        view.addSubview(empty)
        
        refineView.addTapGestureTarget(self, action: #selector(filterBtnDidTap))
        pdtCollectionView.products = clothesList
        pdtCollectionView.delegate = self
        view.addSubview(pdtCollectionView)
        
        searchResultEmptyView = ClothNotFindView(frame: CGRectMake(0, 64, view.bounds.width, view.bounds.height - 64), text: DJStringUtil.localize("Sorry, no item found.", comment:""), showNotFoundButton : false)
        searchResultEmptyView?.hidden = true
        view.addSubview(searchResultEmptyView!)
        view.addSubview(refineView)
        
        reloadTheData(theInitNetTask.total)
        
        showHomeButton(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func filterBtnDidTap(){
        let filterViewController = FilterViewController()
        let category = ConfigDataContainer.sharedInstance.getCatogryByTemplateId(theInitNetTask.templateId!)
        filterViewController.category = category
        filterViewController.subCategoryId = selectedSubCategoryId
        filterViewController.selectedFilters = selectedFilter
        filterViewController.lowerPrice = lowerPrice
        filterViewController.higherPrice = higherPrice
        filterViewController.brandInfo = brandInfo
        filterViewController.priceFilterEnabled = true
        filterViewController.brandFilterEnabled = true
        filterViewController.delegate = self
        
        let task = AddByPhotoMoreOrFilterNetTask()
        task.mark = theInitNetTask.mark
        filterViewController.fetchNetTask = task
        
        self.presentViewController(UINavigationController(rootViewController: filterViewController), animated: true, completion: nil)
        DJStatisticsLogic.instance().addTraceLog(.Findresult_Click_Refine)
    }
 
    func reloadTheData(total : Int?){
        pdtCollectionView.headerInfo = nil
        if let tmp = total{
            let text =  NSString(format: DJStringUtil.localize("%d items found.", comment:""), tmp)
            pdtCollectionView.headerInfo = text as String
        }
        pdtCollectionView.products = clothesList
        pdtCollectionView.reloadData()
    }
    
    func setContentOffSet(cgsize : CGPoint){
        pdtCollectionView.mainCollectionView.setContentOffset(cgsize, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        refineView.frame = CGRectMake(view.frame.size.width - 110 + 35 / 2, view.frame.size.height - 90, 110, 35)
        pdtCollectionView.frame = view.bounds
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == byPhotoMoreOrFilterNetTask{
            MBProgressHUD.hideHUDForView(view, animated: true)
            searchResultEmptyView?.hidden = true
            isLoadingMore = false
            
            if byPhotoMoreOrFilterNetTask.pageIndex == 0{
                clothesList = byPhotoMoreOrFilterNetTask.clothesList
            }else{
                clothesList.appendContentsOf(byPhotoMoreOrFilterNetTask.clothesList)
            }
            
            if clothesList.count == 0 {
                searchResultEmptyView?.hidden = false
            }else{
                searchResultEmptyView?.hidden = true
            }
            reloadTheData(byPhotoMoreOrFilterNetTask.total)
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
            MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Oops! Network is down.", comment:""), animated: true)
        }
        
        if task == byPhotoMoreOrFilterNetTask{
            MBProgressHUD.hideHUDForView(view, animated: true)
            isLoadingMore = false
        }
    }
    
    func sendByPhotoMoreOrFilterTask(){
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        MONetTaskQueue.instance().cancelTask(byPhotoMoreOrFilterNetTask)
        
        if let category = ConfigDataContainer.sharedInstance.getCatogryByTemplateId(theInitNetTask.templateId!){
            byPhotoMoreOrFilterNetTask.categoryID = category.categoryId
        }
        byPhotoMoreOrFilterNetTask.mark = theInitNetTask.mark
        byPhotoMoreOrFilterNetTask.subcategoryID = selectedSubCategoryId
        byPhotoMoreOrFilterNetTask.filterIds = ClothesDataContainer.sharedInstance.extractFilterIds(selectedFilter)
        
        byPhotoMoreOrFilterNetTask.priceMin = lowerPrice
        byPhotoMoreOrFilterNetTask.priceMax = higherPrice
        byPhotoMoreOrFilterNetTask.brandID = brandInfo?.id
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: byPhotoMoreOrFilterNetTask.uri())
        MONetTaskQueue.instance().addTask(self.byPhotoMoreOrFilterNetTask)
    }
    
}

extension ByPhotoResultViewController : FilterViewControllerDelegate{
    func filterDone(controller: FilterViewController) {
        pdtCollectionView.scrollToTheTop()
        
        if ClothesDataContainer.sharedInstance.extractFilterIds(controller.selectedFilters) != ClothesDataContainer.sharedInstance.extractFilterIds(selectedFilter)
            || selectedSubCategoryId != controller.subCategoryId
            || lowerPrice != controller.lowerPrice
            || higherPrice != controller.higherPrice
            || brandInfo?.id != controller.brandInfo?.id
        {
            selectedSubCategoryId = controller.subCategoryId
            selectedFilter = controller.selectedFilters
            lowerPrice = controller.lowerPrice
            higherPrice = controller.higherPrice
            brandInfo = controller.brandInfo
            byPhotoMoreOrFilterNetTask.pageIndex = 0
            byPhotoMoreOrFilterNetTask.ended = false
            sendByPhotoMoreOrFilterTask()
        }
        
        setRefineStatus()
    }
    
    func setRefineStatus() {
        if selectedFilter.count > 0 || selectedSubCategoryId != nil ||  lowerPrice + higherPrice > 0 || brandInfo != nil{
            refineView.selected = true
        }else {
            refineView.selected = false
        }
    }
    
}

extension ByPhotoResultViewController : ProductCollectionViewDelegate{
    func productCollectionViewDidSelect(productView: ProductCollectionView, product: Clothes) {
         pushClothDetailVC(product)
    }
    
    func productCollectionViewNeedLoadMore(productView: ProductCollectionView) {
        if byPhotoMoreOrFilterNetTask.ended || isLoadingMore{
            return
        }
        isLoadingMore = true
        byPhotoMoreOrFilterNetTask.nextPage()
        sendByPhotoMoreOrFilterTask()
    }
    
    
}
