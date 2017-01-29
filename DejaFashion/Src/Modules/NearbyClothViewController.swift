//
//  NearbyClothViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 5/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class NearbyClothViewController: DJBasicViewController, MONetTaskDelegate {
    private var enterInfo : FilterableConditions!
    private let tableView = NearbyClothTableView()
    private var searchTask = NearbyGetClothNetTask()
    private var taskState = NetTaskStates()
    
    init(enterInfo : FilterableConditions) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.enterInfo = enterInfo
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetTitle()
        tableView.listDelegate = self
        view.addSubview(tableView)
        
        sendFetchClothNetTask()
        
        showHomeButton(true)
    }
    
    func resetTitle(){
        if let tmp = enterInfo.keyWords {
            title = tmp
        }else if let tmp = enterInfo.brand {
            title = tmp.name
        }else{
            title = DJStringUtil.localize("Nearby Clothes", comment:"")
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    func sendFetchClothNetTask(){
        if taskState.isLoading || taskState.ended {
            return
        }
        MONetTaskQueue.instance().cancelTask(searchTask)
        searchTask = NearbyGetClothNetTask()
        
        if let tmp = enterInfo.brand{
            searchTask.brandID = tmp.id
        }
        if let tmp = enterInfo.subCategory{
            searchTask.subcategoryID = tmp.categoryId
        }
        searchTask.filterIds = [String]()
        if let tmp = enterInfo.colorFilter{
            searchTask.filterIds = [tmp.id]
        }
        if let tmp = enterInfo.filters {
            var fids = [String]()
            for one in tmp {
                fids.append(one.id)
            }
            searchTask.filterIds?.appendContentsOf(fids)
        }
        searchTask.priceMin = enterInfo.lowPrice
        searchTask.priceMax = enterInfo.highPrice
        
        searchTask.onSale = enterInfo.onSale
        searchTask.longitude = enterInfo.position?.longitude
        searchTask.latitude = enterInfo.position?.latitude
        searchTask.bodyIssue = enterInfo.bodyIssues
        searchTask.occasion = enterInfo.occasion
        
        searchTask.isNewArrival = enterInfo.isNewArrival
        if let tmp = enterInfo.keyWords{
            searchTask.keyWords = tmp
        }
        
        searchTask.pageIndex = taskState.pageIndex
        MONetTaskQueue.instance().addTask(searchTask)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: searchTask.uri())
        
        showLoading(true)
        taskState.isLoading = true
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == searchTask{
            showLoading(false)
            
            taskState.ended = searchTask.ended
            taskState.isLoading = false
            
            if searchTask.pageIndex == 0{
                tableView.data.removeAll()
                tableView.setContentOffset(CGPointZero, animated: true)
            }
            tableView.data.appendContentsOf(searchTask.shopInfos)
            tableView.reloadData()
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == searchTask{
            showLoading(false)
            taskState.isLoading = false
        }
    }
    
    func showLoading(show : Bool){
        if show{
            MBProgressHUD.showHUDAddedTo(view, animated: true)
        }else{
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
    
}

extension NearbyClothViewController: NearbyClothTableViewDelegate{
    func nearbyShopInfo(tableview: NearbyClothTableView, didSelectCloth cloth: Clothes?) {
        pushClothDetailVC(cloth)
    }
    
    func nearbyShopInfo(tableview: NearbyClothTableView, didSelectShop shop: NearbyShopInfo?) {
        guard let shopInfo = shop else{
            return
        }
        if shopInfo.sampleProducts.count > 0 {
            let cloth = shopInfo.sampleProducts[0]
            guard let clothId = cloth.uniqueID else{
                return
            }
            let url = ConfigDataContainer.sharedInstance.getShopLocationUrl(clothId, isGoToBrandHomePage: 1)
            let v = DJWebViewController(URLString: url)
            navigationController?.pushViewController(v, animated: true)
        }
    }
    
    func nearbyShopInfo(tableview: NearbyClothTableView, didClickMoreCloth shop: NearbyShopInfo?) {
        let enterC = ClothResultCondition()
        enterC.filterCondition = enterInfo.copy() as! FilterableConditions
        enterC.filterCondition.brand = shop?.brandInfo
        
        let resultVC = FindClothResultViewController(enterInfo : enterC)
        navigationController?.pushViewController(resultVC, animated: true)
    }
}
