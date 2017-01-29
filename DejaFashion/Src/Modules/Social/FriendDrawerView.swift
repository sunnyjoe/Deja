//
//  FriendDrawerView.swift
//  DejaFashion
//
//  Created by DanyChen on 23/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class FriendDrawerView: DrawerView {
    
    let defaultLayout = CHTCollectionViewWaterfallLayout()
    var defaultDelegate : SimpleDelegate?
    
    let layout = CHTCollectionViewWaterfallLayout()
    
    let emptyView = UILabel().withText("No items.").withFontHeletica(17).withTextColor(DJCommonStyle.BackgroundColor).textCentered()
    
    private let paddingOfImage : CGFloat = 25
    
    override var sectionInset : UIEdgeInsets {
        didSet {
            defaultLayout.sectionInset = sectionInset
        }
    }
    
    private var clothesCollectionView : UICollectionView!
    
    override var items : [Clothes]? {
        didSet {
            let count = items == nil ? 0 : items!.count
            clothesCollectionView.reloadData()
            if (count > 0) {
                clothesCollectionView.hidden = false
                emptyView.hidden = true
            }else {
                clothesCollectionView.hidden = true
                emptyView.hidden = false
            }
        }
    }
    
    func enableEmptyView() {
        addSubview(emptyView)
    }

    override var scrollEnabled : Bool {
        didSet {
            clothesCollectionView.scrollEnabled = scrollEnabled
        }
    }
    
    override weak var panGestureRecognizer : UIPanGestureRecognizer? {
        didSet {
            if panGestureRecognizer != nil {
                addGestureRecognizer(panGestureRecognizer!)
            }
        }
    }
    
    override func showContent() {
        addSubviews(topAreaView, clothesCollectionView, cardColorBackgroud)
        refresh()
        clothesCollectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func hideContent() {
        clothesCollectionView.removeFromSuperview()
    }
    
    override func refresh() {
        clothesCollectionView.reloadData()
    }
    
    override func scrollContentToTop() {
        clothesCollectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override init(frame: CGRect) {
        defaultLayout.columnCount = 2
        defaultLayout.sectionInset = UIEdgeInsetsMake(20, 23, 20, 23)
        clothesCollectionView = UICollectionView(frame: CGRectMake(0, topAreaHeight, ScreenWidth, ScreenHeight - topAreaHeight - 20), collectionViewLayout:  defaultLayout)
        clothesCollectionView.backgroundColor = UIColor.whiteColor()
        emptyView.hidden = true
        super.init(frame: frame)
        userInteractionEnabled = true
        addTapGestureTarget(self, action: #selector(FriendDrawerView.consumeTap))
        
        topAreaView.frame = CGRectMake(0, 0, ScreenWidth, topAreaHeight)
        
        defaultDelegate = SimpleDelegate(drawerView: self)
        
        clothesCollectionView.registerClass(FindClothCollectionCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        clothesCollectionView.showsVerticalScrollIndicator = false
        clothesCollectionView.dataSource = defaultDelegate
        clothesCollectionView.alwaysBounceVertical = true
        clothesCollectionView.delegate = defaultDelegate
        clothesCollectionView.backgroundColor = UIColor.whiteColor()
    }
    
    func consumeTap() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5).CGPath
        clothesCollectionView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        emptyView.frame = CGRectMake(0, 0, self.frame.width, 100)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SimpleDelegate : NSObject, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout{
    var ItemSize : CGSize {
        return DrawerView.ItemSize
    }
    private let paddingOfImage : CGFloat = 25
    
    private unowned let drawerView : DrawerView
    
    init(drawerView : DrawerView) {
        self.drawerView = drawerView
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawerView.items == nil ? 0 : drawerView.items!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! FindClothCollectionCell
        let pdt = drawerView.items![indexPath.row]
        cell.product = pdt
        
        cell.setBrandName(pdt.brandName)
        cell.setClothName(pdt.name)
        cell.setImageUrl(pdt.thumbUrl, colorValue: pdt.thumbColor)
        cell.addTapGestureTarget(self, action: #selector(SimpleDelegate.tapItem(_:)))
        cell.tag = indexPath.row
//        if WardrobeDataContainer.sharedInstance.isInWardrobe(pdt.uniqueID!) {
//            cell.descIcon.hidden = false
//        }else {
//            cell.descIcon.hidden = true
//        }
        if pdt.isNew {
            cell.newAddedLabel.hidden = false
        }else {
            cell.newAddedLabel.hidden = true
        }
        return cell
    }
    
    
    func tapItem(reg : UITapGestureRecognizer) {
        if let index = reg.view?.tag {
            
            let realIndex = index
            
            if index > drawerView.items?.count {
                return
            }
            if let item = drawerView.items?[realIndex] {
                if let id = item.uniqueID {
                    let url = ConfigDataContainer.sharedInstance.getClothDetailUrl(id)
                    let v = ClothDetailViewController(URLString: url)
                    HistoryDataContainer.sharedInstance.addClothesToHistory(item)

                    drawerView.viewController().navigationController?.pushViewController(v, animated: true)
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let clothSummary = drawerView.items![indexPath.row]
        return FindClothCollectionCell.calculateCellSize(clothSummary)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 22
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 19
    }
}
