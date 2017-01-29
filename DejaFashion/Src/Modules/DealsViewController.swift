//
//  DealsViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 24/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class DealsViewController: CategoryIndexableViewController, MONetTaskDelegate {
    private let refineView = RefineButton()
    private var dataSources = Set<PagedDealItemDatasource>()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(beginCategoryId: String?) {
        super.init(beginCategoryId: beginCategoryId)
    }
    
    override func viewDidLoad() {
        needAllCategory = true
        
        super.viewDidLoad()
        
        title = DJStringUtil.localize("Deals", comment:"")
                
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        sendNetTask("0")
        
        view.addSubview(refineView)
        refineView.addTapGestureTarget(self, action: #selector(DealsViewController.refineBtnDidTapped))
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        refineView.frame = CGRectMake(view.frame.size.width - 110 + 35 / 2, view.frame.size.height - 35 - 25, 110, 35)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
         showHomeButton(true)
    }
    
    func sendNetTask(cid : String?, page : Int = 0) {
        
        if let collectionView = categoryIdToView[cid!] as? UICollectionView {
            if let datasource = collectionView.dataSource as? PagedDealItemDatasource {
                
                datasource.netTask = DealsNetTask()
                datasource.netTask?.pageIndex = page
                if let subCId = datasource.subCategoryId {
                    datasource.netTask?.subcategoryID = subCId
                }
                datasource.netTask?.categoryID = cid
                
                datasource.netTask?.priceMin = datasource.lowerPrice
                datasource.netTask?.priceMax = datasource.higherPrice
                datasource.netTask?.brandID = datasource.brandInfo?.id
                datasource.netTask?.filterIds = datasource.selectedFilters.map{ $0.id }
                
                MONetTaskQueue.instance().addTaskDelegate(self, uri: datasource.netTask?.uri())
                MONetTaskQueue.instance().addTask(datasource.netTask)
            }
        }
        
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        
        let cid = categoryView.currentCategory?.categoryId
        
        let netTask = task as? DealsNetTask
        
        if netTask?.pageSize == 1 {
            return
        }
        
        if netTask?.categoryID != cid {
            return
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        if let collectionView = categoryIdToView[cid!] as? UICollectionView {
            if let datasource = collectionView.delegate as? PagedDealItemDatasource {
            
                if netTask?.pageIndex == 0 {
                    collectionView.contentOffset = CGPointZero
                    datasource.items.removeAll()
                }

                if let list = netTask!.clothesList {
                    datasource.items.appendContentsOf(list)
                }
                
                if datasource.items.isEmpty {
                    MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("No item found.", comment:""), duration: 2)
                }

                collectionView.reloadData()
                datasource.ended = netTask!.ended
                datasource.currentPage = netTask!.pageIndex
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        let cid = categoryView.currentCategory?.categoryId
        
        let netTask = task as? DealsNetTask
        
        if netTask?.categoryID != cid {
            return
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
        if let cid = categoryView.currentCategory?.categoryId {
            if let collectionView = categoryIdToView[cid] as? UICollectionView {
                if let datasource = collectionView.dataSource as? PagedDealItemDatasource {
                    if datasource.items.count > 0 {
                        DJNetworkFailedTip.showToast(self.view)
                    }else {
                        showNetworkUnavailableView()
                    }
                    if datasource.netTask == task {
                        datasource.netTask = nil
                    }
                }
            }
        }
    }
    
    override func emptyViewButtonDidClick(emptyView: DJEmptyView!) {
        hideNetworkUnavailableView()
        sendNetTask(categoryView.currentCategory?.categoryId)
    }
}

extension DealsViewController : DealItemListDelegate {
    
    func scrollViewDidScrollToEnd() {
        if let cid = categoryView.currentCategory?.categoryId {
            if let collectionView = categoryIdToView[cid] as? UICollectionView {
                if let datasource = collectionView.dataSource as? PagedDealItemDatasource {
                    if datasource.netTask?.pageIndex != datasource.currentPage + 1 && !datasource.ended && datasource.items.count > 0 {
                        sendNetTask(cid, page: datasource.currentPage + 1)
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(offsetY: CGFloat) {
//        if offsetY < 200 {
//            bottomArea?.hidden = true
//        }else {
//            bottomArea?.hidden = false
//            refineButton.setTitleColor(DJCommonStyle.ColorEA, forState: .Normal)
//            if let cid = categoryView.currentCategory?.categoryId {
//                if let collectionView = categoryIdToView[cid] as? UICollectionView {
//                    if let datasource = collectionView.dataSource as? PagedDealItemDatasource {
//                        if datasource.brandInfo != nil || datasource.subCategoryId != nil || (datasource.lowerPrice + datasource.higherPrice > 0) {
//                            refineButton.setTitleColor(DJCommonStyle.ColorRed, forState: .Normal)
//                        }
//                    }
//                }
//            }
//        }
    }
    
    func refineBtnDidTapped() {
        DJStatisticsLogic.instance().addTraceLog(.Deals_Click_Refine)
        let filterViewController = FilterViewController()
        if let cid = categoryView.currentCategory?.categoryId {
            if let collectionView = categoryIdToView[cid] as? UICollectionView {
                if let datasource = collectionView.dataSource as? PagedDealItemDatasource {
                    filterViewController.category = categoryView.currentCategory
                    filterViewController.subCategoryId = datasource.subCategoryId
                    filterViewController.selectedFilters = datasource.selectedFilters
                    filterViewController.lowerPrice = datasource.lowerPrice
                    filterViewController.higherPrice = datasource.higherPrice
                    filterViewController.brandInfo = datasource.brandInfo
                }
            }
        }
        filterViewController.priceFilterEnabled = true
        filterViewController.brandFilterEnabled = true
        filterViewController.delegate = self
        let task = DealsNetTask()
        filterViewController.fetchNetTask = task
        self.presentViewController(UINavigationController(rootViewController: filterViewController), animated: true, completion: nil)
    }
}

extension DealsViewController : FilterViewControllerDelegate {
    
    func filterDone(controller: FilterViewController) {
        if let cid = categoryView.currentCategory?.categoryId {
            if let collectionView = categoryIdToView[cid] as? UICollectionView {
                if let datasource = collectionView.dataSource as? PagedDealItemDatasource {
                    datasource.subCategoryId = controller.subCategoryId
                    datasource.selectedFilters = controller.selectedFilters
                    datasource.lowerPrice = controller.lowerPrice
                    datasource.higherPrice = controller.higherPrice
                    datasource.brandInfo = controller.brandInfo
                }
            }
            sendNetTask(cid)
            refreshRefineBtnState()
        }
    }
    
}

extension DealsViewController {
    override func categoryViewCategoryDidChange(categoryView: CategoryView) {
        let categoryId = categoryView.currentCategory!.categoryId
        currentCategoryView = categoryIdToView[categoryId]
        let collectionView = currentCategoryView as? UICollectionView
        if let datasource = collectionView?.delegate as? PagedDealItemDatasource {
            if datasource.items.count == 0 && datasource.netTask == nil{
                sendNetTask(categoryId)
            }
        }
        refreshRefineBtnState()
        let eventId = "\(StatisticsKey.Deals_Click.rawValue)_\(categoryView.currentCategory!.name)"
        DJStatisticsLogic.instance().addTraceLog(eventId)
    }
    
    func refreshRefineBtnState() {
        if let cid = categoryView.currentCategory?.categoryId {
            if let collectionView = categoryIdToView[cid] as? UICollectionView {
                if let datasource = collectionView.dataSource as? PagedDealItemDatasource {
                    if datasource.brandInfo != nil || datasource.subCategoryId != nil || (datasource.lowerPrice + datasource.higherPrice > 0) || datasource.selectedFilters.count > 0{
                        refineView.selected = true
                    }else {
                        refineView.selected = false
                    }
                }
            }
        }
    }
    
    override func categoryForView(categoryView: CategoryView, category: ClothCategory)-> UIView {
        let clothesCollectionView = UICollectionView(frame: CGRectZero ,collectionViewLayout: CHTCollectionViewWaterfallLayout())
        if let layout = clothesCollectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            layout.columnCount = 2
            layout.sectionInset = UIEdgeInsetsMake(10, 23, 20, 23)
        }
        let datasource = PagedDealItemDatasource(collectionView: clothesCollectionView)
        clothesCollectionView.delegate = datasource
        clothesCollectionView.dataSource = datasource
        datasource.delegate = self
        clothesCollectionView.registerClass(DealClothCollectionCell.self, forCellWithReuseIdentifier: "cell")
        clothesCollectionView.backgroundColor = UIColor.whiteColor()
        clothesCollectionView.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height)
        
        categoryIdToView[category.categoryId] = clothesCollectionView
        dataSources.insert(datasource)
        return clothesCollectionView
    }
}

