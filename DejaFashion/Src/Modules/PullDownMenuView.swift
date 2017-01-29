//
//  PullDownMenuView.swift
//  DejaFashion
//
//  Created by jiao qing on 25/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class PullDownMenuView: UIView {
    private let brandTableView = StringListView()
    private let bgView = UIView()
    private var tableFrame = CGRectZero
    
    private var contentName = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.frame = bounds
        addSubview(bgView)
        bgView.addTapGestureTarget(self, action: #selector(backGroundDidTapped))
        bgView.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.5)
        
        brandTableView.textCenterAligned = false
        addSubview(brandTableView)
    }
    
    func setTheContent(names : [String], selectedIndex : Int){
        contentName = names
        
        tableFrame = CGRectMake(0, 0, frame.size.width, min(45 * CGFloat(names.count), frame.size.height * 0.7))
        brandTableView.frame = tableFrame
        brandTableView.setTheContent(names, sort : false)
        
        setSelectedIndex(selectedIndex)
    }
    
    func setSelectedIndex(index : Int){
        if index >= 0 && index < contentName.count{
            brandTableView.resetSelectedName(contentName[index])
        }
    }
    
    func setContentSelector(target : AnyObject, sel : Selector){
        brandTableView.setContentSelector(target, sel: sel)
    }
    
    func backGroundDidTapped(){
        hideAnimation()
    }
    
    func showAnimation(completion: (() -> Void)? = nil){
        bgView.alpha = 0
        brandTableView.frame = CGRectMake(0, -tableFrame.size.height, frame.size.width, tableFrame.size.height)
        UIView.animateWithDuration(0.3, animations: {
            self.bgView.alpha = 1
            self.brandTableView.frame = self.tableFrame
            }, completion: { (Bool) -> Void in
                if completion != nil {
                    completion!()
                }
        })
    }
    
    func hideAnimation(animated : Bool = true, completion: (() -> Void)? = nil){
        if !animated {
            self.removeFromSuperview()
            return
        }
        UIView.animateWithDuration(0.15, animations: {
            self.bgView.alpha = 0
            self.brandTableView.frame = CGRectMake(0, -self.tableFrame.size.height, self.frame.size.width, self.tableFrame.size.height)
            }, completion: {(Bool) -> Void in
                self.removeFromSuperview()
                if completion != nil {
                    completion!()
                }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
