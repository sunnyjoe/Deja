//
//  ByPatternResultViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 2/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ByPatternResultViewController: DJBasicViewController, MONetTaskDelegate, CategoryViewDelegate {
    var categories = [ClothCategory]()//First Level
   
    let categoryView = CategoryView(style: .White)
    
    var categoryIdToView = [String: UICollectionView]()
    var currentCategoryView: UIScrollView?
    
    var categoryIdToDataSource = [String: ResultDataSource]()
    
    var categoryIdToFilters = [String : [Filter]]()
    var categoryIdToSelectedSubCategoryId = [String : String]()
    
    var mark = ""
    var end = false
    
    private let refineView = RefineButton()
 
    var searchResultEmptyView : ClothNotFindView?
    
    init(clothesList : [Clothes], categoryIds : [String]) {
        super.init(nibName: nil, bundle: nil)

        let allCate = ConfigDataContainer.sharedInstance.getConfigCategoryById("0")!
        self.categories = [allCate]
//        for (i, categoryId) in categoryIds.enumerate() {
//            for c in origCates {
//                if c.categoryId == categoryId {
//                    categories.append(c)
//                }
//            }
            let datasource = ResultDataSource()
            datasource.containerViewController = self
            categoryIdToDataSource[allCate.categoryId] = datasource
            datasource.categoryId = allCate.categoryId
          //  if i == 0 {
                datasource.clothesList = clothesList
          //  }
       // }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = DJStringUtil.localize("Search Results", comment:"")
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(categoryView)
    
        categoryView.backgroundColor = UIColor.blackColor()
  
        constrain(categoryView) { categoryView in
            categoryView.top == categoryView.superview!.top
            categoryView.left == categoryView.superview!.left
            categoryView.right == categoryView.superview!.right
            categoryView.bottom == categoryView.superview!.bottom
        }
        
        searchResultEmptyView = ClothNotFindView(frame: CGRectMake(0, 220, view.bounds.width, view.bounds.height - 40), text: DJStringUtil.localize("Sorry, no item found.", comment:""), showNotFoundButton : false)
        searchResultEmptyView?.hidden = true
        view.addSubview(searchResultEmptyView!)
        
        categoryView.searchCategories = categories
        categoryView.delegate = self
        
        refineView.frame = CGRectMake(view.frame.size.width - 110 + 35 / 2, view.frame.size.height - 90 - 64, 110, 35)
        refineView.addTapGestureTarget(self, action: #selector(refineBtnDidTapped))
        view.addSubview(refineView)
        
        showHomeButton(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    func refineBtnDidTapped() {
        let filterViewController = FilterViewController()
        let category = categoryView.currentCategory
        filterViewController.category = category
        filterViewController.subCategoryId = categoryIdToSelectedSubCategoryId[category!.categoryId]
        if let filters = categoryIdToFilters[category!.categoryId] {
            filterViewController.selectedFilters = filters
        }
        filterViewController.priceFilterEnabled = false
        filterViewController.brandFilterEnabled = false
        filterViewController.delegate = self
        let task = AddByPatternMoreNetTask()
        task.mark = mark
        filterViewController.fetchNetTask = task
        self.presentViewController(UINavigationController(rootViewController: filterViewController), animated: true, completion: nil)
        DJStatisticsLogic.instance().addTraceLog(.Findresult_Click_Refine)
    }
    
    func setRefineStatus() {
        let category = categoryView.currentCategory
        if categoryIdToFilters[category!.categoryId]?.count > 0 || categoryIdToSelectedSubCategoryId[category!.categoryId] != nil {
            refineView.selected = true
        }else {
            refineView.selected = false
        }
    }
    
    func tapTitle(ges : UITapGestureRecognizer) {
        currentCategoryView?.setContentOffset(CGPointZero, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func categoryViewCategoryDidChange(categoryView: CategoryView){
        let categoryId = categoryView.currentCategory!.categoryId
        currentCategoryView = categoryIdToView[categoryId]
        
        if categoryIdToDataSource[categoryView.currentCategory!.categoryId]!.clothesList.count == 0 {
            sendNetTask(categoryView.currentCategory!.categoryId)
        }
        titleLabel?.text = DJStringUtil.localize("Search Results", comment:"")
        setRefineStatus()
    }
    
    func categoryForView(categoryView:CategoryView, category:ClothCategory) -> UIView{
        let collectionView =  UICollectionView(frame: CGRectZero, collectionViewLayout: CHTCollectionViewWaterfallLayout())
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = categoryIdToDataSource[category.categoryId]
        collectionView.dataSource = categoryIdToDataSource[category.categoryId]
        collectionView.registerClass(FindClothCollectionCell.self, forCellWithReuseIdentifier: "cell")
        
        categoryIdToView[category.categoryId] = collectionView
        
        return collectionView
    }
    
    func sendNetTask(categoryId : String, page : Int = 0) {
        let task = AddByPatternMoreNetTask()
        task.mark = mark
        task.pageIndex = page
        
        task.mainCategory = Int(categoryId)!
        
        task.categoryID = categoryId
        task.subcategoryID = categoryIdToSelectedSubCategoryId[categoryId]
        
        if let filters = categoryIdToFilters[categoryId] {
            task.filterIds = filters.map{ $0.id }
        }else {
            task.filterIds = []
        }
        
        MONetTaskQueue.instance().addTask(task)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: AddByPatternMoreNetTask.uri())
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if let t = task as? AddByPatternMoreNetTask {
            if t.pageSize == 1 {
                return
            }
            
            if let collectionView = categoryIdToView[t.mainCategory.description] {
                if t.pageIndex == 0 {
                    categoryIdToDataSource[t.mainCategory.description]?.clothesList = t.clothesList
                    collectionView.contentOffset = CGPointZero
                    
                    if (t.clothesList.count == 0) {
                        searchResultEmptyView?.hidden = false
                    }else {
                        searchResultEmptyView?.hidden = true
                    }
                }else {
                    categoryIdToDataSource[t.mainCategory.description]?.clothesList.appendContentsOf(t.clothesList)
                }
                collectionView.reloadData()
                categoryIdToDataSource[t.mainCategory.description]?.ended = t.ended
                categoryIdToDataSource[t.mainCategory.description]?.currentPage = t.pageIndex
                categoryIdToDataSource[t.mainCategory.description]?.loading = false
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        
        if let t = task as? AddByPatternMoreNetTask {
            MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Can't find more results", comment:""), animated: true)
            if t.pageSize == 1 {
                return
            }
            if categoryIdToView[t.mainCategory.description] != nil {
                if t.pageIndex != 0 {
                    categoryIdToDataSource[t.mainCategory.description]?.loading = false
                }
            }
        }
    }
    
}

extension ByPatternResultViewController : FilterViewControllerDelegate {
    func filterDone(controller: FilterViewController) {
        categoryIdToFilters[controller.category!.categoryId] = controller.selectedFilters
        categoryIdToSelectedSubCategoryId[controller.category!.categoryId] = controller.subCategoryId
        sendNetTask(categoryView.currentCategory!.categoryId)
        setRefineStatus()
    }
}

class ResultDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    var clothesList = [Clothes]()
    
    weak var containerViewController : ByPatternResultViewController?
    
    var ended = false
    var currentPage = 0
    var loading = false
    
    var categoryId = ""
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothesList.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let clothSummary = clothesList[indexPath.row]
        HistoryDataContainer.sharedInstance.addClothesToHistory(clothSummary)

        let url = ConfigDataContainer.sharedInstance.getClothDetailUrl(clothSummary.uniqueID!)
        let v = ClothDetailViewController(URLString: url)
        containerViewController?.navigationController?.pushViewController(v, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let clothSummary = clothesList[indexPath.row]
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
        
        cell.setBrandName(clothSummary.brandName)
        cell.setClothName(clothSummary.name)
        cell.setPriceInfo(clothSummary.curentPrice as? Int, uprice: clothSummary.upPrice as? Int, currency: clothSummary.currency)
        cell.product = clothSummary
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let clothSummary = clothesList[indexPath.row]
        return FindClothCollectionCell.calculateCellSize(clothSummary)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 23, 20, 23)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.size.height - scrollView.contentInset.bottom + scrollView.contentInset.top{
            if !loading && clothesList.count > 0 && !ended{
                containerViewController?.sendNetTask(categoryId, page: currentPage + 1)
                loading = true
            }
            return
        }
    }
    
}
