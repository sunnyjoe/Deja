//
//  BlackFindClothSearchView.swift
//  DejaFashion
//
//  Created by jiao qing on 23/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol BlackFindClothSearchViewDelegate : NSObjectProtocol{
    func blackFindClothSearchViewDidDragDown(blackFindClothSearchView : BlackFindClothSearchView)
}


class BlackFindClothSearchView: FindClothSearchView {
    var preLocation = CGPointZero
    weak var gestureDelegate : BlackFindClothSearchViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.defaultBlack()
    }
    
    override func buildSearchView(){
        backgroundColor = UIColor.whiteColor()
        
        let controlBtn = UIControl(frame: CGRectMake(0, 0, 25 + 20, frame.size.height))
        controlBtn.addTarget(self, action: #selector(arrowBtnDidClicked), forControlEvents: .TouchUpInside)
        addSubview(controlBtn)
        
        let arrowIV = UIImageView(frame: CGRectMake(18, 17 + (frame.size.height - 20) / 2 - 23 / 2, 19, 23))
        arrowIV.image = UIImage(named: "DownArrowWhite")
      //  arrowIV.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI))
        addSubview(arrowIV)
        
        pureSearchView = CustomSearchView(frame : CGRectMake(55, 22.5, frame.size.width - 20 - 55 - 70, frame.size.height - 25 - 5))
        pureSearchView.backgroundColor = UIColor(fromHexString: "383940")
        pureSearchView.delegate = self
        addSubview(pureSearchView)
        if let tmp = ConfigDataContainer.sharedInstance.getSearchKeywordHint(){
            pureSearchView.setSearchPlaceHolder(tmp)
        }
        
        pureSearchView.textFiled.textColor = UIColor.whiteColor()
        pureSearchView.iconBtn.setImage(UIImage(named: "FindSearchIcon"), forState: .Normal)
        pureSearchView.iconBtn.frame = CGRectMake(8, pureSearchView.frame.size.height / 2 - 10, 20, 20)
        
        let bgView = UIView(frame : CGRectMake(CGRectGetMaxX(pureSearchView.frame), pureSearchView.frame.origin.y, 70, pureSearchView.frame.size.height))
        addSubview(bgView)
        bgView.backgroundColor = pureSearchView.backgroundColor
        
        let photoIV = UIButton(frame : CGRectMake(0, bgView.frame.size.height / 2 - 10, 20, 20))
        photoIV.setImage(UIImage(named: "ByPhotoWhite"), forState: .Normal)
        photoIV.addTarget(self, action: #selector(byPhotoViewDidTapped(_:)), forControlEvents: .TouchUpInside)
        bgView.addSubview(photoIV)
        
        let tagIV = UIButton(frame : CGRectMake(35, bgView.frame.size.height / 2 - 10, 20, 20))
        tagIV.setImage(UIImage(named: "ByTagWhite"), forState: .Normal)
        tagIV.addTarget(self, action: #selector(byPhotoTagDidTapped(_:)), forControlEvents: .TouchUpInside)
        bgView.addSubview(tagIV)
        
        let pang = UIPanGestureRecognizer(target: self, action: #selector(detectPanGesture(_:)))
        pang.cancelsTouchesInView = false
        addGestureRecognizer(pang)
    }
    
    func detectPanGesture(pan : UIPanGestureRecognizer){
        let translation = pan.locationInView(self)
        // print("\(pan.state.rawValue)")
        if pan.state == .Began{
            preLocation = translation
        }else if pan.state == .Ended{
            let xd = translation.x - preLocation.x
            let yd = translation.y - preLocation.y
            
            if xd < 40 && yd > frame.size.height {
                gestureDelegate?.blackFindClothSearchViewDidDragDown(self)
            }
        }
    }
    
    func arrowBtnDidClicked(){
         gestureDelegate?.blackFindClothSearchViewDidDragDown(self)
    }
    
    override func buildRightView(){
    }
    
    internal override func customSearchViewBeginEditing(view : CustomSearchView){
        delegate?.findClothSearchViewBeginEditing(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
