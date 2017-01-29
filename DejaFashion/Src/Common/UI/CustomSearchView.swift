//
//  CustomSearchView.swift
//  DejaFashion
//
//  Created by jiao qing on 24/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

@objc protocol CustomSearchViewDelegate : NSObjectProtocol{
    func customSearchViewDidSearch(view : CustomSearchView, query : String?)
    func customSearchViewClessClear(view : CustomSearchView)
    
    @objc optional func customSearchViewBeginEditing(view : CustomSearchView)
}


class CustomSearchView: UIView, UITextFieldDelegate {
    weak var delegate : CustomSearchViewDelegate?
    let textFiled = UITextField()
    let iconBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconBtn.setImage(UIImage(named: "SearchIcon"), forState: .Normal)
        iconBtn.addTarget(self, action: #selector(searchDidTapped), forControlEvents: .TouchUpInside)
        iconBtn.frame = CGRectMake(0, frame.size.height / 2 - 10, 23, 19)
        addSubview(iconBtn)
        
        textFiled.delegate = self
        textFiled.keyboardType = .WebSearch
        textFiled.clearButtonMode = .Always
        
        textFiled.font = DJFont.helveticaFontOfSize(15)
        let oX = CGRectGetMaxX(iconBtn.frame) + 13
        textFiled.frame = CGRectMake(oX, 0, frame.size.width - oX, frame.size.height - 3)
        addSubview(textFiled)
    }
    
    func addUnderLine(){
        let underLine = UIView(frame: CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5))
        underLine.backgroundColor = DJCommonStyle.ColorCE
        addSubview(underLine)
    }
    
    func setSearchPlaceHolder(str : String){
      //  textFiled.placeholder = str
        
        var myMutableStringTitle = NSMutableAttributedString()
       // let Name  = "Enter Title" // PlaceHolderText
        
        myMutableStringTitle = NSMutableAttributedString(string:str, attributes: [NSFontAttributeName:DJFont.contentFontOfSize(15)]) // Font
        myMutableStringTitle.addAttribute(NSForegroundColorAttributeName, value: DJCommonStyle.Color81, range:NSRange(location:0,length:str.characters.count))    // Color
        textFiled.attributedPlaceholder = myMutableStringTitle
    }
    
    func setKeyBoardType(theType : UIKeyboardType){
        textFiled.keyboardType = theType
    }
    
    func searchDidTapped(){
        textFiled.resignFirstResponder()
        delegate?.customSearchViewDidSearch(self, query: textFiled.text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textFiled.resignFirstResponder()
        delegate?.customSearchViewDidSearch(self, query: textFiled.text)
        return true
    }
    
    func clearSearch(){
        textFiled.text = nil
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if delegate == nil {
            return true
        }
        
        if delegate!.respondsToSelector(#selector(CustomSearchViewDelegate.customSearchViewBeginEditing(_:))) {
            delegate?.customSearchViewBeginEditing!(self)
        }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool
    {
        delegate?.customSearchViewClessClear(self)
        return true
    }
    
    func text() -> String?
    {
        return textFiled.text
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, withEvent: event)
        if (view == nil) {
            textFiled.resignFirstResponder()
        }
        return view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
