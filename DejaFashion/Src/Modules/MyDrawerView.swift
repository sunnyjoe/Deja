//
//  DrawerView.swift
//  DejaFashion
//
//  Created by DanyChen on 9/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit
import Cartography
import SDWebImage
import KLCPopup
import RAReorderableLayout

let cardWidth = ScreenWidth
let topAreaHeight = 46 as CGFloat
let horizontalMargin : CGFloat = 23


protocol DrawerViewDelegate : class {
    func onClickDeleteButton(ids : [String])
}

class MyDrawerView: DrawerView {
        
    var popup : KLCPopup?
    
    var categoryId : String?
    
    let countLabel = UILabel().withFontHeletica(14).withTextColor(DJCommonStyle.BackgroundColor)
    let countLabelConstraint = ConstraintGroup()

    let editButton = UIButton().withTitle(DJStringUtil.localize("Edit", comment: "")).withFont(DJFont.fontOfSize(14)).withTitleColor(DJCommonStyle.Color41).withHighlightTitleColor(DJCommonStyle.ColorRed)
    let doneButton = UIButton().withTitle(DJStringUtil.localize("Cancel", comment: "")).withFont(DJFont.fontOfSize(14)).withTitleColor(DJCommonStyle.Color41).withHighlightTitleColor(DJCommonStyle.ColorRed)
    let deleteButton = UIButton().withTitle(DJStringUtil.localize("Remove", comment: "")).withFont(DJFont.fontOfSize(14)).withTitleColor(DJCommonStyle.ColorRed).withHighlightTitleColor(DJCommonStyle.Color41).withDisabledTitleColor(DJCommonStyle.Color81)
    let defaultLayout = CHTCollectionViewWaterfallLayout()
    var defaultDelegate : DefaultDelegate?
    
    private var floatingCell : View?
    let layout = CHTCollectionViewWaterfallLayout()
    
    let streetSnapIcon = UIImage(named: "StreetSnapIcon")

    private let paddingOfImage : CGFloat = 25
    
    override var sectionInset : UIEdgeInsets {
        didSet {
            defaultLayout.sectionInset = sectionInset
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            cardColorBackgroud.backgroundColor = backgroundColor
            if backgroundColor == nil {
                return
            }
            defaultLayout.sectionInset = UIEdgeInsetsMake(5, 23, 20, 23)
        }
    }
    
    override var editMode : Bool {
        didSet {
            if editMode {
                hideViews(countLabel, editButton)
                showViews(deleteButton, doneButton)
            }else {
                showViews(countLabel, editButton)
                hideViews(deleteButton, doneButton)
            }
            if editMode != oldValue {
                selectedIds.removeAll()
                deleteButton.enabled = false
                self.clothesCollectionView.reloadData()
            }
        }
    }
    
    weak var delegate : DrawerViewDelegate?
    private var clothesCollectionView : UICollectionView!
    private var selectedIds = Set<String>()
    
    override var items : [Clothes]? {
        didSet {
            let count = items == nil ? 0 : items!.count
            if count > 1 {
                countLabel.text = "\(count) items"
            }else {
                countLabel.text = "\(count) item"
            }
            clothesCollectionView.reloadData()
            if count == 0 {
                editMode = false
            }
            if count > 0 && !editMode {
                editButton.hidden = false
            }else {
                editButton.hidden = true
            }
            deleteButton.enabled = selectedIds.count > 0
            
            if oldValue?.count != items?.count {
                clothesCollectionView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }
    
    override func showContent() {
        addSubviews(topAreaView, clothesCollectionView, cardColorBackgroud)
        refresh()
//        clothesCollectionView.setContentOffset(CGPoint.zero, animated: false)
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
        defaultLayout.sectionInset = UIEdgeInsetsMake(0, 23, 20, 23)
        clothesCollectionView = UICollectionView(frame: CGRectMake(0, topAreaHeight, ScreenWidth, ScreenHeight - topAreaHeight - 20), collectionViewLayout: defaultLayout)
        clothesCollectionView.backgroundColor = UIColor.whiteColor()
        super.init(frame: frame)
        topAreaView.addSubviews(countLabel, editButton, doneButton, deleteButton)
        
        topAreaView.frame = CGRectMake(0, 0, ScreenWidth, topAreaHeight)
        
        constrain(countLabel, topAreaView, replace : countLabelConstraint) { (countLabel, parent) -> () in
            countLabel.top == parent.top + 15
            countLabel.left == parent.left + 23
        }
        
        constrain(doneButton, topAreaView) { (doneButton, parent) -> () in
            doneButton.top == parent.top
            doneButton.right == parent.right
            doneButton.height == parent.height
            doneButton.width == 80
        }
  
        constrain(editButton, topAreaView) { (editButton, parent) -> () in
            editButton.top == parent.top
            editButton.right == parent.right
            editButton.height == parent.height
            editButton.width == 80
        }
        
        constrain(deleteButton, topAreaView) { (deleteButton, parent) -> () in
            deleteButton.top == parent.top
            deleteButton.left == parent.left + 8
            deleteButton.height == parent.height
            deleteButton.width == 80
        }
        
        editButton.addTarget(self, action: #selector(MyDrawerView.clickEditButton(_:)), forControlEvents: .TouchUpInside)
        doneButton.addTarget(self, action: #selector(MyDrawerView.clickDoneButton(_:)), forControlEvents: .TouchUpInside)
        deleteButton.addTarget(self, action: #selector(MyDrawerView.clickDeleteButton(_:)), forControlEvents: .TouchUpInside)
        
        defaultDelegate = DefaultDelegate(drawerView: self)
        
        clothesCollectionView.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Cell")
        clothesCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")

        clothesCollectionView.showsVerticalScrollIndicator = false
        clothesCollectionView.dataSource = defaultDelegate
        clothesCollectionView.alwaysBounceVertical = true
        clothesCollectionView.delegate = defaultDelegate
        clothesCollectionView.backgroundColor = UIColor.whiteColor()
        clothesCollectionView.layer.cornerRadius = 5
        
        showViews(countLabel, editButton)
        hideViews(deleteButton, doneButton)
        
        if #available(iOS 9.0, *) {
            longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MyDrawerView.handleLongGesture(_:)))
            longPressGesture?.enabled = false
            clothesCollectionView.addGestureRecognizer(longPressGesture!)
        }
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            guard let selectedIndexPath = clothesCollectionView.indexPathForItemAtPoint(gesture.locationInView(clothesCollectionView)) else {
                break
            }
            if selectedIndexPath.row == 0 {
                return
            }
            if #available(iOS 9.0, *) {
                for v in clothesCollectionView.subviews {
                    if v.tag == selectedIndexPath.row + 1{
                        v.layer.shadowColor = UIColor(white: 0.5, alpha: 0.5).CGColor
                        v.layer.shadowOffset = CGSize(width: 1, height: 1)
                        v.layer.shadowOpacity = 0.8
                        v.layer.shadowRadius = 2
                        v.layer.shadowPath = UIBezierPath(roundedRect: v.bounds, cornerRadius: 0).CGPath
                        floatingCell = v
                    }
                }
                
                clothesCollectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
            } else {
                // Fallback on earlier versions
            }
        case UIGestureRecognizerState.Changed:
            if #available(iOS 9.0, *) {
                clothesCollectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
            } else {
                // Fallback on earlier versions
            }
        case UIGestureRecognizerState.Ended:
            if #available(iOS 9.0, *) {
                clothesCollectionView.endInteractiveMovement()
                floatingCell?.layer.shadowOpacity = 0
                floatingCell?.layer.shadowOffset = CGSize.zero
                floatingCell?.layer.shadowRadius = 0
                floatingCell?.layer.shadowColor = UIColor.clearColor().CGColor
            } else {
                // Fallback on earlier versions
            }
        default:
            if #available(iOS 9.0, *) {
                clothesCollectionView.cancelInteractiveMovement()
                floatingCell?.layer.shadowOpacity = 0
                floatingCell?.layer.shadowOffset = CGSize.zero
                floatingCell?.layer.shadowRadius = 0
                floatingCell?.layer.shadowColor = UIColor.clearColor().CGColor
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5).CGPath
        clothesCollectionView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        cardColorBackgroud.frame = CGRectMake(0, topAreaHeight, self.frame.width, 5)
        topAreaView.frame = CGRectMake(0, 0, self.frame.width, topAreaHeight)
    }
    
    func clickEditButton(btn : UIButton) {
        self.editMode = true
        DJStatisticsLogic.instance().addTraceLog(.Wardrobe_Click_Edit)
    }
    
    func clickDoneButton(btn : UIButton) {
        self.editMode = false
    }
    
    func clickDeleteButton(btn : UIButton) {
        if selectedIds.count > 0 {
            self.delegate?.onClickDeleteButton(Array(selectedIds))
            selectedIds.removeAll()
            editMode = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BaseDelegate : NSObject{
    private let paddingOfImage : CGFloat = 25
    
    private unowned let drawerView : MyDrawerView
    
    init(drawerView : MyDrawerView) {
        self.drawerView = drawerView
    }
    
    
    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
    }
    
    func scrollTrigerPaddingInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(collectionView.contentInset.top, 0, collectionView.contentInset.bottom, 0)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawerView.items == nil ? 1 : drawerView.items!.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        var item : Clothes?
        if indexPath.row > 0 {
            item = drawerView.items![indexPath.row - 1]
        }
        cell.tag = indexPath.row + 1
        cell.backgroundColor = UIColor.whiteColor()
        cell.fillWithContentView({ (view : ClothesView) -> Void in
            constrain(view, block: { (v) in
                v.left == v.superview!.left
                v.right == v.superview!.right
                v.top == v.superview!.top
                v.bottom == v.superview!.bottom
            })

            view.addSubviews(view.borderView, view.imageView, view.imageView4OldClothes, view.selectIcon, view.newAddedLabel, view.nameLabel, view.brandLabel, view.addIcon)
            
            constrain(view.selectIcon, block: { (icon) in
                icon.width == 18
                icon.height == 18
                icon.right == icon.superview!.right - 12
                icon.top == icon.superview!.top + 12
            })

            constrain(view.borderView, block: { (v) in
                v.left == v.superview!.left
                v.right == v.superview!.right
                v.top == v.superview!.top
                v.bottom == v.superview!.bottom - 40
            })
            
            constrain(view.imageView, block: { (v) in
                v.left == v.superview!.left
                v.right == v.superview!.right
                v.top == v.superview!.top
                v.bottom == v.superview!.bottom - 40
            })
            
            constrain(view.imageView4OldClothes, block: { (v) in
                v.left == v.superview!.left + 25
                v.right == v.superview!.right - 25
                v.top == v.superview!.top + 25
                v.bottom == v.superview!.bottom - 65
            })
            
            constrain(view.addIcon, block: { (v) in
                v.center == v.superview!.center
            })
            
            constrain(view.newAddedLabel, block: { (label) in
                label.width == 27
                label.height == 27
                label.right == label.superview!.right - 12
                label.top == label.superview!.top + 12
            })
            
            constrain(view.imageView, view.nameLabel, view.brandLabel, block: { (imageView, nameLabel, brandLabel) in
                nameLabel.left == nameLabel.superview!.left
                nameLabel.top == imageView.bottom + 8
                nameLabel.right == nameLabel.superview!.right
                
                brandLabel.left == brandLabel.superview!.left
                brandLabel.top == nameLabel.bottom + 3
                brandLabel.right == brandLabel.superview!.right
            })
            
            view.newAddedLabel.textCentered().withTextColor(UIColor.whiteColor()).withText(DJStringUtil.localize("New", comment: ""))
            view.newAddedLabel.font = DJFont.condensedHelveticaFontOfSize(9)
            view.newAddedLabel.withBackgroundColor(UIColor(fromHexString: "9ccf99"))
            view.newAddedLabel.layer.cornerRadius = 13.5
            view.newAddedLabel.clipsToBounds = true
            
            view.nameLabel.lineBreakMode = .ByTruncatingTail
            
            view.borderView.layer.borderColor = DJCommonStyle.DividerColor.CGColor
            view.layer.borderColor = DJCommonStyle.DividerColor.CGColor

            }) { (view : ClothesView) -> Void in
                var newAdded = false
                if item != nil {
                    view.layer.borderWidth = 0

                    view.addTapGestureTarget(self, action: #selector(BaseDelegate.tapItem(_:)))
                    view.tag = indexPath.row
                    if let imgUrl = item!.thumbUrl
                    {
                        if let id = item!.uniqueID {
                            if (Int(id) > 30000) {
                                view.imageView.sd_setImageWithURL(NSURL(string: imgUrl + "/\(ImageQuality.MIDDLE).jpg"))
                                view.imageView.hidden = false
                                view.imageView4OldClothes.hidden = true
                            }else {
                                view.imageView4OldClothes.sd_setImageWithURL(NSURL(string: imgUrl + "/\(ImageQuality.MIDDLE).jpg"))
                                view.imageView.hidden = true
                                view.imageView4OldClothes.hidden = false
                            }
                        }
                    }
                    
                    if item?.isNewAdded == true {
                        newAdded = true
                    }
                    
                    view.nameLabel.text = item?.name
                    view.brandLabel.text = (item?.brandName == nil || item?.brandName == "") ? "" : item?.brandName
                    
                    if self.drawerView.editMode {
                        view.selectIcon.hidden = false
                        if let id = item?.uniqueID {
                            if self.drawerView.selectedIds.contains(id) {
                                view.selectIcon.image = UIImage(named: "ClothesSelectedIconBlack")
                            }else {
                                view.selectIcon.image = UIImage(named: "ClothesNotSelectedIcon")
                            }
                        }else {
                            // not possiable, wrong data if happen
                            view.selectIcon.hidden = true
                        }
                        newAdded = false
                    }else {
                        view.selectIcon.hidden = true
                    }
                    view.addIcon.hidden = true
                    view.imageView.contentMode = .ScaleAspectFit
                    view.imageView4OldClothes.contentMode = .ScaleAspectFit
                    view.addLongPressGestureTarget(self, action: #selector(BaseDelegate.longTapItem(_:)))
                }else {
                    view.layer.borderWidth = 0.5
                    view.nameLabel.text = nil
                    view.brandLabel.text = nil
                    view.tag = Int.max
                    view.addIcon.hidden = false
                    view.imageView.hidden = true
                    view.imageView4OldClothes.hidden = true

                    if self.drawerView.editMode {
                        view.addIcon.image = UIImage(named: "AddClothesIcon")
                    }else {
                        view.addIcon.image = UIImage(named: "AddClothesIcon")
                    }
                    view.addTapGestureTarget(self, action: #selector(BaseDelegate.addClothes(_:)))
                    view.selectIcon.hidden = true
                }

                if newAdded {
                    view.newAddedLabel.hidden = false
                }else {
                    view.newAddedLabel.hidden = true
                }
        }
        cell.layer.shadowOpacity = 0
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowRadius = 0
        cell.layer.shadowColor = UIColor.clearColor().CGColor
        return cell
    }
    
    class ClothesView : UIView {
        var imageView = UIImageView()
        var imageView4OldClothes = UIImageView()
        var selectIcon = UIImageView()
        var newAddedLabel = UILabel()
        var nameLabel = UILabel().withFontHeletica(13).withTextColor(DJCommonStyle.BackgroundColor)
        var brandLabel = UILabel().withFontHeletica(13).withTextColor(DJCommonStyle.BackgroundColor)
        var borderView = UIView()
        var addIcon = UIImageView()
    }
    
    func longTapItem(reg : UILongPressGestureRecognizer) {
        if !debugMode {
            return
        }
        if let index = reg.view?.tag {
            let item = drawerView.items![index - 1]
            if let id = item.uniqueID {
                MBProgressHUD.showHUDAddedTo(drawerView.clothesCollectionView.viewController().view, text: id, animated: true)
            }
        }
    }
    
    
    func tapItem(reg : UITapGestureRecognizer) {
        if let index = reg.view?.tag {

            let realIndex = index - 1
            
            if index > drawerView.items?.count {
                return
            }
            if let item = drawerView.items?[realIndex] {
                 if let id = item.uniqueID {
                    if drawerView.editMode {
                        if drawerView.selectedIds.contains(id) {
                            self.drawerView.selectedIds.remove(id)
                        }else {
                            drawerView.selectedIds.insert(id)
                        }
                        drawerView.clothesCollectionView.reloadData()
                        if drawerView.selectedIds.count > 0 {
                            drawerView.deleteButton.enabled = true
                        }else {
                            drawerView.deleteButton.enabled = false
                        }
                        
                    }else {
                        let url = ConfigDataContainer.sharedInstance.getClothDetailUrl(id)
                        let v = ClothDetailViewController(URLString: url)
                        HistoryDataContainer.sharedInstance.addClothesToHistory(item)

                        drawerView.viewController().navigationController?.pushViewController(v, animated: true)
                        DJStatisticsLogic.instance().addTraceLog(.Wardrobe_Click_Item)
                    }
                }
            }
        }
    }
    
    func addClothes(button : UIButton) {
        DJStatisticsLogic.instance().addTraceLog(.Wardrobe_Click_Addbutton)
        if self.drawerView.editMode {
            return
        }
        let contentView = UIView().withBackgroundColor(UIColor(fromHexString: "262729", alpha: 0.95))
        contentView.frame = CGRectMake(0.0, 0.0, 256.0, 241.0);
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 256, height: 51)).withFontHeleticaMedium(15).withTextColor(DJCommonStyle.ColorEA).withText(DJStringUtil.localize("Add Clothes", comment: "")).textCentered()
        let border = UIView(frame: CGRect(x: 41, y: 51, width: 256 - 41 * 2, height: 1)).withBackgroundColor(DJCommonStyle.ColorEA)
        // change to button
        
        let scanBtn = DJButton(frame: CGRect(x: 41, y: border.frame.maxY + 15, width: 60, height: 60))
        let brandBtn = DJButton(frame: CGRect(x: 155, y: border.frame.maxY + 15, width: 60, height: 60))
        let searchBtn = DJButton(frame: CGRect(x: 41, y: brandBtn.frame.maxY + 20, width: 60, height: 60))
        let cameraBtn = DJButton(frame: CGRect(x: 155, y: scanBtn.frame.maxY + 20, width: 60, height: 60))
        
        let brandImage = UIImage(named: "AddClothesByBrandIcon")
        let scanImage = UIImage(named: "AddClothesByScanIcon")
        let searchImage = UIImage(named: "AddClothesBySearchIcon")
        let cameraImage = UIImage(named: "AddClothesByPhotoIcon")
        
        searchBtn.setImage(searchImage, forState: .Normal)
        brandBtn.setImage(brandImage, forState: .Normal)
        scanBtn.setImage(scanImage, forState: .Normal)
        cameraBtn.setImage(cameraImage, forState: .Normal)
        
        let brandLabel = UILabel()
        let scanLabel = UILabel()
        let searchLabel = UILabel()
        let cameraLabel = UILabel()
        [brandLabel, scanLabel, searchLabel, cameraLabel].forEach { (label) -> () in
            label.withFontHeletica(14).withTextColor(DJCommonStyle.ColorEA).textCentered()
            label.frame = CGRectMake(-10, 56, 80, 20)
        }
        
        brandLabel.text = DJStringUtil.localize("Brands", comment: "")
        scanLabel.text =  DJStringUtil.localize("Price Tag", comment: "")
        searchLabel.text = DJStringUtil.localize("Keywords", comment: "")
        cameraLabel.text = DJStringUtil.localize("Photo", comment: "")
        
        brandBtn.addSubview(brandLabel)
        scanBtn.addSubview(scanLabel)
        searchBtn.addSubview(searchLabel)
        cameraBtn.addSubview(cameraLabel)
        
        contentView.addSubviews(title, border, brandBtn, scanBtn, searchBtn, cameraBtn)

        
        brandBtn.addTarget(self, action: #selector(BaseDelegate.addFromBrand), forControlEvents: .TouchUpInside)
        scanBtn.addTarget(self, action: #selector(BaseDelegate.addFromScan), forControlEvents: .TouchUpInside)
        searchBtn.addTarget(self, action: #selector(BaseDelegate.addFromSearch), forControlEvents: .TouchUpInside)
        cameraBtn.addTarget(self, action: #selector(BaseDelegate.addFromCamera), forControlEvents: .TouchUpInside)

        drawerView.popup?.removeFromSuperview()//fix pop up twice
        drawerView.popup = KLCPopup(contentView: contentView)
        drawerView.viewController().navigationController?.view.addSubview(drawerView.popup!)
        drawerView.popup?.shouldDismissOnBackgroundTouch = true
        drawerView.popup?.maskType = .Clear
        drawerView.popup!.show()
    }
    
    func addFromCamera() {
        drawerView.popup?.dismiss(false)
        drawerView.viewController().navigationController?.pushViewController(AddClothByCameraViewController() , animated: true)
      //  drawerView.viewController().navigationController?.pushViewController(AddClothByCameraViewController(), animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Wardrobeadd_Click_Photo)
    }
    
    func addFromSearch() {
        drawerView.popup?.dismiss(false)
        drawerView.viewController().navigationController?.pushViewController(SearchClothesViewController(), animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Wardrobeadd_Click_Keywords)
    }
    
    func addFromBrand() {
        drawerView.popup?.dismiss(false)
        let v = AddByBrandViewController()
        v.categoryId = drawerView.categoryId
        v.hidesBottomBarWhenPushed = true
        drawerView.viewController().navigationController?.pushViewController(v, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Wardrobeadd_Click_Brands)
    }
    
    func addFromScan() {
        drawerView.popup?.dismiss(false)
        let v = AddByScanViewController()
        drawerView.viewController().navigationController?.pushViewController(v, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Wardrobeadd_Click_Pricetag)

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let imageWidth = (UIScreen.mainScreen().bounds.width - 19 - 46) / 2
        if indexPath.row > 0 {
            let clothSummary = drawerView.items![indexPath.row - 1]
            let size = FindClothCollectionCell.calculateCellSize(clothSummary)
            return CGSizeMake(size.width, size.height - 20)
        }else {
            return CGSizeMake(imageWidth, imageWidth * 200 / 306)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let v = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath)
        if indexPath.section == 0 {
            if let _ = v.viewWithTag(11) {
            }else {
                v.addSubview(drawerView.topAreaView)
            }
        }
        
        return v
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return topAreaHeight
        }
        return 0
    }
    
    func itemDidMoved(sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == 0{
            return
        }
        if destinationIndexPath.row == 0 {
            WardrobeDataContainer.sharedInstance.changeClothesOrder(sourceIndexPath.row - 1, toIndex: 0, list: drawerView.items!)
            let temp = drawerView.items!.removeAtIndex(sourceIndexPath.item - 1)
            drawerView.items!.insert(temp, atIndex: 0)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.drawerView.clothesCollectionView.reloadData()
            })
            return
        }
        WardrobeDataContainer.sharedInstance.changeClothesOrder(sourceIndexPath.row - 1, toIndex: destinationIndexPath.row - 1, list: drawerView.items!)
        let temp = drawerView.items!.removeAtIndex(sourceIndexPath.item - 1)
        drawerView.items!.insert(temp, atIndex: destinationIndexPath.item - 1)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 22
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 19
    }
}

class DefaultDelegate : BaseDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        itemDidMoved(sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}
