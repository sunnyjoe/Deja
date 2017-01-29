//
//  CategoryIndexableViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 3/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class CategoryIndexableViewController: DJBasicViewController
{
    let categoryView = CategoryView()
    var categoryIdToView = [String: UIView]()
    var currentCategoryView: UIView?
    
    var needAllCategory = false
        
    init(beginCategoryId : String?) {
        super.init(nibName: nil, bundle: nil)
//        categoryView.startCategoryId = beginCategoryId
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = DJStringUtil.localize("Categories", comment:"")
        
        view.addSubview(categoryView)
        constrain(categoryView) { categoryView in
            categoryView.top == categoryView.superview!.top - 10
            categoryView.left == categoryView.superview!.left
            categoryView.right == categoryView.superview!.right
            categoryView.bottom == categoryView.superview!.bottom
        }
        var origCates = ConfigDataContainer.sharedInstance.getConfigCategory()
        
        if needAllCategory {
            let allCategory = ClothCategory()
            allCategory.categoryId = "0"
            allCategory.name = DJStringUtil.localize("All", comment:"")
            origCates.insert(allCategory, atIndex: 0)
        }
        
        categoryView.searchCategories = origCates
        categoryView.delegate = self
    }
}

extension CategoryIndexableViewController : CategoryViewDelegate {
    // DJCategoriesViewDelegate
    func categoryViewCategoryDidChange(categoryView: CategoryView) {
        let categoryId = categoryView.currentCategory!.categoryId
        currentCategoryView = categoryIdToView[categoryId]
    }
    
    func categoryForView(categoryView: CategoryView, category: ClothCategory)-> UIView {
        return UIView()
    }
}
