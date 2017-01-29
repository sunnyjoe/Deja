//
//  ProductCollectionView
//  DejaFashion
//
//  Created by jiao qing on 13/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

@objc protocol ProductCollectionViewDelegate : NSObjectProtocol{
    func productCollectionViewDidSelect(productView: ProductCollectionView, product : Clothes)
    
    optional func productCollectionViewNeedLoadMore(productView: ProductCollectionView)
}

class ProductCollectionView : UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    private let collectionViewLayout = CHTCollectionViewWaterfallLayout()
    var mainCollectionView : UICollectionView!
    weak var delegate : ProductCollectionViewDelegate?
    var products = [Clothes]()
    
    var headerInfo : String?
    private let searchResultLabel = UILabel()
    
    let emptyView = UIView()
    private var showPrice = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchResultLabel.withTextColor(DJCommonStyle.Color81).withFontHeletica(14).textCentered()
        
        mainCollectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        mainCollectionView.backgroundColor = UIColor.whiteColor()
        addSubview(mainCollectionView)
        mainCollectionView.registerClass(FindClothCollectionCell.self, forCellWithReuseIdentifier: "ProductCell")
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        
        emptyView.frame = bounds
        
        let reminderLabel = UILabel(frame: CGRectMake(20, 60, UIScreen.mainScreen().bounds.size.width - 40, 60))
        emptyView.addSubview(reminderLabel)
        reminderLabel.textAlignment = .Center
        reminderLabel.numberOfLines = 0
        reminderLabel.withFontHeletica(17).withTextColor(UIColor.defaultBlack()).withText("No Clothes Found.")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainCollectionView.frame = bounds
        searchResultLabel.frame = CGRectMake(0, 0, mainCollectionView.frame.size.width, 37)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showEmptyView(show : Bool){
        if show{
            addSubview(emptyView)
        }else{
            emptyView.removeFromSuperview()
        }
    }
    
    func showPrice(show : Bool){
        showPrice = show
        mainCollectionView.reloadData()
    }
    
    func reloadData(){
        if headerInfo != nil {
            searchResultLabel.withText(headerInfo!)
            mainCollectionView.addSubviews(searchResultLabel)
        }else{
            searchResultLabel.removeFromSuperview()
            searchResultLabel.withText(nil)
        }
        mainCollectionView.reloadData()
    }
    
    func scrollToTheTop(){
        mainCollectionView.setContentOffset(CGPointZero, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if delegate == nil {
            return
        }
        if indexPath.row == products.count - 1{
            if delegate!.respondsToSelector(#selector(ProductCollectionViewDelegate.productCollectionViewNeedLoadMore(_:))){
                delegate?.productCollectionViewNeedLoadMore!(self)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! FindClothCollectionCell
        let pdt = products[indexPath.row]
        cell.product = pdt
        
        cell.setBrandName(pdt.brandName)
        //        if !showPrice{
        cell.setClothName(pdt.name)
        //        }else{
        cell.setPriceInfo(pdt.curentPrice as? Int, uprice: pdt.upPrice as? Int, currency: pdt.currency)
        //        }
        cell.setImageUrl(pdt.thumbUrl, colorValue: pdt.thumbColor)
        
        if WardrobeDataContainer.sharedInstance.isInWardrobe(pdt.uniqueID!) {
            cell.descIcon.hidden = false
        }else {
            cell.descIcon.hidden = true
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let pdt = products[indexPath.row]
        delegate?.productCollectionViewDidSelect(self, product: pdt)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let clothSummary = products[indexPath.row]
        return FindClothCollectionCell.calculateCellSize(clothSummary)
    }
    
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if headerInfo != nil {
            return UIEdgeInsetsMake(37, 23, 20, 23)
        }
        return UIEdgeInsetsMake(20, 23, 20, 23)
    }
    
}
