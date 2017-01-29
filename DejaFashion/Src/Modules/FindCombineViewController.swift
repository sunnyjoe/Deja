//
//  FindCombineViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 18/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


class FindCombineViewController: DJBasicViewController, MONetTaskDelegate {
    private let topBannerView = UIView()
    private var searchBar : FindClothSearchView!
    private var priceBCView : FindClothPBCView!
    private var purposeView = UIView()
    private let searchBtn = DJButton()
    private let purposeInfoLabel = UILabel()
    
    private var priceOptionWindow : FindClothPriceSelecWindow?
    private var brandOptionWindow : FindClothBrandOptionWindow?
    private var colorOptionWindow : FindClothColorOptionWindow?
    private var purposeWindow     : FindClothPurposeWindow?
    
    private var searchCondition = FilterableConditions()
    private var fetchNetTask = FindClothesNetTask()
    private let searchActivity = UIActivityIndicatorView()
    
    private let pullDownView = UIView()
    private let brandView = AddByBrandView()
    private var blackSearchView : BlackFindClothSearchView?
    
    private let beginKeyWords = ConfigDataContainer.sharedInstance.getNewFindPlaceHolder()
    
    private var preLocation = CGPointZero
    private var locationPurpose = SearchPurpose()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hidesBottomBarWhenPushed = false
        view.backgroundColor = UIColor(fromHexString: "f6f6f6")
        
        var scale : CGFloat = 1
        if view.frame.size.width < 374{
            scale = 0.8
        }
        topBannerView.frame = CGRectMake(0, 0, view.frame.size.width, 257 * scale)
        view.addSubview(topBannerView)
        buildTopBanner(topBannerView)
        
        searchBar = FindClothSearchView(frame: CGRectMake(23, CGRectGetMaxY(topBannerView.frame) + 27, view.frame.size.width - 23 * 2, 40))
        searchBar.delegate = self
        searchBar.addBorder()
        view.addSubview(searchBar)
        
        priceBCView = FindClothPBCView(frame : CGRectMake(23, CGRectGetMaxY(searchBar.frame) + 10, view.frame.size.width - 23 * 2, 50))
        priceBCView.delegate = self
        priceBCView.backgroundColor = UIColor.whiteColor()
        priceBCView.addBorder()
        view.addSubview(priceBCView)
        
        purposeView.frame = CGRectMake(23, CGRectGetMaxY(priceBCView.frame) + 10, view.frame.size.width - 23 * 2, 40)
        buildPurposeView()
        view.addSubview(purposeView)
        
        searchBtn.frame = CGRectMake(23, CGRectGetMaxY(purposeView.frame) + 20, view.frame.size.width - 23 * 2, 35)
        searchBtn.setWhiteTitle()
        searchBtn.withTitle("Search").withFontHeletica(15)
        searchBtn.addTarget(self, action: #selector(searchBtnDidClicked), forControlEvents: .TouchUpInside)
        view.addSubview(searchBtn)
        
        searchActivity.activityIndicatorViewStyle = .White
        searchActivity.frame = CGRectMake(90, 0, searchBtn.frame.size.width - 90, searchBtn.frame.size.height)
        
        view.addSubview(pullDownView)
        pullDownView.frame = CGRectMake(view.frame.size.width / 2 - 125 / 2, view.frame.size.height - 74 * scale - 56, 125, 31)
        //hide pull donw view
        //        buildPullDownView()
        
        
        
        //        searchBar.setSearchText(beginKeyWords)
        //        searchCondition.keyWord = beginKeyWords
        // searchConditionChanged()
        
        
        //hide pull donw view
        //        let pang = UIPanGestureRecognizer(target: self, action: #selector(detectPanGesture(_:)))
        //        pang.cancelsTouchesInView = false
        //        view.addGestureRecognizer(pang)
        
  
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationDidUpdate), name: NOTIFY_LOCATION_UPDATE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationUsageAllowed), name: NOTIFY_LOCATION_AUTH_ALLOW, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationUsageDenied), name: NOTIFY_LOCATION_AUTH_DENIED, object: nil)
    }
    
    func applicationWillEnterForeground(){
        if searchCondition.position != nil {
            LocationManager.sharedInstance().startAccurateMonitor()
        }
    }
    
    func locationDidUpdate(){
        guard let cl = LocationManager.sharedInstance().currentLocation else{
            return
        }
        
        guard let preP = searchCondition.position else{
            return
        }
        
        let curP = cl.coordinate
        if abs(preP.latitude - curP.latitude) > 0.001 || abs(preP.longitude - curP.longitude) > 0.0015 {
            searchCondition.position = (curP.longitude, curP.latitude)
            searchConditionChanged()
        }
    }
    
    func detectPanGesture(pan : UIPanGestureRecognizer){
        let translation = pan.locationInView(view)
        if pan.state == .Began{
            preLocation = translation
        }else if pan.state == .Ended{
            if preLocation.y <= searchBtn.frame.origin.y{
                return
            }
            let xd = preLocation.x - translation.x
            let yd = preLocation.y - translation.y
            
            if xd < 40 && yd > 60 {
                pullUPView()
            }
        }
    }
    
    func searchBtnDidClicked(){
        DJStatisticsLogic.instance().addTraceLog(.Find_Click_Search)
        
        if let theInput = searchBar.getKeywords(){
            if theInput.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
                searchCondition.keyWords = nil
            }else{
                searchCondition.keyWords = theInput
            }
        }
        
        let enterC = ClothResultCondition()
        enterC.filterCondition = searchCondition.copy() as! FilterableConditions
        
        
        if searchCondition.position != nil {
            let resultVC = NearbyClothViewController(enterInfo : enterC.filterCondition)
            navigationController?.pushViewController(resultVC, animated: true)
        }else{
            let resultVC = FindClothResultViewController(enterInfo : enterC)
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }
    
    func searchConditionChanged(){
        MONetTaskQueue.instance().cancelTask(fetchNetTask)
        
        fetchNetTask = FindClothesNetTask()
        fetchNetTask.pageSize = 1
        
        fetchNetTask.extractFilterCondition(searchCondition.copy() as! FilterableConditions)
        
        
        MONetTaskQueue.instance().addTask(fetchNetTask)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: fetchNetTask.uri())
        
        searchBtn.addSubview(searchActivity)
        searchActivity.startAnimating()
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == fetchNetTask {
            searchActivity.removeFromSuperview()
            searchActivity.stopAnimating()
            if fetchNetTask.pageSize == 1 {
                var brandCont = 0
                if let tmp = fetchNetTask.fromBrandNumber{
                    brandCont = tmp
                }
                showItemNumber(fetchNetTask.total, brandNumber:brandCont)
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == fetchNetTask {
            searchActivity.removeFromSuperview()
            searchActivity.stopAnimating()
            searchBtn.enabled = true
            searchBtn.setBackgroundColor(UIColor.blackColor(), forState: .Normal)
            searchBtn.withTitle("Search")
        }
    }
    
    func showItemNumber(number : Int, brandNumber : Int){
        if checkAllCondtion() {
            searchBtn.enabled = true
            searchBtn.setBackgroundColor(UIColor.blackColor(), forState: .Normal)
            searchBtn.withTitle("Search")
            
            return
        }
        
        if number <= 0 {
            searchBtn.enabled = false
            searchBtn.withTitle("No Result Found")
            searchBtn.setBackgroundColor(DJCommonStyle.ColorCE, forState: .Normal)
        }else{
            searchBtn.enabled = true
            searchBtn.setBackgroundColor(UIColor.blackColor(), forState: .Normal)
            
            var text =  NSString(format: DJStringUtil.localize("Show %d items", comment:""), number) as String
            if brandNumber > 1 {
                text =  NSString(format: DJStringUtil.localize("Show %d items in %d brands", comment:""), number, brandNumber) as String
            }
            searchBtn.withTitle(text)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    deinit{
        LocationManager.sharedInstance().stopAccurateMonitor()
    }
}

extension FindCombineViewController: FindClothSearchViewDelegate, FindClothPBCViewDelegate, FindClothPriceSelecWindowDelegate, FindClothColorOptionWindowDelegate, FindClothBrandOptionWindowDelegate, FindClothPurposeWindowDelegate{
    func resetSearch(){
        searchCondition = FilterableConditions()
        
        searchBar.setSearchText(searchCondition.keyWords)
        priceBCView.resetPrice(searchCondition.lowPrice, searchCondition.highPrice)
        priceBCView.resetBrand(searchCondition.brand?.name)
        priceBCView.resetColor(searchCondition.colorFilter?.name)
        
        LocationManager.sharedInstance().stopAccurateMonitor()
        setDefaultPurposeInfo()
        
        searchBtn.enabled = true
        searchBtn.setBackgroundColor(UIColor.blackColor(), forState: .Normal)
        searchBtn.withTitle("Search")
    }
    
    func findClothPriceSelecWindowSelectPrice(findClothPriceSelecWindow: FindClothPriceSelecWindow, lowPrice: Int, highPrice: Int) {
        searchCondition.lowPrice = lowPrice
        searchCondition.highPrice = highPrice
        
        priceBCView.resetPrice(lowPrice, highPrice)
        searchConditionChanged()
    }
    
    func findClothBrandOptionWindowSelectBrand(findClothBrandOptionWindow: FindClothBrandOptionWindow, brand : BrandInfo?) {
        searchCondition.brand = brand
        if brand != nil {
            priceBCView.resetBrand(brand!.name)
        }else{
            priceBCView.resetBrand(nil)
        }
        searchConditionChanged()
    }
    
    func findClothColorOptionWindowSelectColor(findClothColorOptionWindow: FindClothColorOptionWindow, colorFilter: ColorFilter?) {
        searchCondition.colorFilter = colorFilter
        priceBCView.resetColor(colorFilter?.name)
        searchConditionChanged()
    }
    
    func findClothPurposeWindowSelectPurpose(findClothPurposeWindow: FindClothPurposeWindow, purpose: SearchPurpose?) {
        if let tmp = purpose{
            if tmp.type == PurposeType.Nearby{
                locationPurpose = tmp
                let curS = CLLocationManager.authorizationStatus()
                if curS == .Denied || curS == .Restricted{
                    let alertView = LocationAlertView(frame : UIScreen.mainScreen().bounds)
                    alertView.setTargetSelector(self, noThanksSel:  nil, settingSel:  #selector(settingBtnDidClicked))
                    alertView.showAnimation()
                    
                    UIApplication.sharedApplication().windows[0].addSubview(alertView)
                }else if curS == .NotDetermined{//should pop up system alert
                    LocationManager.sharedInstance().startAccurateMonitor()
                }else {
                    selectPosition()
                    purposeInfoLabel.withText(tmp.name)
                    LocationManager.sharedInstance().startAccurateMonitor()
                    searchConditionChanged()
                }
            }else{
                LocationManager.sharedInstance().stopAccurateMonitor()
                selectPurpose(tmp)
                purposeInfoLabel.withText(tmp.name)
                searchConditionChanged()
            }
        }else{
            setDefaultPurposeInfo()
            clearPurposeSelection()
        }
    }
    
    
    func locationUsageAllowed(){
        selectPosition()
        purposeInfoLabel.withText(locationPurpose.name)
        searchConditionChanged()
    }
    
    func locationUsageDenied(){
        purposeWindow!.resetPurpose(generatePurpose())
    }
    
    func findClothPBCViewClickBrand(findClothPBCView : FindClothPBCView){
        DJStatisticsLogic.instance().addTraceLog(.Find_Choose_Brand)
        if brandOptionWindow == nil{
            brandOptionWindow = FindClothBrandOptionWindow(frame: UIScreen.mainScreen().bounds)
            brandOptionWindow?.delegate = self
        }
        brandOptionWindow!.resetBrand(searchCondition.brand)
        brandOptionWindow!.showAnimation()
    }
    
    func findClothPBCViewClickPrice(findClothPBCView : FindClothPBCView){
        DJStatisticsLogic.instance().addTraceLog(.Find_Choose_Price)
        if priceOptionWindow == nil{
            priceOptionWindow = FindClothPriceSelecWindow(frame: UIScreen.mainScreen().bounds)
            priceOptionWindow?.delegate = self
        }
        priceOptionWindow!.resetPrice(searchCondition.lowPrice, high: searchCondition.highPrice)
        priceOptionWindow!.showAnimation()
    }
    
    func findClothPBCViewClickColor(findClothPBCView : FindClothPBCView){
        DJStatisticsLogic.instance().addTraceLog(.Find_Choose_Color)
        if colorOptionWindow == nil{
            colorOptionWindow = FindClothColorOptionWindow(frame: UIScreen.mainScreen().bounds)
            colorOptionWindow?.delegate = self
        }
        colorOptionWindow!.resetSelectedColor(searchCondition.colorFilter)
        colorOptionWindow!.showAnimation()
    }
    
    
    func purposeViewDidTapped(){
        DJStatisticsLogic.instance().addTraceLog(.Find_Choose_Pur)
        if purposeWindow == nil{
            purposeWindow = FindClothPurposeWindow(frame: UIScreen.mainScreen().bounds)
            purposeWindow?.delegate = self
        }
        
        purposeWindow!.resetPurpose(generatePurpose())
        purposeWindow!.showAnimation()
    }
    
    
    func findClothSearchViewDidSearch(findClothSearchView : FindClothSearchView, query : String?){
        //        if query == "" {
        //            searchCondition.keyWord = beginKeyWords
        //        }else{
        //            if query?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
        //                searchCondition.keyWord = nil
        //            }else{
        searchCondition.keyWords = query
        //            }
        //        }
        searchConditionChanged()
    }
    
    func findClothSearchViewDidPauseInput(findClothSearchView: FindClothSearchView, query: String?) {
        if query?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
            searchCondition.keyWords = nil
        }else{
            searchCondition.keyWords = query
        }
        
        searchConditionChanged()
    }
    
    func findClothSearchViewClessClear(findClothSearchView : FindClothSearchView){
        searchCondition.keyWords = nil
        searchConditionChanged()
    }
    
    func findClothSearchViewBeginEditing(findClothSearchView: FindClothSearchView) {
        DJStatisticsLogic.instance().addTraceLog(.Find_Choose_Searchbox)
        // navigationController?.pushViewController(SearchClothesViewController(), animated: true)
    }
    
    func findClothSearchViewByPhoto(findClothSearchView : FindClothSearchView){
        DJStatisticsLogic.instance().addTraceLog(.Find_Click_Photo)
        navigationController?.pushViewController(AddClothByCameraViewController(), animated: true)
    }
    
    func findClothSearchViewByPriceTag(findClothSearchView : FindClothSearchView){
        DJStatisticsLogic.instance().addTraceLog(.Find_Click_Pricetag)
        ConfigDataContainer.sharedInstance.scanButtonClicked = true
        navigationController?.pushViewController(AddByScanViewController(), animated: true)
    }
}

extension FindCombineViewController: AddByBrandViewDelegate{
    func addByBrandViewDelegateSelectBrand(addByBrandView : AddByBrandView, brand : BrandInfo?){
        DJStatisticsLogic.instance().addTraceLog(.Brands_Click_onebrand)
        let bpv = BrandCategoriesViewController(brandIf: brand)
        navigationController?.pushViewController(bpv, animated: true)
    }
    
    func addByBrandViewDelegateGoback(addByBrandView: AddByBrandView) {
        recoverView()
    }
}

extension FindCombineViewController {
    func checkAllCondtion() -> Bool{
        if searchCondition.lowPrice != 0 || searchCondition.highPrice != 0{
            return false
        }
        if searchCondition.colorFilter != nil || searchCondition.brand != nil || searchCondition.keyWords != nil {
            return false
        }
        if searchCondition.isNewArrival || searchCondition.onSale{
            return false
        }
        if searchCondition.position != nil || searchCondition.bodyIssues != nil || searchCondition.occasion != nil {
            return false
        }
        return true
    }
    
    func generatePurpose() -> Purpose{
        var purpose = Purpose()
        purpose.isNewArrival = searchCondition.isNewArrival
        purpose.position = searchCondition.position
        purpose.bodyIssues = searchCondition.bodyIssues
        purpose.occasion = searchCondition.occasion
        purpose.onSale = searchCondition.onSale
        
        return purpose
    }
    
    func selectPosition(){
        clearPurposeSelection()
        let loc = LocationManager.sharedInstance().currentLocation
        if loc != nil {
            searchCondition.position = (loc.coordinate.longitude, loc.coordinate.latitude)
        }else{
            searchCondition.position = (0, 0)
        }
    }
    
    func selectPurpose(sp : SearchPurpose){
        let type = sp.type
        clearPurposeSelection()
        
        if type == PurposeType.NewArrival{
            searchCondition.isNewArrival = true
        }else if type == PurposeType.Nearby{
            selectPosition()
        }else if type == PurposeType.Deal{
            searchCondition.onSale = true
        }else if type == PurposeType.Occasion{
            searchCondition.occasion = sp.id
        }else if type == PurposeType.BodyIssues{
            searchCondition.bodyIssues = sp.id
        }
    }
    
    func clearPurposeSelection(){
        searchCondition.isNewArrival = false
        searchCondition.position = nil
        searchCondition.bodyIssues = nil
        searchCondition.occasion = nil
        searchCondition.onSale = false
    }
    
    func settingBtnDidClicked(){
        if let url = NSURL(string:  UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}

extension FindCombineViewController: BlackFindClothSearchViewDelegate{
    func pullUPView(){
        brandView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, view.frame.size.height - 55)
        brandView.delegate = self
        
        if blackSearchView == nil{
            blackSearchView = BlackFindClothSearchView(frame : CGRectMake(0, 0, view.frame.size.width, 65))
        }
        
        blackSearchView!.delegate = self
        blackSearchView!.gestureDelegate = self
        self.blackSearchView!.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 65)
        self.view.addSubview(self.blackSearchView!)
        
        let searchBarTmp = self.searchBar.frame
        
        let offSet = view.frame.size.height - 65
        
        UIView.animateWithDuration(0.3, animations: {
            var tmp = self.topBannerView.frame
            self.topBannerView.frame = CGRectMake(tmp.origin.x, tmp.origin.y - offSet, tmp.size.width, tmp.size.height)
            
            self.blackSearchView!.frame = CGRectMake(0, 0, self.view.frame.size.width, 65)
            self.searchBar.frame = CGRectMake(23, 22.5, self.view.frame.size.width - 23 * 2, 40)
            
            tmp = self.priceBCView.frame
            self.priceBCView.frame = CGRectMake(tmp.origin.x, tmp.origin.y - offSet, tmp.size.width, tmp.size.height)
            
            tmp = self.purposeView.frame
            self.purposeView.frame = CGRectMake(tmp.origin.x, tmp.origin.y - offSet, tmp.size.width, tmp.size.height)
            
            tmp = self.searchBtn.frame
            self.searchBtn.frame =  CGRectMake(tmp.origin.x, tmp.origin.y - offSet, tmp.size.width, tmp.size.height)
            
            self.brandView.frame = CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height - 65)
            
            }, completion: {(Bool) -> Void in
                var tmp = self.topBannerView.frame
                self.topBannerView.frame = CGRectMake(tmp.origin.x, tmp.origin.y + offSet, tmp.size.width, tmp.size.height)
                
                tmp = self.priceBCView.frame
                self.priceBCView.frame = CGRectMake(tmp.origin.x, tmp.origin.y + offSet, tmp.size.width, tmp.size.height)
                
                tmp = self.purposeView.frame
                self.purposeView.frame = CGRectMake(tmp.origin.x, tmp.origin.y + offSet, tmp.size.width, tmp.size.height)
                
                tmp = self.searchBtn.frame
                self.searchBtn.frame = CGRectMake(tmp.origin.x, tmp.origin.y + offSet, tmp.size.width, tmp.size.height)
                
                self.searchBar.frame = searchBarTmp
                
        })
        view.addSubview(brandView)
    }
    
    func blackFindClothSearchViewDidDragDown(blackFindClothSearchView: BlackFindClothSearchView) {
        recoverView()
    }
    
    func recoverView(){
        if self.blackSearchView == nil{
            return
        }
        
        if self.blackSearchView!.superview == nil {
            return
        }
        
        UIView.animateWithDuration(0.3, animations: {
            self.blackSearchView!.frame = CGRectMake(0, self.view.frame.size.height, self.blackSearchView!.frame.size.width, self.blackSearchView!.frame.size.height)
            self.brandView.frame = CGRectMake(0,  self.view.frame.size.height + self.blackSearchView!.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - 65)
            self.brandView.alpha = 0
            }, completion: {(Bool) -> Void in
                self.brandView.alpha = 1
                self.blackSearchView!.removeFromSuperview()
        })
    }
    
    func setDefaultPurposeInfo(){
        if let tmp = ConfigDataContainer.sharedInstance.getDefaultSearchPurpose(){
            purposeInfoLabel.withText(tmp.name)
        }else{
            purposeInfoLabel.withText("No Limited")
        }
    }
    
    func buildPurposeView(){
        purposeView.backgroundColor = UIColor.whiteColor()
        
        let forLabel = UILabel(frame: CGRectMake(20, 15, 30, 15))
        purposeView.addSubview(forLabel)
        forLabel.withTextColor(DJCommonStyle.Color41).withText("Preference").withFontHeleticaThin(11)
        forLabel.sizeToFit()
        
        purposeInfoLabel.frame = CGRectMake(CGRectGetMaxX(forLabel.frame) + 10, 0, purposeView.frame.size.width - CGRectGetMaxX(forLabel.frame) - 10 - 10, purposeView.frame.size.height)
        purposeView.addSubview(purposeInfoLabel)
        purposeInfoLabel.withFontHeletica(15).withTextColor(UIColor.defaultBlack())
        
        setDefaultPurposeInfo()
        
        forLabel.userInteractionEnabled = false
        purposeInfoLabel.userInteractionEnabled = false
        purposeView.addTapGestureTarget(self, action: #selector(purposeViewDidTapped))
        purposeView.addBorder()
    }
    
    func buildTopBanner(containterView : UIView){
        let imageView = UIImageView(frame : containterView.bounds)
        imageView.image = UIImage(named: "FindBannerImage")
        containterView.addSubview(imageView)
        
        var scale : CGFloat = 1
        if view.frame.size.width < 374{
            scale = 0.8
        }
        
        let logoIV = UIImageView(frame : CGRectMake(containterView.frame.size.width / 2 - 26, 120 * scale, 52.5, 52.5))
        logoIV.image = UIImage(named: "CircleDeja")
        containterView.addSubview(logoIV)
        
        let labelV = UILabel(frame : CGRectMake(0, CGRectGetMaxY(logoIV.frame) + 4, containterView.frame.size.width, 16))
        containterView.addSubview(labelV)
        labelV.textCentered().withText("Deja").withTextColor(UIColor.whiteColor()).withFontHeleticaThin(14)
        
        containterView.addBorder()
    }
    
    func buildPullDownView(){
        let label = UILabel(frame : CGRectMake(0, 0, pullDownView.frame.size.width, 15.5))
        label.withText("Search by Brands").withTextColor(UIColor.defaultBlack()).withFontHeletica(13).textCentered()
        pullDownView.addSubview(label)
        
        let arrow = UIImageView(frame : CGRectMake(pullDownView.frame.size.width / 2 - 22 / (1.5 * 2), pullDownView.frame.size.height - 19 / 2 - 3, 22 / 1.5, 19 / 2))
        pullDownView.addSubview(arrow)
        arrow.image = UIImage(named: "FilterArrowDown")
        
        pullDownView.addTapGestureTarget(self, action: #selector(pullUPView))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if let touch = touches.first {
            if touch.view != searchBar {
                searchBar.hideKeyBoard()
            }
        }
    }
    
}
