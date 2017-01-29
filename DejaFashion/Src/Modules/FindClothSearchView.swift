//
//  FindClothSearchView.swift
//  DejaFashion
//
//  Created by jiao qing on 18/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol FindClothSearchViewDelegate : NSObjectProtocol{
    func findClothSearchViewDidSearch(findClothSearchView : FindClothSearchView, query : String?)
    func findClothSearchViewDidPauseInput(findClothSearchView : FindClothSearchView, query : String?)
    func findClothSearchViewClessClear(findClothSearchView : FindClothSearchView)
    func findClothSearchViewByPhoto(findClothSearchView : FindClothSearchView)
    func findClothSearchViewByPriceTag(findClothSearchView : FindClothSearchView)
    func findClothSearchViewBeginEditing(findClothSearchView : FindClothSearchView)
}

class FindClothSearchView: UIView, CustomSearchViewDelegate{
    weak var delegate : FindClothSearchViewDelegate?
    var pureSearchView : CustomSearchView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildSearchView()
        buildRightView()
    }
    
    func buildSearchView(){
        let offSet = frame.size.width / 3
        backgroundColor = UIColor.whiteColor()
        pureSearchView = CustomSearchView(frame : CGRectMake(20, 0, frame.size.width - 20 - offSet, frame.size.height))
        pureSearchView.delegate = self
        addSubview(pureSearchView)
        if let word = ConfigDataContainer.sharedInstance.getNewFindPlaceHolder()
        {
            pureSearchView.setSearchPlaceHolder(word)
        }
        pureSearchView.iconBtn.setImage(UIImage(named: "FindSearchIcon"), forState: .Normal)
        pureSearchView.iconBtn.frame = CGRectMake(0, frame.size.height / 2 - 10, 20, 20)
    }
    
    func buildRightView(){
        let lineV = UIView(frame : CGRectMake(CGRectGetMaxX(pureSearchView.frame) - 3 - 0.5, 3, 0.5, frame.size.height - 6))
        lineV.backgroundColor = DJCommonStyle.ColorCE
        addSubview(lineV)
        
        let offSet = frame.size.width / 3
        let byPhotoView = UIView(frame : CGRectMake(CGRectGetMaxX(lineV.frame), 0, offSet / 2, frame.size.height))
        byPhotoView.addTapGestureTarget(self, action: #selector(byPhotoViewDidTapped(_:)))
        addSubview(byPhotoView)
        let photoIV = UIImageView(frame : CGRectMake(26.5 * kIphoneSizeScale, byPhotoView.frame.size.height / 2 - 10, 20, 20))
        photoIV.image = UIImage(named: "ByPhotoIcon")
        byPhotoView.addSubview(photoIV)
        
        let byTagView = UIView(frame : CGRectMake(CGRectGetMaxX(byPhotoView.frame), 0, offSet / 2, frame.size.height))
        byTagView.addTapGestureTarget(self, action: #selector(byPhotoTagDidTapped(_:)))
        addSubview(byTagView)
        let byTagIV = UIImageView(frame : CGRectMake(13.5, byTagView.frame.size.height / 2 - 10, 20, 20))
        byTagIV.image = UIImage(named: "ByPriceTagIcon")
        byTagView.addSubview(byTagIV)
    }
    
    func changeToBlackStyle(){
        backgroundColor = UIColor.defaultBlack()
    }
    
    internal func customSearchViewDidSearch(view : CustomSearchView, query : String?){
        delegate?.findClothSearchViewDidSearch(self, query: query)
    }
    
    internal func customSearchViewClessClear(view : CustomSearchView){
        delegate?.findClothSearchViewClessClear(self)
    }
    
    internal func customSearchViewBeginEditing(view : CustomSearchView){
        delegate?.findClothSearchViewBeginEditing(self)
    }
    
    func getKeywords() -> String?{
        return pureSearchView.textFiled.text
    }
    
    @objc func byPhotoViewDidTapped(sender : UITapGestureRecognizer){
        delegate?.findClothSearchViewByPhoto(self)
    }
    
    @objc func byPhotoTagDidTapped(sender : UITapGestureRecognizer){
        delegate?.findClothSearchViewByPriceTag(self)
    }
    
    func setSearchText(text : String?){
        pureSearchView.textFiled.text = text
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if touch.view != pureSearchView {
                hideKeyBoard()
            }
        }
    }
    
    func hideKeyBoard(){
        if pureSearchView.textFiled.isFirstResponder(){
            delegate?.findClothSearchViewDidPauseInput(self, query: pureSearchView.textFiled.text)
            pureSearchView.textFiled.resignFirstResponder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
