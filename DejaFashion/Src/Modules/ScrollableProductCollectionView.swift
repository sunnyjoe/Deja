//
//  ScrollableProductCollectionView.swift
//  DejaFashion
//
//  Created by jiao qing on 7/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

@objc protocol ScrollableProductCollectionViewDelegate : NSObjectProtocol{
    func scrollableProductCollectionViewDidSelect(spcv: ScrollableProductCollectionView, product : Clothes)
    func scrollableProductCollectionViewNeedLoadMore(spcv: ScrollableProductCollectionView, index : Int)
    func scrollableProductCollectionViewDidScrollToIndex(spcv: ScrollableProductCollectionView, index : Int)
}

class ScrollableProductCollectionView: UIView {
    private let scrollView = UIScrollView()
    private var cateView = ScrollableCategoryView()
    weak var delegate : ScrollableProductCollectionViewDelegate?
    
    private var categories = [String]()
    private var cateProducts = [[Clothes]]()
    
    private var emptyView = UIView()
    private var collectionViewDic = [Int : ProductCollectionView]()
    private var currentCateIndex : Int?
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        
        cateView.delegate = self
        addSubview(cateView)
        constrain(cateView) { cateView in
            cateView.top == cateView.superview!.top
            cateView.left == cateView.superview!.left
            cateView.right == cateView.superview!.right
        }
        NSLayoutConstraint(item: cateView, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: 45).active = true
        
        addSubview(scrollView)
        scrollView.delegate = self
        constrain(scrollView, cateView) { scrollView, cateView in
            scrollView.top == cateView.bottom
            scrollView.left == scrollView.superview!.left
            scrollView.right == scrollView.superview!.right
            scrollView.bottom == scrollView.superview!.bottom
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCategory(cates : [String]){
        setCategory(cates, defaultCateIndex: 0)
    }
    
    func setCategory(cates : [String], defaultCateIndex : Int){
        categories = cates
        if cates.count == 0{
            return
        }
        currentCateIndex = defaultCateIndex
        cateView.resetInfos(categories)
        cateView.scrollToIndex(defaultCateIndex)
        
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentSize = CGSizeMake(CGFloat(categories.count) * UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - 64 - 45)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func setCategoryScrollView(index : Int, products : [Clothes], scrollToTop : Bool = false, headerInfo : String? = nil){
        let oX  = CGFloat(index) * UIScreen.mainScreen().bounds.size.width
        
        var tmpV = collectionViewDic[index]
        if tmpV == nil {
            let list = ProductCollectionView(frame: CGRectMake(oX, 0, frame.size.width, scrollView.contentSize.height))
            scrollView.addSubview(list)
            list.delegate = self
            collectionViewDic[index] = list
            tmpV = list
        }
        tmpV!.headerInfo = headerInfo
        tmpV!.products = products
        tmpV!.reloadData()
        if scrollToTop{
            tmpV!.scrollToTheTop()
        }

        scrollView.setContentOffset(CGPointMake(CGFloat(index) * UIScreen.mainScreen().bounds.size.width, 0), animated: true)
        didScrollToIndex(index)
        
        if products.count == 0{
            tmpV!.showEmptyView(true)
        }else{
            tmpV!.showEmptyView(false)
        }
    }
    
    func didScrollToIndex(index : Int){
        currentCateIndex = index
        delegate?.scrollableProductCollectionViewDidScrollToIndex(self, index: index)
    }
}

extension ScrollableProductCollectionView: UIScrollViewDelegate, ScrollableCategoryViewDelegate, ProductCollectionViewDelegate{
    func scrollableCategoryViewDidSelectedIndex(scrollableCategoryView: ScrollableCategoryView, selectedIndex: Int) {
        scrollView.setContentOffset(CGPointMake(CGFloat(selectedIndex) * UIScreen.mainScreen().bounds.size.width, 0), animated: true)
        didScrollToIndex(selectedIndex)
    }
    
    func productCollectionViewNeedLoadMore(productView: ProductCollectionView) {
        if currentCateIndex == nil{
            return
        }
        delegate?.scrollableProductCollectionViewNeedLoadMore(self, index: currentCateIndex!)
    }
    
    func productCollectionViewDidSelect(productView: ProductCollectionView, product: Clothes) {
        delegate?.scrollableProductCollectionViewDidSelect(self, product: product)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView != self.scrollView {
            return;
        }
        
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if index < 0 || index >= categories.count {
            return
        }
        cateView.scrollToIndex(index)
        didScrollToIndex(index)
    }
    
}








