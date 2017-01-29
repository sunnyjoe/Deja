//
//  FilterViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 27/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate : NSObjectProtocol {
    func filterDone(controller : FilterViewController)
}

class FilterViewController: DJBasicViewController {
    
    var category : ClothCategory?
    var subCategoryId : String?
    var selectedFilters = [Filter]()
    var lowerPrice : Int = 0
    var higherPrice : Int = 0
    var brandInfo : BrandInfo?
    
    var priceFilterEnabled = false
    var brandFilterEnabled = true
    
    var filterView : FindClothRefineView?
    
    weak var delegate : FilterViewControllerDelegate?
    
    var fetchNetTask : FilterableNetTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let c = category {
            title = c.name
            filterView = FindClothRefineView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height - 64), category: c, priceFilterEnable: priceFilterEnabled, brandFilterEnable: brandFilterEnabled)
            filterView?.delegate = self
            
            filterView?.subCategoryId = subCategoryId
            filterView?.resetSelectedFilters(selectedFilters)
            
            filterView?.priceViewContainer?.setPrice(CGFloat(lowerPrice), higherPrice: CGFloat(higherPrice))
            
            filterView?.brandViewContainer?.selectedBrand = brandInfo
            
            filterView?.refreshLayout()
            
            refineViewChanged(filterView!)
            view.addSubview(filterView!)
        }
        setCancelLeftBarItem()
        addRightResetButton()
//        let vcName = DJAppCall.topViewControllName()
//        DJStatisticsLogic.instance().addTraceLog(kStatisticsID_refine_page_enter, withParameter: ["vc" : vcName])
    }
    
    func addRightResetButton() {
        let rightIcon = UIControl(frame: CGRectMake(0, 0, 60, 44))
        let rightLabel = DJButton(frame: CGRect(x: 10, y: 9, width: 60, height: 25)).withFontHeletica(15).withTitle(DJStringUtil.localize("Reset", comment: "")).withHighlightTitleColor(UIColor.gray81Color())
        rightIcon.addSubview(rightLabel)
        rightLabel.addTapGestureTarget(self, action: #selector(FilterViewController.resetFilter))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightIcon)
    }
    
    func resetFilter() {
        self.filterView?.resetBtnDidTap()
    }
}

extension FilterViewController : FindClothRefineViewDelegate {
    func refineViewDone(refineView: FindClothRefineView) {
        delegate?.filterDone(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refineViewChanged(refineView: FindClothRefineView) {
        selectedFilters = refineView.selectedFilters
        subCategoryId = refineView.subCategoryId
        if let priceFilter = refineView.priceViewContainer {
            lowerPrice = priceFilter.lowerPrice
            higherPrice = priceFilter.higherPrice
        }
        brandInfo = refineView.brandViewContainer?.selectedBrand
        
        sendFetchFilteredClothesCountTask()
    }
    
    func sendFetchFilteredClothesCountTask() {
        if let task = fetchNetTask {
            task.pageSize = 1
            task.categoryID = category?.categoryId
            task.subcategoryID = subCategoryId
            
            task.filterIds = selectedFilters.map{ $0.id }

            if brandFilterEnabled {
                task.brandID = brandInfo?.id
            }
            
            if priceFilterEnabled {
                task.priceMin = lowerPrice
                task.priceMax = higherPrice
            }
            
            MONetTaskQueue.instance().addTask(task)
            MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
        }
    }
    
}

extension FilterViewController : MONetTaskDelegate {
    func netTaskDidEnd(task: MONetTask!) {
        if let t = task as? FilterableNetTask {
            if t.pageSize == 1 {
                  filterView?.showItemNumber(t.total)
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        
    }
}
