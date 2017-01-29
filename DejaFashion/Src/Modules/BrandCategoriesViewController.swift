
//
//  BrandCategoriesViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 23/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class BrandCategoriesViewController: DJBasicViewController, MONetTaskDelegate, CategorySelectViewDelegate {
    private var brandInfo : BrandInfo?
    
    let cateNetTask = BrandGetCategoryNetTask()
    private let brandCV = CategorySelectView()
    
    init(brandIf : BrandInfo?) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.brandInfo = brandIf
        if let tmp = brandIf{
            cateNetTask.brandId = tmp.id
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if brandInfo != nil{
            title = brandInfo!.name
        }else{
            title = DJStringUtil.localize("All Brands", comment:"")
        }
        
//        let narLabel = createTitleLabel(DJStringUtil.localize("New Arrivals", comment: ""))
//        view.addSubview(narLabel)
//        narLabel.addTapGestureTarget(self, action: #selector(newArrivalDidTapped))
//        
//        let border = UIView(frame : CGRectMake(0, CGRectGetMaxY(narLabel.frame) - 0.5, view.frame.size.width, 0.5))
//        border.backgroundColor = DJCommonStyle.ColorCE
//        view.addSubview(border)
        
        brandCV.delegate = self
        view.addSubview(brandCV)
        
        MONetTaskQueue.instance().addTask(cateNetTask)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: cateNetTask.uri())
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        brandCV.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showHomeButton(true)
    }
 
    func createTitleLabel(name : String) -> UILabel{
        let label = UILabel(frame : CGRectMake(23, 0, view.frame.size.width - 23 * 2, 50))
        label.withText(name).withFontHeleticaMedium(16).withTextColor(UIColor.defaultBlack())
        return label
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == cateNetTask{
            MBProgressHUD.hideHUDForView(view, animated: true)
            let categories = cateNetTask.categoryIds
            if categories.count > 0{
                var configCates = [ClothCategory]()
                for oneId in categories{
                    if let cate = ConfigDataContainer.sharedInstance.getConfigCategoryById(oneId){
                        configCates.append(cate)
                    }
                }
                brandCV.resetData(configCates, extraHeader: DJStringUtil.localize("New Arrivals", comment:""))
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == cateNetTask{
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
    
    func categorySelectViewDidClickExtraHeader(categorySelectView: CategorySelectView) {
        let enterC = ClothResultCondition()
        enterC.filterCondition.isNewArrival = true
        if let tmp = brandInfo{
            enterC.filterCondition.brand = tmp.copy() as? BrandInfo
        }
        
        let resultVC = FindClothResultViewController(enterInfo : enterC)
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func categorySelectViewDidSelectSubCategory(categorySelectView: CategorySelectView, subCategory: ClothSubCategory?) {
        
        let enterC = ClothResultCondition()
        enterC.filterCondition.brand = self.brandInfo
        enterC.filterCondition.subCategory = subCategory
        
        let resultVC = FindClothResultViewController(enterInfo : enterC)
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
}


