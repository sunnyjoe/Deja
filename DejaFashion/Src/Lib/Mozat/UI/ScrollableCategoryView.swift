//
//  ScrollableCategoryView.swift
//  DejaFashion
//
//  Created by jiao qing on 7/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol ScrollableCategoryViewDelegate : NSObjectProtocol{
    func scrollableCategoryViewDidSelectedIndex(scrollableCategoryView : ScrollableCategoryView, selectedIndex : Int)
}

class ScrollableCategoryView: UIView {
    private let scrollView = UIScrollView()
    private let underLine = UIView()
    private var shownInfos = [String]()
    private var infoBtns = [UIButton]()
    private var selectedIndex = 0
    private var border = UIView()
    
    weak var delegate : ScrollableCategoryViewDelegate?
    
    convenience init() {
        self.init(frame : CGRectZero, infos : [" "])
    }
    
    init(frame : CGRect, infos : [String]){
        super.init(frame: frame)
        
        underLine.backgroundColor = UIColor.whiteColor()
        scrollView.addSubview(underLine)
        scrollView.backgroundColor = UIColor.defaultBlack()
        
        addSubview(scrollView)
        addSubview(border)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetInfos(infos : [String]){
        shownInfos = infos
        
        updateIndexView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        border.frame = CGRectMake(0, scrollView.frame.height - 0.5, scrollView.frame.size.width, 0.5)
        
        updateIndexView()
        scrollToIndex(selectedIndex)
    }
    
    func updateIndexView(){
        scrollView.removeAllSubViews()
        infoBtns.removeAll()
        
        var oX : CGFloat = 23
        var index = 0
        for item in shownInfos
        {
            let nameBtn = DJButton(frame: CGRectMake(oX, 10, 50, frame.size.height - 20))
            nameBtn.withTitle(item)
            nameBtn.addTarget(self, action: #selector(ScrollableCategoryView.categoryBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            nameBtn.tag = index
            scrollView.addSubview(nameBtn)
            infoBtns.append(nameBtn)
            
            if index == selectedIndex {
                nameBtn.withFontHeleticaMedium(16)
                nameBtn.withTitleColor(UIColor.whiteColor())
                
            }else{
                nameBtn.withFontHeletica(16)
                nameBtn.withTitleColor(DJCommonStyle.ColorCE)
            }
            nameBtn.sizeToFit()
            nameBtn.frame = CGRectMake(oX, 9, nameBtn.frame.size.width, nameBtn.frame.size.height)
            
            oX += CGFloat(nameBtn.frame.size.width)
            if index < shownInfos.count {
                oX += 25
            }
            index += 1
        }
        scrollView.addSubview(underLine)
        scrollView.contentSize = CGSizeMake(oX, frame.size.height)
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 23)
    }
    
    func categoryBtnDidTap(btn : DJButton)
    {
        let index = btn.tag
        self.scrollToIndex(index)
        delegate?.scrollableCategoryViewDidSelectedIndex(self, selectedIndex: index)
    }
    
    func scrollToIndex(index : Int){
        if index < 0 || index >= shownInfos.count{
            return
        }
        
        selectedIndex = index
        updateIndexView()
        
        let btn = infoBtns[index]
        
        var nextX = btn.frame.origin.x - (frame.size.width - btn.frame.size.width) / 2
        var maxX = scrollView.contentSize.width - frame.size.width
        
        maxX = maxX < 0  ? 0 : maxX
        nextX = nextX < 0 ? 0 : nextX
        nextX = min(nextX, maxX)
        
        UIView.animateWithDuration(0.2, animations: {
            self.underLine.frame = CGRectMake(btn.frame.origin.x, self.scrollView.frame.size.height - 1.5, btn.frame.size.width, 1.5)
            self.scrollView.setContentOffset(CGPointMake(nextX, 0),animated: false)
        })
    }
}
