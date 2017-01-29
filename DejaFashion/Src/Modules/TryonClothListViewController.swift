//
//  TryonClothListViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 8/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit
import AssetsLibrary

protocol TryonClothListViewControllerDelegate : NSObjectProtocol{
    func tryonClothListViewControllerDidChooseCloth(vc: TryonClothListViewController, product : Clothes)
}

class TryonClothListViewController : DJBasicViewController, MONetTaskDelegate, FindClothRefineViewDelegate {
    static let collectionCellIdentifier = "collectionCellIdentifier"
    
    var vcTitle = ""
    var category : ClothCategory?
    let mainCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: CHTCollectionViewWaterfallLayout())
    let containterView = DJRefreshContainerView()
    var filterView : FindClothRefineView?
    var netTaskResults = [Clothes]()
    var tryonClothNetTask = FindClothesTryonNetTask()
    var pageEnd = false
    var clickClothReturn = false
    weak var delegate : TryonClothListViewControllerDelegate?
    let notfindBtn = DJButton()
    
    var selectedFilter = [Filter]()
    var suggestView : SuggestionView?
    let filterScrollViewBar = UIScrollView()
    var selectedFilterBtns = [DJButton]()
    var uploadNetTask: DJUploadFileNetTask?
    var feedbackNetTask : FeedbackNetTask?
    
    var selectedSubCategoryId : String?
    var originSubCategoryId : String?
    
    lazy private var notFindView: ClothNotFindView = {
        let tmp = ClothNotFindView(frame: self.view.bounds)
        tmp.setReportSelector(self, sel: #selector(notfindBtnDidTapped))
        return tmp
    }()
    
    init(category : ClothCategory, selectedSubCategoryId : String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.category = category
        
        vcTitle = category.name
        
        self.selectedSubCategoryId = selectedSubCategoryId
        originSubCategoryId = selectedSubCategoryId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = vcTitle

        let colorFilterCnt = ConfigDataContainer.sharedInstance.getConfigColorFilters().count
        if colorFilterCnt > 0 {
            let filterBtn = DJButton(type: UIButtonType.Custom)
            filterBtn.frame = CGRectMake(0, 0, 44, 44)
            filterBtn.addTarget(self, action: #selector(TryonClothListViewController.filterBtnDidTap), forControlEvents: UIControlEvents.TouchUpInside)
            filterBtn.withTitle(DJStringUtil.localize("Refine", comment:"")).withTitleColor(UIColor.whiteColor()).withFontHeletica(16)
            filterBtn.setTitleColor(UIColor.defaultRed(), forState: .Highlighted)
            filterBtn.sizeToFit()
            filterBtn.frame = CGRectMake(0, 0, filterBtn.frame.size.width, 44)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterBtn)
            
            filterScrollViewBar.frame = CGRectMake(0, 0, view.frame.size.width, 60)
            filterScrollViewBar.backgroundColor = UIColor.whiteColor()
            filterScrollViewBar.contentInset = UIEdgeInsetsMake(15, 23, 15, 23)
            filterScrollViewBar.hidden = true
            mainCollectionView.addSubview(filterScrollViewBar)
        }
        
        mainCollectionView.backgroundColor = UIColor.whiteColor()
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.registerClass(TryOnClothCollectionCell.self, forCellWithReuseIdentifier: "cell")
        containterView.scrollView = mainCollectionView
        view.addSubview(containterView)
        
        mainCollectionView.addSubview(notfindBtn)
        notfindBtn.hidden = true
        notfindBtn.frame = CGRectMake(23, 0, view.frame.size.width - 46, 35)
        notfindBtn.setWhiteTitle()
        notfindBtn.withTitle(DJStringUtil.localize("Cannot Find What You Want?", comment:"")).withTitleColor(UIColor.whiteColor()).withFontHeleticaMedium(14)
        notfindBtn.addTarget(self, action: #selector(notfindBtnDidTapped), forControlEvents: UIControlEvents.TouchUpInside)
        sendfindClothesNetTask(true)
        
        self.notFindView.hidden = true
        view.addSubview(self.notFindView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        containterView.frame = view.bounds
        notFindView.frame = view.bounds
    }
    
    func notfindBtnDidTapped(){
        suggestView = SuggestionView(frame: view.bounds)
        suggestView?.delegate = self
        suggestView?.scaleShowAnimation(suggestView!.frame, startWidth: 1, time: 0.2, alpha: true, completion: nil)
        view.addSubview(suggestView!)
    }
    
    override func goBack() {
        if let view = filterView {
            if !view.hidden {
                title = vcTitle
                filterView?.hideAnimation()
                return
            }
        }
        super.goBack()
    }
    
    func filterBtnDidTap(){
        if filterView == nil {
            filterView = FindClothRefineView(frame: view.bounds, category : category!)
            filterView!.delegate = self
            filterView!.hidden = true
            filterView?.originSubCategoryId = originSubCategoryId
            filterView?.subCategoryId = selectedSubCategoryId
            filterView?.refreshLayout()
        }
        
        if filterView!.hidden {
            filterView?.showAnimation()
        }else{
            filterView?.hideAnimation()
            title = vcTitle
        }
        
        if ClothesDataContainer.sharedInstance.extractFilterIds(filterView!.selectedFilters) != ClothesDataContainer.sharedInstance.extractFilterIds(selectedFilter){
            filterView?.resetSelectedFilters(selectedFilter)
        }
        view.addSubview(filterView!)
//        DJStatisticsLogic.instance().addTraceLog(kStatisticsID_enter_find_cloth_result_refine)
    }
    
    func refineViewDone(refineView: FindClothRefineView) {
        filterView?.hideAnimation()
        
        if refineView.selectedFilters.count > 0 {
            filterScrollViewBar.hidden = false
        }else{
            filterScrollViewBar.hidden = true
        }
        
        if ClothesDataContainer.sharedInstance.extractFilterIds(refineView.selectedFilters) != ClothesDataContainer.sharedInstance.extractFilterIds(selectedFilter) || selectedSubCategoryId != filterView?.subCategoryId {
            selectedSubCategoryId = filterView?.subCategoryId
            selectedFilter = refineView.selectedFilters
            updateFilterBar()
            
            sendfindClothesNetTask(true)
        }else{
            mainCollectionView.contentOffset = CGPointMake(0, 0)
        }
    }
    
    func refineViewChanged(refineView: FindClothRefineView) {
        let task = FindClothesTryonNetTask()
        task.categoryID = category?.categoryId
        task.subcategoryID = refineView.subCategoryId
        task.filterIds = extractFilterIds(refineView.selectedFilters)
        task.pageSize = 1
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
        MONetTaskQueue.instance().addTask(task)
    }
    
    func extractFilterIds(filterArray : [Filter]) -> [String]{
        var result = [String]()
        for filter in filterArray {
            result.append(filter.id)
        }
        return result
    }
    
    func updateFilterBar(){
        filterScrollViewBar.removeAllSubViews()
        selectedFilterBtns = [DJButton]()
        
        var oX : CGFloat = 0
        for item in selectedFilter {
            let filterBtn = DJButton()
            filterBtn.layer.cornerRadius = 15
            filterBtn.layer.borderColor = UIColor.blackColor().CGColor
            filterBtn.layer.borderWidth = 1
            filterBtn.property = item
            filterBtn.addTarget(self, action: #selector(TryonClothListViewController.selectedFilterBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            selectedFilterBtns.append(filterBtn)
            filterScrollViewBar.addSubview(filterBtn)
            
            let label = UILabel()
            label.withText(item.name).withFontHeletica(14).withTextColor(UIColor.blackColor())
            filterBtn.addSubview(label)
            label.sizeToFit()
            label.frame = CGRectMake(15, 0, label.frame.size.width, 30)
            
            let imageView = UIImageView(frame: CGRectMake(CGRectGetMaxX(label.frame) + 8, 10, 10, 10))
            imageView.image = UIImage(named: "FilterCloseIcon")
            filterBtn.addSubview(imageView)
            
            filterBtn.frame = CGRectMake(oX, 0, CGRectGetMaxX(imageView.frame) + 15, 30)
            
            oX += filterBtn.frame.size.width + 10
            if selectedFilter.indexOf(item) == selectedFilter.count - 1{
                oX -= 10
            }
        }
        filterScrollViewBar.contentSize = CGSizeMake(oX, 30)
    }
    
    func selectedFilterBtnDidTap(btn : DJButton)
    {
        let filter = btn.property as? Filter
        if filter == nil{
            return
        }
        for item in selectedFilter{
            if item.id == filter?.id {
                selectedFilter.removeAtIndex(selectedFilter.indexOf(item)!)
                break
            }
        }
        
        if selectedFilter.count == 0{
            filterScrollViewBar.hidden = true
        }else{
            filterScrollViewBar.hidden = false
        }
        
        updateFilterBar()
        sendfindClothesNetTask(true)
        
        title = vcTitle
    }
    
    func sendfindClothesNetTask(resetNetTask : Bool){
        MONetTaskQueue.instance().cancelTask(tryonClothNetTask)
        if resetNetTask {
            pageEnd = false
            tryonClothNetTask.pageIndex = 0
        }
        
        if pageEnd || category == nil{
            return
        }
        
        if tryonClothNetTask.pageIndex == 0 {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            }
        }
        
        if tryonClothNetTask.pageIndex > 0 {
            containterView.isLoadingMore = true
        }
        
        tryonClothNetTask.subcategoryID = selectedSubCategoryId
        tryonClothNetTask.categoryID = category!.categoryId
        tryonClothNetTask.filterIds = ClothesDataContainer.sharedInstance.extractFilterIds(selectedFilter)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: tryonClothNetTask.uri())
        MONetTaskQueue.instance().addTask(tryonClothNetTask)
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if let t = task as? FindClothesTryonNetTask {
//            if t.pageSize == 1 {
                filterView?.showItemNumber(t.total)
                //title = "\(t.totalClothesCount) Items"
//                return
//            }
        }
        
        if task == tryonClothNetTask {
            pageEnd = tryonClothNetTask.ended
            if tryonClothNetTask.pageIndex == 0 {
                mainCollectionView.setContentOffset(CGPointZero, animated: true)
                netTaskResults = tryonClothNetTask.clothesList
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
            }else {
                netTaskResults += tryonClothNetTask.clothesList
                containterView.isLoadingMore = false
            }
            mainCollectionView.reloadData()
            
            if netTaskResults.count == 0 {
                self.notFindView.hidden = false
                view.addSubview(filterScrollViewBar)
            }else{
                mainCollectionView.addSubview(filterScrollViewBar)
                self.notFindView.hidden = true
            }
            
            if pageEnd {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  Int64(0.1) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                    self.notfindBtn.hidden = false
                    self.notfindBtn.frame = CGRectMake(self.notfindBtn.frame.origin.x, self.mainCollectionView.contentSize.height - 33, self.notfindBtn.frame.size.width, self.notfindBtn.frame.size.height)
                }
            }else{
                self.notfindBtn.hidden = true
            }
        }else if task == uploadNetTask {
            let upTask = task as! DJUploadFileNetTask
            uploadNetTask?.property = nil
            sendFeedbackNetTask(upTask.fileUrl)
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == tryonClothNetTask {
            containterView.isLoadingMore = false
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        }
    }
}


extension TryonClothListViewController: SuggestionViewDelegate, UINavigationControllerDelegate, DJTakePhotoViewControllerDelegate{
    func suggestionViewReportDidClickSubmit(suggestionView: SuggestionView) {
        if suggestionView.image != nil {
            uploadNetTask = DJUploadFileNetTask()
            uploadNetTask?.property = self //to avoid instance release while still has not finish feedbacknettask
            uploadNetTask!.data = UIImageJPEGRepresentation(suggestionView.image!, 0.5)
            MONetTaskQueue.instance().addTaskDelegate(self, uri: uploadNetTask!.uri())
            MONetTaskQueue.instance().addTask(uploadNetTask)
        }else{
            sendFeedbackNetTask(nil)
        }
        suggestionView.removeAnimation()
    }
    
    func suggestionViewReportDidClickCancel(suggestionView: SuggestionView) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func sendFeedbackNetTask(imageUrl :String?){
        if suggestView == nil {
            return
        }
        
        feedbackNetTask = FeedbackNetTask()
        feedbackNetTask!.text = suggestView!.textView.text
        feedbackNetTask!.imageUrl = imageUrl
        MONetTaskQueue.instance().addTaskDelegate(self, uri: feedbackNetTask!.uri())
        MONetTaskQueue.instance().addTask(feedbackNetTask!)
    }
    
    func suggestionViewTakePhotoDidClick(suggestionView: SuggestionView){
        let takeP = DJTakePhotoViewController()
        takeP.delegate = self
        takeP.title = "My Cloth"
        takeP.maskRect = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - 85)
        self.navigationController?.presentViewController(UINavigationController(rootViewController: takeP), animated: true, completion: nil)
    }
    
    func takePhotoViewController(takePhototVC: DJTakePhotoViewController!, didUseImage image: UIImage!) {
        suggestView?.setSelectedImage(image)
        
        takePhototVC.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension TryonClothListViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return netTaskResults.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let clothSummary = netTaskResults[indexPath.row]

        if !clickClothReturn {
            pushClothDetailVC(clothSummary)
        }else{
            delegate?.tryonClothListViewControllerDidChooseCloth(self, product : clothSummary)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let clothSummary = netTaskResults[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TryOnClothCollectionCell
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
        
        cell.setClothName(clothSummary.name)
        cell.setBrandName(clothSummary.brandName)
        cell.product = clothSummary
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let clothSummary = netTaskResults[indexPath.row]
        let originSize = TryOnClothCollectionCell.calculateCellSize(clothSummary)
        return CGSizeMake(originSize.width, originSize.height - 20)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        if selectedFilter.count == 0 {
            return UIEdgeInsetsMake(20, 23, 60, 23)
        }else{
            return UIEdgeInsetsMake(60, 23, 60, 23)
        }
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.size.height - scrollView.contentInset.bottom + scrollView.contentInset.top{
            if !containterView.isLoadingMore {
                tryonClothNetTask.nextPage()
                sendfindClothesNetTask(false)
            }
        }
    }
    
}
