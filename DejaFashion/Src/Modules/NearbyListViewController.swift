//
//  NearbyListViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 21/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class NearbyListViewController: DJBasicViewController, MONetTaskDelegate, CustomSearchViewDelegate {
    private let scrollMallView = ScrollableBannerView()
    private let listTableView = ShopListTableView()
    private var searchBar : CustomSearchView!
    
    private let getShopMallNetTask = GetNearbyListNetTask()
    private let searchNetTask = NearbySearchNetTask()
    
    private var shopList : [ShopInfo]?
    private var mallList : [MallInfo]?
    private var alertView : LocationAlertView?
    
    private var coordinate : CLLocationCoordinate2D?
    private var currentPlaceLabel = UILabel()
    
    let emptyView = UIView()
    private var wasInitialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = DJStringUtil.localize("Nearby", comment:"")
        
        searchBar = CustomSearchView(frame: CGRectMake(23, 0, view.frame.size.width - 23 * 2, 48))
        searchBar.delegate = self
        searchBar.addUnderLine()
        searchBar.setSearchPlaceHolder(DJStringUtil.localize("Search Shops or Malls", comment:""))
        view.addSubview(searchBar)
        
        scrollMallView.frame = CGRectMake(0, CGRectGetMaxY(searchBar.frame) + 15, view.frame.size.width, 100)
        scrollMallView.delegate = self
        scrollMallView
        view.addSubview(scrollMallView)
        
        listTableView.shopListDelegate = self
        view.addSubview(listTableView)
        buildBottomView()
        
        emptyView.frame = CGRectMake(0, 100, view.bounds.size.width, view.bounds.size.height - 100) //view.bounds
        let reminderLabel = UILabel(frame: CGRectMake(20, 60, view.frame.size.width - 40, 60))
        emptyView.addSubview(reminderLabel)
        reminderLabel.textAlignment = .Center
        reminderLabel.numberOfLines = 0
        reminderLabel.withFontHeletica(17).withTextColor(UIColor.defaultBlack()).withText(DJStringUtil.localize("No Results.", comment:""))
        
        LocationManager.sharedInstance().startAccurateMonitor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateCurrentAddress), name:NOTIFY_LOCATION_UPDATE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationAuthDenied), name:NOTIFY_LOCATION_AUTH_DENIED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationAuthAllow), name:NOTIFY_LOCATION_AUTH_ALLOW, object: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        showHomeButton(true)
        showLocationAlertIfDontHavePermission()
        
        if ShopDataContainer.sharedInstance.isFirstEnterNearby(){
            DJAlertView.init(title: DJStringUtil.localize("Attention", comment:""), message: DJStringUtil.localize("Nearby service is only available in Singapore now, support for more cities will come soon.", comment: ""), cancelButtonTitle: DJStringUtil.localize("Ok", comment:""))
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let oX = CGRectGetMaxY(scrollMallView.frame) + 15
        listTableView.frame = CGRectMake(0, oX, view.frame.size.width, view.frame.size.height - oX - 30)
    }
    
    
    func showEmptyView(show : Bool){
        if show{
            view.addSubview(emptyView)
        }else{
            emptyView.removeFromSuperview()
        }
    }
    
    func showLocationAlertIfDontHavePermission() {
        if CLLocationManager.authorizationStatus() != .NotDetermined && (CLLocationManager.authorizationStatus() != .AuthorizedAlways && CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse) && (alertView == nil || alertView?.superview == nil) {
            alertView = LocationAlertView(frame : UIScreen.mainScreen().bounds)
            alertView!.setTargetSelector(self, noThanksSel:  #selector(noThanksBtnDidClicked), settingSel:  #selector(settingBtnDidClicked))
            alertView!.showAnimation()
            navigationController?.view.addSubview(alertView!)
        }
    }
    
    func customSearchViewDidSearch(view: CustomSearchView, query: String?)
    {
        
        if searchBar.text()?.isEmpty == true
        {
            sendGetShopMallListNetTask()
        }
        else
        {
            sendSearchNetTask(query)
        }
        DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Click_Search)
    }
    
    func customSearchViewClessClear(view: CustomSearchView)
    {
        sendGetShopMallListNetTask()
    }
    
    func sendSearchNetTask(query: String?)
    {
        if let location = LocationManager.sharedInstance().currentLocation
        {
            coordinate = location.coordinate
            if coordinate != nil
            {
                searchNetTask.latitude = coordinate!.latitude
                searchNetTask.longitude = coordinate!.longitude
                searchNetTask.queryStr = query
                MONetTaskQueue.instance().addTaskDelegate(self, uri: searchNetTask.uri())
                MONetTaskQueue.instance().addTask(searchNetTask)
            }
        }
    }
    
    func sendGetShopMallListNetTask(){
        if let location = LocationManager.sharedInstance().currentLocation
        {
            coordinate = location.coordinate
            if coordinate != nil
            {
                getShopMallNetTask.latitude = coordinate!.latitude
                getShopMallNetTask.longitude = coordinate!.longitude
                MONetTaskQueue.instance().addTaskDelegate(self, uri: getShopMallNetTask.uri())
                MONetTaskQueue.instance().addTask(getShopMallNetTask)
            }
        }
        
    }
    
    func refreshBtnDidClicked(){
        //        refreshLocationDuration()
        //        searchBar.clearSearch()
        //        sendGetShopMallListNetTask()
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        if searchBar.text()?.isEmpty == true
        {
            sendGetShopMallListNetTask()
        }
        else
        {
            sendSearchNetTask(searchBar.text())
        }
        refreshAdress()
        DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Click_Refresh)
        
    }
    
    func refreshAdress()
    {
        if let location = LocationManager.sharedInstance().currentLocation
        {
            coordinate = location.coordinate
            if coordinate != nil
            {
                LocationManager.sharedInstance().geocodeAddress(coordinate!, completionHandler: {(place : Place?, success : Bool?) -> Void in
                    if place != nil && success != nil && success == true{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.currentPlaceLabel.text = place?.address
                        })
                    }
                })
            }
        }
    }
    
    func locationAuthDenied()
    {
        showLocationAlertIfDontHavePermission()
    }
    
    func locationAuthAllow()
    {
        if alertView != nil && alertView?.superview != nil
        {
            alertView?.removeFromSuperview()
        }
    }
    
    func updateCurrentAddress(){
        if wasInitialized == true{
            return
        }
        wasInitialized = true
        sendGetShopMallListNetTask()
        refreshAdress()
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == getShopMallNetTask || task == searchNetTask{
            MBProgressHUD.hideHUDForView(view, animated: true)
            
            let listTask = task as! GetNearbyListNetTask
            
            if let shops = listTask.shops
            {
                shopList = shops
                shopList!.sortInPlace({ $0.distance < $1.distance})
            }
            else
            {
                shopList = [ShopInfo]()
            }
            
            if let malls = listTask.malls
            {
                mallList = malls
                mallList!.sortInPlace({ $0.distance < $1.distance})
            }
            else
            {
                mallList = [MallInfo]()
            }
            
            if shopList?.count == 0 && mallList?.count == 0
            {
                showEmptyView(true)
            }
            else
            {
                showEmptyView(false)
            }
            
            resetMallScrollView()
            listTableView.data = shopList
            listTableView.reloadData()
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == getShopMallNetTask || task == searchNetTask {
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
    
    func didClickMallInfo(sender: AnyObject?){
        let vc = MallInfoViewController()
        if let gr = sender as? UITapGestureRecognizer
        {
            vc.mallInfo = gr.view?.property as? MallInfo
        }
        navigationController?.pushViewController(vc, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Click_Mall)
    }
    
    deinit{
        LocationManager.sharedInstance().stopAccurateMonitor()
    }
}

extension NearbyListViewController : ScrollableBannerViewDelegate
{
    func scrollableBannerView(bannerView : ScrollableBannerView, didTapImage : UIImage)
    {
    }
    
    func scrollableBannerViewStartScroll(bannerView : ScrollableBannerView)
    {
        self.view.endEditing(true)
    }
}


extension NearbyListViewController : ShopListTableViewDelegate
{
    func shopListTableView(tableview : ShopListTableView, didSelectShop shop: ShopInfo)
    {
        let vc = ShopInfoViewController()
        //        vc.shopInfo = shop
        vc.shopId = shop.id
        navigationController?.pushViewController(vc, animated: true)
        if shop.showMayLike
        {
            DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Click_ShopYouMayLike)
        }
        else
        {
            DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Click_Shop)
        }
    }
    
    func shopListTableViewStartScroll(tableview : ShopListTableView)
    {
        self.view.endEditing(true)
    }
}
extension NearbyListViewController{
    func buildBottomView(){
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(fromHexString: "f4f4f4")
        view.addSubview(bottomView)
        bottomView.addSubview(currentPlaceLabel)
        
        let refreshBtn = UIButton()
        bottomView.addSubview(refreshBtn)
        refreshBtn.addTarget(self, action: #selector(refreshBtnDidClicked), forControlEvents: .TouchUpInside)
        refreshBtn.setImage(UIImage(named: "RefreshIcon"), forState: .Normal)
        NSLayoutConstraint(item: refreshBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 21).active = true
        NSLayoutConstraint(item: refreshBtn, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 19).active = true
        
        constrain(bottomView, currentPlaceLabel, refreshBtn) { bottomView, currentPlaceLabel, refreshBtn in
            bottomView.right == bottomView.superview!.right
            bottomView.bottom == bottomView.superview!.bottom
            bottomView.left == bottomView.superview!.left
            bottomView.top == bottomView.superview!.bottom - 30
            
            currentPlaceLabel.centerY == bottomView.centerY
            currentPlaceLabel.left == bottomView.left + 23
            currentPlaceLabel.right == bottomView.right - 23 - 30
            
            refreshBtn.centerY == bottomView.centerY
            refreshBtn.right == bottomView.right - 23
        }
        currentPlaceLabel.numberOfLines = 1
        currentPlaceLabel.withTextColor(UIColor.defaultBlack()).withFontHeletica(13)
    }
    
    
    func resetMallScrollView(){
        if mallList != nil {
            var mallViews = [MallShortInfoView]()
            for oneMall in mallList!{
                let mallView = MallShortInfoView(frame : CGRectMake(0, 0, 245, scrollMallView.frame.size.height))
                mallViews.append(mallView)
                mallView.property = oneMall
                mallView.addTapGestureTarget(self, action: #selector(didClickMallInfo))
                mallView.mallName(oneMall.name)
                let distance = String(format: "%.1fKM", oneMall.distance)
                mallView.distance(distance)
            }
            scrollMallView.setScrollViews(mallViews)
        }
    }
    
    func noThanksBtnDidClicked(){
        navigationController?.popViewControllerAnimated(true)
    }
    
    func settingBtnDidClicked(){
        if let url = NSURL(string:  UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
        else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
}
