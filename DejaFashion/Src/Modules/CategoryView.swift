//
//  CategoryView.swift
//  DejaFashion
//
//  Created by jiao qing on 8/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

 
protocol CategoryViewDelegate : NSObjectProtocol{
    func categoryViewCategoryDidChange(categoryView: CategoryView)
    func categoryForView(categoryView:CategoryView, category:ClothCategory) -> UIView
}

enum ColorStyle {
    case White
    case Default
}

class CategoryView: UIView, UIScrollViewDelegate
{
    static let categoryCellIdentifier = "categoryNameCollectionCellIndentifier"
    static let categoryCellWidth = 100
    static let categoryCellHeight : CGFloat = 46
    static let searchBarHeight = 40
    
    var categories = [ClothCategory]()
    var currentCategory : ClothCategory?
    weak var delegate : CategoryViewDelegate?
    var categoryIdToView = [String : UIView]()
    var contentView = UIScrollView()
    var categoriesView = UIScrollView()
    
    var categoryBtns = [UIButton]()
    var searchBar : UISearchBar?
    let underLine = UIView()
    
    var startCategoryId : String?
    
    var colorStyle = ColorStyle.Default
    
    var searchCategories: [ClothCategory]
        {
        get
        {
            return categories
        }
        set
        {
            categories = newValue
            if categories.count > 0 {
                updateCategoryView()
            }
        }
    }
    
    let lable = UILabel().withText("").withTextColor(UIColor.redColor())
    
    
    init(style : ColorStyle = .Default) {
        super.init(frame: CGRectZero)
        
        colorStyle = style
        
        self.addSubview(contentView)
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        contentView.pagingEnabled = true
        contentView.delegate = self
        contentView.scrollEnabled = false
        
//        self.addSubview(categoriesView)
        categoriesView.showsHorizontalScrollIndicator = false
        categoriesView.showsVerticalScrollIndicator = false
        categoriesView.indicatorStyle = .Black
        categoriesView.delegate = self
        
        if style == ColorStyle.White {
            categoriesView.backgroundColor = UIColor(fromHexString: "ffffff")
        }else {
            categoriesView.backgroundColor = UIColor.defaultBlack()
        }
        
        underLine.backgroundColor = UIColor(fromHexString: "ebecec")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        categoriesView.frame = CGRectMake(0, 0, self.frame.size.width, CategoryView.categoryCellHeight)
//        contentView.frame = CGRectMake(0, CategoryView.categoryCellHeight, self.frame.size.width, self.frame.size.height - CategoryView.categoryCellHeight)
        categoriesView.frame = CGRectMake(0, 0, 0,0)
        contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        buildContentScrollView()
        if startCategoryId != nil {
            for cate in categories {
                if cate.categoryId == startCategoryId {
                    updateHighlightedView(scrollToCategory(cate),animated: false)
                    break
                }
            }
        }else{
            if categories.count > 0 {
                updateHighlightedView(scrollToCategory(categories[0]),animated: false)
            }
        }
    }
    
    func addSearchBar(searchBar : UISearchBar){
        self.addSubview(searchBar)
        self.searchBar = searchBar
    }
    
    func updateCategoryView(){
        categoriesView.removeAllSubViews()
        categoryBtns = [UIButton]()
        categoriesView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        var oX : CGFloat = 23
        var index = 0
        for item in categories
        {
            let nameBtn = DJButton(frame: CGRectMake(oX, 10, 50, CGFloat(CategoryView.categoryCellHeight) - 20))
            nameBtn.withTitle(item.name)
            nameBtn.addTarget(self, action: #selector(CategoryView.categoryBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            nameBtn.tag = index
            categoriesView.addSubview(nameBtn)
            categoryBtns.insert(nameBtn, atIndex: categoryBtns.count)
            
            if currentCategory?.categoryId == item.categoryId {
                nameBtn.withFontHeleticaMedium(16)
                if colorStyle == .White {
                    nameBtn.withTitleColor(DJCommonStyle.Color41)
                }else {
                    nameBtn.withTitleColor(UIColor.whiteColor())
                }
                
                nameBtn.sizeToFit()
                if currentCategory == nil {
                    underLine.frame = CGRectMake(oX, categoriesView.frame.size.height - 1.5, nameBtn.frame.size.width, 1.5)
                }
                
                nameBtn.frame = CGRectMake(oX, 9, nameBtn.frame.size.width, nameBtn.frame.size.height)
            }else{
                nameBtn.withFontHeletica(16)
                if colorStyle == .White {
                    nameBtn.withTitleColor(DJCommonStyle.Color81)
                }else {
                    nameBtn.withTitleColor(UIColor.lightGrayColor())
                }
                
                nameBtn.sizeToFit()
            }
            
            oX += CGFloat(nameBtn.frame.size.width)
            if index < categories.count {
                oX += 25
            }else{
                oX += 23
            }
            
            index += 1
        }
        categoriesView.addSubview(underLine)
        categoriesView.contentSize = CGSizeMake(oX, CGFloat(CategoryView.categoryCellHeight))
    }
    
    func categoryBtnDidTap(btn : DJButton)
    {
        let index = btn.tag
        if index < categories.count {
            updateHighlightedView(scrollToCategory(categories[index]))
        }
    }
    
    func buildContentScrollView(){
        for cate in categories {
            let theView = categoryIdToView[cate.categoryId]
            if theView == nil{
                if let createdView = delegate?.categoryForView(self, category: cate){
                    self.categoryIdToView[cate.categoryId] = createdView
                    createdView.frame = CGRectMake(CGFloat(categories.indexOf(cate)!) * contentView.frame.size.width, 0, contentView.frame.size.width, contentView.frame.size.height)
                    self.contentView.addSubview(createdView)
                }
            }
        }
        contentView.contentSize = CGSizeMake(contentView.frame.size.width * CGFloat(categories.count), contentView.frame.size.height)
    }
    
    func scrollToCategory(category : ClothCategory) -> Int{
        var index = 0
        for item in categories
        {
            if item.categoryId == category.categoryId {
                break
            }
            index += 1
        }
        if index >= self.categories.count {
            return index
        }
        
        currentCategory = category
        delegate?.categoryViewCategoryDidChange(self)
        contentView.setContentOffset(CGPointMake(CGFloat(index) * contentView.frame.size.width, 0), animated: true)
        updateCategoryView()
        return index
    }
    
    func updateHighlightedView(index : Int, animated : Bool = true){
        
        if index >= self.categories.count {
            return
        }
        
        let btn = categoryBtns[index]
        
        var nextX = btn.frame.origin.x - (categoriesView.frame.size.width - btn.frame.size.width) / 2
        var maxX = categoriesView.contentSize.width - categoriesView.frame.size.width
        
        maxX = maxX < 0  ? 0 : maxX
        nextX = nextX < 0 ? 0 : nextX
        nextX = min(nextX, maxX)
        
        if animated {
            UIView.animateWithDuration(0.2, animations: {
                self.underLine.frame = CGRectMake(btn.frame.origin.x, self.categoriesView.frame.size.height - 1.5, btn.frame.size.width, 1.5)
                self.categoriesView.setContentOffset(CGPointMake(nextX, 0),animated: false)
            })
        }else {
            self.underLine.frame = CGRectMake(btn.frame.origin.x, self.categoriesView.frame.size.height - 1.5, btn.frame.size.width, 1.5)
            self.categoriesView.setContentOffset(CGPointMake(nextX, 0),animated: false)
        }
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView != contentView {
            return;
        }
        
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if index < 0 || index >= self.categories.count {
            return
        }
        updateHighlightedView(scrollToCategory(categories[index]))
    }
    
}
