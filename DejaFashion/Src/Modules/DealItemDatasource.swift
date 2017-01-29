//
//  DealItemDatasource.swift
//  DejaFashion
//
//  Created by DanyChen on 25/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

@objc protocol DealItemListDelegate  {
    func scrollViewDidScrollToEnd()
    
    func scrollViewDidScroll(offsetY : CGFloat)
}

class PagedDealItemDatasource : NSObject, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    // filter info
    var subCategoryId : String?
    var selectedFilters = [Filter]()
    var lowerPrice : Int = 0
    var higherPrice : Int = 0
    var brandInfo : BrandInfo?
    
    var items = [Clothes]()
    private let paddingOfImage : CGFloat = 25
    var selectedIds = Set<String>()
    
    weak var delegate : DealItemListDelegate?
    unowned var collectionView : UICollectionView
    
    var netTask : DealsNetTask?
    var currentPage = 0
    var ended = false
    
    init(collectionView : UICollectionView) {
        
        self.collectionView = collectionView
        
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.row]
        HistoryDataContainer.sharedInstance.addClothesToHistory(item)

        let url = ConfigDataContainer.sharedInstance.getClothDetailUrl(item.uniqueID!)
        let v = ClothDetailViewController(URLString: url)
        collectionView.viewController().navigationController?.pushViewController(v, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Deals_Click_Item)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DealClothCollectionCell
        let pdt = items[indexPath.row]
        cell.product = pdt
        
        cell.setBrandName(pdt.brandName)
        cell.setPriceInfo(pdt.curentPrice as? Int, uprice: pdt.upPrice as? Int, currency: pdt.currency)
        cell.setClothName(pdt.name)
        cell.setImageUrl(pdt.thumbUrl, colorValue: pdt.thumbColor)
        cell.setDiscount(pdt.discountPercent as? Int)
    
        if WardrobeDataContainer.sharedInstance.isInWardrobe(pdt.uniqueID!) {
            cell.descIcon.hidden = false
        }else {
            cell.descIcon.hidden = true
        }
//        cell.buyButton.addTarget(self, action: #selector(PagedDealItemDatasource.tapBuy(_:)), forControlEvents: .TouchUpInside)
//        cell.buyButton.tag = indexPath.row
        return cell
    }
    
    class ClothesView : UIView {
        var imageView = UIImageView()
        var brandLabel = UILabel().withFontHeletica(14).withTextColor(DJCommonStyle.BackgroundColor)
        var borderView = UIView()
        var discountPriceLabel = UILabel().withFontHeletica(14).withTextColor(DJCommonStyle.ColorRed)
        var originPriceLabel = UILabel().withFontHeletica(14).withTextColor(DJCommonStyle.ColorCE)
    }
    
//    func tapBuy(button : UIButton) {
//        let index = button.tag
//        let item = items[index]
//        if let url = item.shopUrl {
//            let v = ProductPurchaseViewController(URLString: url)
//            collectionView.viewController().navigationController?.pushViewController(v, animated: true)
//        }
//        DJStatisticsLogic.instance().addTraceLog(.Deals_Click_Shop)
//    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let clothSummary = items[indexPath.row]
        return FindClothCollectionCell.calculateCellSize(clothSummary)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 22
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 19
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height)
        {
            delegate?.scrollViewDidScrollToEnd()
        }
        delegate?.scrollViewDidScroll(scrollView.contentOffset.y)
    }
}
