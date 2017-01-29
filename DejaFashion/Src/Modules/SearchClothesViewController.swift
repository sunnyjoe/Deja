//
//  SearchClothesViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 4/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class SearchClothesViewController: DJBasicViewController, MONetTaskDelegate, UIScrollViewDelegate {
    
    var resultList = [Clothes]()
    
    var recents = [SearchHistory]()
    var popularKeyWords = [String]()
    let recommendView = UIScrollView()
    let popularKeywordView = UIView()
    let recentView = UIView()
    
    let searchBar = UISearchBar(frame: CGRectMake(0, 0, 200, 44))
    let searchHintTableView = UITableView()
    let searchHintDataSource = SearchHintDataSource()
    
    let searchResultCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: CHTCollectionViewWaterfallLayout())
    let searchResultDataSource = SearchResultDataSource()
    var searchResultEmptyView : SearchResultEmptyView?
    
    // filter info
    var subCategoryId : String?
    var selectedFilters = [Filter]()
    var lowerPrice : Int = 0
    var higherPrice : Int = 0
    var brandInfo : BrandInfo?
    private let refineView = RefineButton()
    
    private let searchResultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecommendView()
        loadRecentSearch()
        
        setupSearchUI()
        
        setupSearchResultUI()
        
        MONetTaskQueue.instance().addTask(SearchPopularNetTask())
        MONetTaskQueue.instance().addTaskDelegate(self, uri: SearchPopularNetTask.uri())
        
        view.addSubview(refineView)
        refineView.hidden = true
        refineView.addTapGestureTarget(self, action: #selector(SearchClothesViewController.refineBtnDidTapped))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        refineView.frame = CGRectMake(view.frame.size.width - 110 + 35 / 2, view.frame.size.height - 35 - 25, 110, 35)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if searchResultCollectionView.hidden{
            searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    func setupRecommendView() {
        view.addSubview(recommendView)
        recommendView.alwaysBounceVertical = true
        recommendView.frame = self.view.bounds
        recommendView.delegate = self
        popularKeywordView.hidden = true
        recentView.hidden = true
        recommendView.addSubviews(popularKeywordView, recentView)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func setupSearchUI() {
        searchBar.delegate = self
        searchBar.setImage(UIImage(), forSearchBarIcon: .Search, state: .Normal)
        searchBar.translucent = true
        searchBar.barStyle = .BlackTranslucent
        searchBar.placeholder = ConfigDataContainer.sharedInstance.getSearchKeywordHint()
        searchBar.barTintColor = UIColor(fromHexString: "383940")
        searchBar.backgroundColor = UIColor.clearColor()
        
        
        // Get the instance of the UITextField of the search bar
        if let searchField = searchBar.valueForKey("_searchField")
        {
            searchField.setTextColor(UIColor.whiteColor())
        }
        
        let searchArea = UIView(frame: CGRect(x: 0, y: 0, width: Int(view.frame.width) - 70, height: 44))
        let line = UIView(frame: CGRect(x: 0, y: 0, width: Int(view.frame.width), height: 1)).withBackgroundColor(DJCommonStyle.BackgroundColor)
        
        searchBar.frame = CGRect(x: 0, y: 6, width: Int(searchArea.frame.width), height: 32)
        searchArea.addSubviews(searchBar, line)
        searchArea.backgroundColor = DJCommonStyle.BackgroundColor
        
        let searchTextBackgound = UIImage(color: UIColor.clearColor(), andSize: searchBar.frame.size)
        searchBar.setSearchFieldBackgroundImage(searchTextBackgound, forState: .Normal)
        
        
        let searchItem = UIBarButtonItem(customView: searchArea)
        self.navigationItem.rightBarButtonItem = searchItem;
        
        view.userInteractionEnabled = true
        recommendView.addTapGestureTarget(self, action: #selector(SearchClothesViewController.hideKeyboard))
        
        searchHintTableView.hidden = true
        searchHintTableView.dataSource = searchHintDataSource
        searchHintTableView.delegate = searchHintDataSource
        searchHintTableView.allowsSelection = true
        searchHintTableView.frame = view.bounds
        searchHintDataSource.searchViewController = self
        searchHintTableView.showsVerticalScrollIndicator = false
        searchHintTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(searchHintTableView)
    }
    
    func setupSearchResultUI() {
        searchResultLabel.frame = CGRectMake(0, 0, view.frame.size.width, 37)
        searchResultLabel.withTextColor(DJCommonStyle.Color81).withFontHeletica(14).textCentered()
        
        searchResultCollectionView.hidden = true
        searchResultCollectionView.backgroundColor = UIColor.whiteColor()
        searchResultCollectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 64)
        searchResultCollectionView.delegate = searchResultDataSource
        searchResultCollectionView.dataSource = searchResultDataSource
        searchResultDataSource.searchViewController = self
        searchResultCollectionView.registerClass(FindClothCollectionCell.self, forCellWithReuseIdentifier: "cell")
        searchResultCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        view.addSubview(searchResultCollectionView)
    }
    
    func showResultView() {
        DJStatisticsLogic.instance().addTraceLog(.Findresult_appear)
        searchResultCollectionView.hidden = false
        refineView.hidden = false
    }
    
    func hideResultView() {
        searchResultCollectionView.hidden = true
        refineView.hidden = true
    }
    
    func refineBtnDidTapped() {
        let filterViewController = FilterViewController()
        let allCategory = ClothCategory()
        allCategory.categoryId = "0"
        allCategory.name = DJStringUtil.localize("Search", comment:"")
        filterViewController.category = allCategory
        filterViewController.subCategoryId = subCategoryId
        filterViewController.selectedFilters = selectedFilters
        filterViewController.lowerPrice = lowerPrice
        filterViewController.higherPrice = higherPrice
        filterViewController.brandInfo = brandInfo
        
        filterViewController.priceFilterEnabled = true
        filterViewController.brandFilterEnabled = true
        filterViewController.delegate = self
        
        if let text = searchBar.text {
            let task = SearchNetTask(keyword: text)
            task.isAnd = true
            filterViewController.fetchNetTask = task
        }
        self.presentViewController(UINavigationController(rootViewController: filterViewController), animated: true, completion: nil)
        DJStatisticsLogic.instance().addTraceLog(.Findresult_Click_Refine)
    }
    
    override func goBack() {
        if !searchResultCollectionView.hidden {
            
            resetSearchBar()
            
            loadRecentSearch()
            searchHintTableView.hidden = true
            hideResultView()
            searchResultEmptyView?.removeFromSuperview()
            searchResultEmptyView?.hidden = true
        }else {
            super.goBack()
        }
    }
    
    func hideKeyboard() {
        searchBar.endEditing(true)
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if let popularNetTask = task as? SearchPopularNetTask {
            if let keywords = popularNetTask.keywords {
                popularKeyWords = keywords
                showRecommendKeywords(keywords)
            }
        }
        
        if let hintNetTask = task as? SearchHintNetTask {
            if let keywords = hintNetTask.keywords {
                if searchBar.text == hintNetTask.keyword {
                    recommendView.hidden = true
                    searchResultEmptyView?.hidden = true
                    searchResultEmptyView?.removeFromSuperview()
                    hideResultView()
                    searchHintTableView.hidden = false
                    searchHintDataSource.keywords = keywords
                    searchHintTableView.reloadData()
                }
            }
        }
        
        if let searchNetTask = task as? SearchNetTask {
            if searchNetTask.pageSize == 1 {
                return
            }
            
            MBProgressHUD.hideHUDForView(view, animated: true)
            
            if searchNetTask.isAnd {
                if let list = searchNetTask.clothesList {
                    
                    if searchResultCollectionView.hidden && searchNetTask.pageIndex > 0 {
                        return
                    }
                    
                    if searchNetTask.pageIndex == 0 {
                        searchResultDataSource.andResults = list
                        //                        if searchNetTask.ended {
                        //                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 300), dispatch_get_main_queue()) {
                        //                                let task = SearchNetTask(keyword: self.searchBar.text!)
                        //                                task.isAnd = false
                        //                                task.pageIndex = 0
                        //                                self.addParamsToNetTask(task)
                        //                                MONetTaskQueue.instance().addTask(task)
                        //                                self.searchResultDataSource.loadingMore = true
                        //                            }
                        //                        }
                    }else {
                        searchResultDataSource.andResults.appendContentsOf(list)
                    }
                    searchResultDataSource.andResultEnded = searchNetTask.ended
                    searchResultDataSource.currentPage = searchNetTask.pageIndex
                    searchResultDataSource.loadingMore = false
                    searchResultCollectionView.reloadData()
                    showResultView()
                    recommendView.hidden = true
                    searchHintTableView.hidden = true
                    if list.count == 0 {
                        searchResultEmptyView = SearchResultEmptyView(frame : CGRectMake(0, 0, ScreenWidth, 300), keyword: self.searchBar.text!, recommendKeywords: searchNetTask.trySearchKeywords)
                        searchResultEmptyView?.controller = self
                        searchResultCollectionView.addSubview(searchResultEmptyView!)
                        searchResultEmptyView?.hidden = false
                    }else {
                        searchResultEmptyView?.hidden = true
                        searchResultEmptyView?.removeFromSuperview()
                    }
                }else {
                    searchResultEmptyView = SearchResultEmptyView(frame : CGRectMake(0, 0, ScreenWidth, 300), keyword: self.searchBar.text!, recommendKeywords: searchNetTask.trySearchKeywords)
                    searchResultEmptyView?.controller = self
                    searchResultCollectionView.addSubview(searchResultEmptyView!)
                    searchResultEmptyView?.hidden = false
                }
            }else {
                if let list = searchNetTask.clothesList {
                    if searchResultCollectionView.hidden && searchNetTask.pageIndex > 0 {
                        return
                    }
                    
                    if searchNetTask.pageIndex == 0 {
                        searchResultDataSource.orResults = list
                    }else {
                        searchResultDataSource.orResults.appendContentsOf(list)
                    }
                    searchResultDataSource.orResultEnded = searchNetTask.ended
                    searchResultDataSource.currentPage = searchNetTask.pageIndex
                    searchResultDataSource.loadingMore = false
                    searchResultCollectionView.reloadData()
                    showResultView()
                    recommendView.hidden = true
                    searchHintTableView.hidden = true
                }
            }
            
            if searchResultDataSource.andResults.count > 0{
                var text =  NSString(format: DJStringUtil.localize("%d items found.", comment: ""), searchNetTask.total)
                if let brandNumber = searchNetTask.fromBrandNumber{
                    if brandNumber > 1{
                        text =  NSString(format: DJStringUtil.localize("%d items found from %d brands.", comment: ""), searchNetTask.total, brandNumber)
                    }
                }
                searchResultCollectionView.addSubview(searchResultLabel)
                searchResultLabel.withText(text as String)
                
                // UITips.showSlideDownTip(text as String, duration: 2, offsetY: 0, insideParentView: self.view)
            }else{
                searchResultLabel.removeFromSuperview()
            }
        }
        
    }
    
    func netTaskDidFail(task: MONetTask!) {
        
        if let _ = task as? SearchPopularNetTask {
            loadRecentSearch()
        }
        
        if let _ = task as? SearchNetTask {
            MBProgressHUD.hideHUDForView(view, animated: true)
            searchResultDataSource.loadingMore = false
            DJNetworkFailedTip.showToast(self.view)
        }
    }
    
    override func emptyViewButtonDidClick(emptyView: DJEmptyView!) {
        
    }
    
    func showRecommendKeywords(keywords : [String]) {
        if keywords.count > 0 {
            popularKeywordView.hidden = false
            let popularLabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.width - 40, height: 40)).withFontHeletica(13).withTextColor(DJCommonStyle.ColorCE)
            popularLabel.text = DJStringUtil.localize("Popular Searches", comment: "")
            popularKeywordView.addSubview(popularLabel)
            
            let lineBreakContainer = LineBreakContainer()
            lineBreakContainer.lineWidth = view.frame.width - 40
            lineBreakContainer.lineHeight = 35
            lineBreakContainer.itemSpacing = 11
            lineBreakContainer.lineSpacing = 11
            popularKeywordView.addSubview(lineBreakContainer)
            
            for (i, keyword) in keywords.enumerate() {
                let label = DJLabel()
                label.withTextColor(DJCommonStyle.BackgroundColor).withFontHeletica(16)
                label.text = keyword
                label.backgroundColor = UIColor(fromHexString: "f0f0f0")
                label.insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                label.sizeToFit()
                label.tag = i + 1
                lineBreakContainer.addSubview(label, viewWidth: label.frame.width)
                label.addTapGestureTarget(self, action: #selector(SearchResultEmptyView.tapKeyword(_:)))
            }
            
            lineBreakContainer.frame = CGRect(origin: CGPoint(x: 20, y: 40), size: lineBreakContainer.contentSize)
            popularKeywordView.frame = CGRectMake(0, 0, view.frame.width, lineBreakContainer.frame.maxY)
            
            if !recentView.hidden {
                recentView.frame = CGRectMake(0, popularKeywordView.frame.maxY, view.frame.width, recentView.frame.height)
            }
        }else {
            popularKeywordView.hidden = true
            popularKeywordView.frame = CGRectZero
        }
        recommendView.contentSize = CGSize(width: view.frame.width, height: popularKeywordView.frame.maxY + recentView.frame.height + 90)
    }
    
    func tapKeyword(reg : UITapGestureRecognizer) {
        if let index = reg.view?.tag {
            if index > 0 {
                let keyword = popularKeyWords[index - 1]
                searchBar.text = keyword
                searchKeyword()
            }
        }
    }
    
    func loadRecentSearch() {
        recentView.removeAllSubViews()
        let recents = ClothesDataContainer.sharedInstance.querySearchHistory()
        if recents.count == 0 {
            self.recents.removeAll()
            recentView.frame = CGRectZero
            recentView.hidden = true
            return
        }
        
        recentView.hidden = false
        self.recents = recents
        
        let recentLabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.width - 40, height: 40)).withFontHeletica(13).withTextColor(DJCommonStyle.ColorCE)
        recentLabel.text = DJStringUtil.localize("Recent Searches", comment: "")
        recentView.addSubview(recentLabel)
        let divider = UIView(frame: CGRect(x: 20, y: recentLabel.frame.maxY, width: view.frame.width - 40, height: 1))
        divider.backgroundColor = DJCommonStyle.DividerColor
        recentView.addSubview(divider)
        
        let cacelImage = UIImage(named: "RemoveRecentSearchIcon")
        
        var maxY : CGFloat = 0
        for (i, recent) in recents.enumerate() {
            let recentItem = UIView(frame: CGRect(x: 20, y: (i + 1) * 40, width: Int(view.frame.width - 40), height: 40))
            let label = UILabel(frame: CGRectMake(0,0,230,40)).withTextColor(DJCommonStyle.BackgroundColor).withFontHeletica(16)
            label.text = recent.keyword
            let divider = UIView(frame: CGRect(x: 20, y: recentItem.frame.maxY, width: view.frame.width - 40, height: 1))
            divider.backgroundColor = DJCommonStyle.DividerColor
            label.userInteractionEnabled = true
            recentItem.addSubview(label)
            recentView.addSubview(recentItem)
            recentView.addSubview(divider)
            
            let cacelButton = UIButton(frame: CGRect(x: Int(view.frame.width - 55), y: 15 , width: 11, height: 10))
            cacelButton.setImage(cacelImage, forState: .Normal)
            cacelButton.tag = i + 1
            label.tag = i + 1
            cacelButton.addTarget(self, action: #selector(SearchClothesViewController.removeRecent(_:)), forControlEvents: .TouchUpInside)
            label.addTapGestureTarget(self, action: #selector(SearchClothesViewController.clickRecent(_:)))
            recentItem.addSubview(cacelButton)
            maxY = recentItem.frame.maxY
        }
        
        let clearAllLabel = UILabel(frame: CGRect(x: 20, y: maxY + 15, width: 150, height: 20))
        clearAllLabel.withFontHeletica(16)
        clearAllLabel.withTextColor(DJCommonStyle.ColorBlue)
        clearAllLabel.text = DJStringUtil.localize("Clear all history", comment: "")
        clearAllLabel.addTapGestureTarget(self, action: #selector(SearchClothesViewController.clearAllHistory(_:)))
        recentView.addSubview(clearAllLabel)
        
        recentView.frame = CGRectMake(0, popularKeywordView.frame.maxY, view.frame.width, clearAllLabel.frame.maxY)
        
        recommendView.contentSize = CGSize(width: view.frame.width, height: popularKeywordView.frame.maxY + recentView.frame.size.height + 90)
    }
    
    func clearAllHistory(reg : UITapGestureRecognizer) {
        ClothesDataContainer.sharedInstance.clearAllHistory()
        recentView.removeAllSubViews()
        recents.removeAll()
        recentView.frame = CGRectZero
        recentView.hidden = true
        recommendView.contentSize = popularKeywordView.frame.size
    }
    
    func removeRecent(btn : UIButton) {
        let index = btn.tag
        
        if index > 0 {
            if let keyword = recents[index - 1].keyword {
                ClothesDataContainer.sharedInstance.deleteSearchHistory(keyword)
                loadRecentSearch()
            }
        }
    }
    
    func clickRecent(reg : UITapGestureRecognizer) {
        if let index = reg.view?.tag {
            if index > 0 {
                if let keyword = recents[index - 1].keyword {
                    searchBar.text = keyword
                    searchKeyword()
                }
            }
        }
    }
}

extension SearchClothesViewController : FilterViewControllerDelegate {
    func filterDone(controller: FilterViewController) {
        subCategoryId = controller.subCategoryId
        selectedFilters = controller.selectedFilters
        lowerPrice = controller.lowerPrice
        higherPrice = controller.higherPrice
        brandInfo = controller.brandInfo
        searchKeyword(false)
    }
    
}

extension SearchClothesViewController : UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        NSLog("textDidChange searchText = " + searchText)
        if !searchText.isEmpty {
            MONetTaskQueue.instance().addTask(SearchHintNetTask(keyword: searchText))
            MONetTaskQueue.instance().addTaskDelegate(self, uri: SearchHintNetTask.uri())
        }else {
            recommendView.hidden = false
            loadRecentSearch()
            searchHintTableView.hidden = true
            hideResultView()
            searchHintDataSource.keywords.removeAll()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //        searchInputScrollView.contentOffset = CGPointZero
        if searchBar.text?.characters.count > 0 {
            return
        }
        recommendView.hidden = false
        loadRecentSearch()
        searchHintTableView.hidden = true
        hideResultView()
        searchHintDataSource.keywords.removeAll()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        NSLog("searchBarSearchButtonClicked")
        searchKeyword()
    }
    
    func searchKeyword(clearFilter : Bool = true) {
        let enterC = ClothResultCondition()
        enterC.filterCondition.keyWords = searchBar.text

        let resultVC = FindClothResultViewController(enterInfo : enterC)
        navigationController?.pushViewController(resultVC, animated: true)
 
        return 
//        searchResultEmptyView?.hidden = true
//        if let keyword = searchBar.text {
//            if !keyword.isEmpty {
//                ClothesDataContainer.sharedInstance.insertSearchHistory(keyword)
//                let task = SearchNetTask(keyword: searchBar.text!)
//                task.isAnd = true
//                if clearFilter {
//                    self.clearFilter()
//                }
//                setRefineStatus()
//                addParamsToNetTask(task)
//                MONetTaskQueue.instance().addTask(task)
//                MONetTaskQueue.instance().addTaskDelegate(self, uri: SearchNetTask.uri())
//                searchResultDataSource.loadingMore = true
//                searchResultDataSource.currentPage = 0
//                searchResultDataSource.isAnd = true
//                searchResultDataSource.andResultEnded = false
//                searchResultDataSource.orResultEnded = false
//                searchResultDataSource.andResults.removeAll()
//                searchResultDataSource.orResults.removeAll()
//                searchResultCollectionView.reloadData()
//                MBProgressHUD.showHUDAddedTo(view, animated: true)
//            }
//        }else {
//            resetSearchBar()
//        }
//        
//        hideKeyboard()
    }
    
    func clearFilter() {
        lowerPrice = 0
        higherPrice = 0
        subCategoryId = nil
        brandInfo = nil
        selectedFilters.removeAll()
    }
    
    func setRefineStatus() {
        if lowerPrice + higherPrice > 0 || subCategoryId != nil || brandInfo != nil || selectedFilters.count > 0 {
            refineView.selected = true
        }else {
            refineView.selected = false
        }
    }
    
    func addParamsToNetTask(netTask : SearchNetTask) {
        if let subCId = subCategoryId {
            netTask.subcategoryID = subCId
        }else {
            netTask.categoryID = "0"
        }
        netTask.priceMin = lowerPrice
        netTask.priceMax = higherPrice
        netTask.brandID = brandInfo?.id
        netTask.filterIds = selectedFilters.map{ $0.id }
    }
    
    func resetSearchBar() {
        searchResultDataSource.andResults.removeAll()
        searchResultDataSource.orResults.removeAll()
        searchResultDataSource.andResultEnded = false
        searchResultDataSource.orResultEnded = false
        searchResultCollectionView.reloadData()
        hideResultView()
        recommendView.hidden = false
        searchBar.placeholder = ConfigDataContainer.sharedInstance.getSearchKeywordHint()
    }
}

class SearchHintDataSource :NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var keywords = [String]()
    
    weak var searchViewController : SearchClothesViewController?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.textColor = DJCommonStyle.BackgroundColor
        cell.textLabel?.text = keywords[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchViewController?.searchBar.text = keywords[indexPath.row]
        searchViewController?.searchKeyword()
        searchViewController?.recommendView.hidden = false
        searchViewController?.loadRecentSearch()
        searchViewController?.searchHintTableView.hidden = true
        searchViewController?.hideResultView()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchViewController?.searchBar.endEditing(true)
    }
}

class SearchResultDataSource : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout{
    
    var andResults = [Clothes]()
    var orResults = [Clothes]()
    
    weak var searchViewController : SearchClothesViewController?
    
    var loadingMore = false
    var currentPage = 0
    
    var andResultEnded = false
    var orResultEnded = false
    
    var isAnd = true
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return andResults.count
        }
        
        if section == 1 {
            return orResults.count
        }
        
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if orResults.count > 0 {
            return 2
        }else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let v = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath)
        if indexPath.section == 1 {
            v.backgroundColor = UIColor(fromHexString: "eaeaea")
            if let _ = v.viewWithTag(11) {
            }else {
                let label = UILabel(frame: CGRectMake(23, 0, ScreenWidth, 30)).withTextColor(DJCommonStyle.Color81).withFontHeletica(15)
                label.withText(DJStringUtil.localize("Items you might be interested in", comment: ""))
                v.addSubview(label)
            }
        }
        
        return v
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var clothSummary : Clothes
        if indexPath.section == 0 {
            clothSummary = andResults[indexPath.row]
        }else {
            clothSummary = orResults[indexPath.row]
        }
        HistoryDataContainer.sharedInstance.addClothesToHistory(clothSummary)

        let url = ConfigDataContainer.sharedInstance.getClothDetailUrl(clothSummary.uniqueID!)
        let v = ClothDetailViewController(URLString: url)
        searchViewController?.navigationController?.pushViewController(v, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var clothSummary : Clothes
        if indexPath.section == 0 {
            clothSummary = andResults[indexPath.row]
        }else {
            clothSummary = orResults[indexPath.row]
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! FindClothCollectionCell
        cell.product = clothSummary
        if let url = clothSummary.thumbUrl, let color = clothSummary.thumbColor
        {
            cell.setImageUrl(url + "/\(ImageQuality.MIDDLE).jpg", colorValue: color)
        }
        
        if WardrobeDataContainer.sharedInstance.isInWardrobe(clothSummary.uniqueID!) {
            cell.descIcon.hidden = false
        }else {
            cell.descIcon.hidden = true
        }
        cell.product = clothSummary
        cell.setBrandName(clothSummary.brandName)
        cell.setClothName(clothSummary.name)
        cell.setPriceInfo(clothSummary.curentPrice as? Int, uprice: clothSummary.upPrice as? Int, currency: clothSummary.currency)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var clothSummary : Clothes
        if indexPath.section == 0 {
            clothSummary = andResults[indexPath.row]
        }else {
            clothSummary = orResults[indexPath.row]
        }
        return FindClothCollectionCell.calculateCellSize(clothSummary)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            if andResults.count == 0 {
                return UIEdgeInsetsMake(266, 23, 20, 23)
            }else{
                return UIEdgeInsetsMake(37, 23, 20, 23)
            }
        }
        
        return UIEdgeInsetsMake(23, 23, 20, 23)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchViewController?.searchBar.endEditing(true)
        if scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.size.height - scrollView.contentInset.bottom + scrollView.contentInset.top{
            if !loadingMore && !orResultEnded{
                // load more
                
                if andResultEnded {
                    //                    let task = SearchNetTask(keyword: searchViewController!.searchBar.text!)
                    //                    task.isAnd = false
                    //                    if orResults.count == 0 {
                    //                        task.pageIndex = 0
                    //                    }else {
                    //                        task.pageIndex = currentPage + 1
                    //                    }
                    //                    searchViewController?.addParamsToNetTask(task)
                    //                    MONetTaskQueue.instance().addTask(task)
                    //                    MONetTaskQueue.instance().addTaskDelegate(searchViewController, uri: SearchNetTask.uri())
                    //                    loadingMore = true
                }else {
                    let task = SearchNetTask(keyword: searchViewController!.searchBar.text!)
                    task.isAnd = true
                    task.pageIndex = currentPage + 1
                    searchViewController?.addParamsToNetTask(task)
                    MONetTaskQueue.instance().addTask(task)
                    MONetTaskQueue.instance().addTaskDelegate(searchViewController, uri: SearchNetTask.uri())
                    loadingMore = true
                }
                
            }
        }
    }
}



