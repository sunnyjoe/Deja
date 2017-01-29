//
//  TemplateSelectionView.swift
//  DejaFashion
//
//  Created by jiao qing on 5/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol TemplateSelectionViewDelegate : NSObjectProtocol{
    func templateSelectionViewDidSelectIndex(templateSelectionView: TemplateSelectionView, index : Int)
}

class TemplateSelectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
     var templateIcon = [UIImage]()
     var templateInfo = [String]()
    
    private let cellWidth : CGFloat = 56
    private var selectedCell = -1
    
    weak var delegate : TemplateSelectionViewDelegate?
    let bottomTitleLabel = UILabel()
    var collectionView : UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        
        let bottomLabel = UILabel()
        bottomLabel.withFontHeletica(13).withTextColor(UIColor.gray81Color()).withText(DJStringUtil.localize("Choose a template : ", comment:""))
        addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        constrain(bottomLabel) { bottomLabel in
            bottomLabel.top == bottomLabel.superview!.top
            bottomLabel.left == bottomLabel.superview!.left + 19
            bottomLabel.bottom == bottomLabel.superview!.top + 31
        }
        
        bottomTitleLabel.withFontHeletica(13).withTextColor(UIColor.whiteColor())
        bottomTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomTitleLabel.textAlignment = .Left
        addSubview(bottomTitleLabel)
        constrain(bottomTitleLabel, bottomLabel) { bottomTitleLabel, bottomLabel in
            bottomTitleLabel.top == bottomTitleLabel.superview!.top
            bottomTitleLabel.left == bottomLabel.right
            bottomTitleLabel.bottom == bottomTitleLabel.superview!.top + 31
        }
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .Horizontal
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        addSubview(collectionView)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = true
        collectionView.contentInset = UIEdgeInsetsMake(32, 19, 15, 19)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CameraViewCell")
        constrain(collectionView) { collectionView in
            collectionView.top == collectionView.superview!.top
            collectionView.left == collectionView.superview!.left
            collectionView.right == collectionView.superview!.right
            collectionView.bottom == collectionView.superview!.bottom
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectIndex(index : Int){
        if index < 0 || index >= templateIcon.count{
            return
        }
        
        selectedCell = index
        
        bottomTitleLabel.withText("\(templateInfo[index])")
        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templateIcon.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        DJStatisticsLogic.instance().addTraceLog(kStatisticsID_add_by_photo_template_click)
        self.delegate?.templateSelectionViewDidSelectIndex(self, index: indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CameraViewCell", forIndexPath: indexPath)
        cell.removeAllSubViews()
        cell.backgroundColor = UIColor.defaultBlack()
        if indexPath.row == selectedCell{
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor(fromHexString: "ff6854").CGColor
        }else{
            cell.layer.borderWidth = 0
        }
        
        let imageView = UIImageView()
        imageView.image = templateIcon[indexPath.row]
        imageView.contentMode = .ScaleAspectFit
        cell.addSubview(imageView)
        imageView.frame = CGRectMake(0, 0, cellWidth, cellWidth)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(cellWidth, cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 13
    }
    
    
}
