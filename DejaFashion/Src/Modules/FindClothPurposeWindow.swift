//
//  FindClothPurposeWindow.swift
//  DejaFashion
//
//  Created by jiao qing on 6/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

struct Purpose {
    var isNewArrival = false
    var position : (longitude : Double, latitude : Double)?
    var bodyIssues : String?
    var occasion : String?
    var onSale = false
}


protocol FindClothPurposeWindowDelegate : NSObjectProtocol{
    func findClothPurposeWindowSelectPurpose(findClothPurposeWindow : FindClothPurposeWindow, purpose : SearchPurpose?)
}

class FindClothPurposeWindow: SlideWindow {
    let topView = UIView()
    weak var delegate : FindClothPurposeWindowDelegate?
    
    private var selectedPurpose : SearchPurpose?
    private var names = [String]()
    private var tableView : StringListView!
    private var whole = ConfigDataContainer.sharedInstance.getSearchPurposes()
    
    private var subTableView = StringListView()
    private var subTableType = PurposeType.NoLimit
    
    
    private let topView2 = UIView()
    private var contentView2 = UIView()
    private var contentRightHiddenFrame2 = CGRectZero
    private var contentHiddenFrame2 = CGRectZero
    private var contentNormalFrame2 = CGRectZero
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        
        whole.sortInPlace({$0.id < $1.id})
        
        backView.backgroundColor = UIColor(fromHexString: "272629", alpha: 0.5)
        
        let height = CGFloat(whole.count * 45 + 40)
        contentNormalFrame = CGRectMake(0, frame.size.height - height, frame.size.width, height)
        contentHiddenFrame = CGRectMake(0, frame.size.height, frame.size.width, height)
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.frame = contentHiddenFrame
        
        topView.backgroundColor = DJCommonStyle.ColorEA
        topView.frame = CGRectMake(0, 0, frame.size.width, 40)
        contentView.addSubview(topView)
        buildTopView()
        topView.addBorder()
        
        
        var arrowNames = [String]()
        var names = [String]()
        for one in whole{
            names.append(one.name)
            if one.type == PurposeType.BodyIssues || one.type == PurposeType.Occasion {
                arrowNames.append(one.name)
            }
        }
        tableView = StringListView(frame : CGRectMake(0, 40, contentView.frame.size.width, contentView.frame.size.height - 40))
        tableView.textCenterAligned = false
        tableView.showArrowNames = arrowNames
        tableView.setTheContent(names, sort: false)
        contentView.addSubview(tableView)
        if names.count > 0{
            tableView.resetSelectedName(names[0])
        }
        tableView.setContentSelector(self, sel: #selector(didSelectName(_:)))
        
        contentView2.addSubview(subTableView)
        
        topView2.frame = CGRectMake(0, 0, frame.size.width, 40)
        contentView2.addSubview(topView2)
        buildTopView2()
        topView2.addBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetPurpose(purpose : Purpose){
        var type = PurposeType.NoLimit
        
        if purpose.isNewArrival {
            type = .NewArrival
        }else if purpose.onSale {
            type = .Deal
        }else if purpose.occasion != nil {
            type = .Occasion
        }else if purpose.position != nil {
            type = .Nearby
        }else if purpose.bodyIssues != nil {
            type = .BodyIssues
        }
        
        for one in whole{
            if type == one.type {
                if type == .Occasion || type == .BodyIssues{
                    for subOne in one.subPurposes{
                        if subOne.id == purpose.bodyIssues {
                            selectedPurpose = subOne
                        }else if subOne.id == purpose.occasion {
                            selectedPurpose = subOne
                        }
                    }
                }else{
                    selectedPurpose = one
                }
                tableView.resetSelectedName(one.name)
                break
            }
        }
    }
    
    @objc private func didSelectName(str : String){
        var theSelected : SearchPurpose?
        for one in whole{
            if str == one.name {
                theSelected = one
                break
            }
        }
        if theSelected == nil {
            return
        }
        
        var names = [String]()
        
        subTableType = theSelected!.type
        if theSelected!.type == PurposeType.BodyIssues || theSelected!.type == PurposeType.Occasion{
            var bodyP : SearchPurpose?
            for one in whole{
                if one.type == theSelected!.type{
                    bodyP = one
                    break
                }
            }
            if bodyP == nil {
                return
            }
            
            for one in bodyP!.subPurposes{
                names.append(one.name)
            }
            
            let height = min(CGFloat(names.count * 45 + 40), frame.size.height * 0.7)
            contentNormalFrame2 = CGRectMake(0, frame.size.height - height, frame.size.width, height)
            contentHiddenFrame2 = CGRectMake(0, frame.size.height, frame.size.width, height)
            contentRightHiddenFrame2 = CGRectMake(frame.size.width, frame.size.height - height, frame.size.width, height)
            contentView2.backgroundColor = UIColor.whiteColor()
            contentView2.frame = contentRightHiddenFrame2
            
            subTableView.frame = CGRectMake(0, 40, contentView2.frame.size.width, contentView2.frame.size.height - 40)
            subTableView.setTheContent(names, sort: false)
            subTableView.resetSelectedName(theSelected!.name)
            subTableView.setContentSelector(self, sel: #selector(subTableDidSelectName(_:)))

            subTableViewAnimationShow()
        }else {
            selectedPurpose = theSelected
            doneDidClicked()
        }
    }
    
    @objc private func subTableDidSelectName(str : String){
        var bodyP : SearchPurpose?
        for one in whole{
            if one.type == subTableType{
                bodyP = one
                break
            }
        }
        if bodyP == nil {
            return
        }
        
        for one in bodyP!.subPurposes{
            if one.name == str {
                selectedPurpose = one
            }
        }
        
        doneDidClicked()
    }
    
    private func buildTopView(){
        let cancelLabel = UILabel(frame : CGRectMake(23, 5, 100, 30))
        cancelLabel.withTextColor(UIColor.defaultBlack()).withFontHeletica(14).withText("Cancel")
        cancelLabel.addTapGestureTarget(self, action: #selector(cancelDidClicked))
        topView.addSubview(cancelLabel)
    }
    
    private func buildTopView2(){
        let cancelLabel = UILabel(frame : CGRectMake(23, 5, 100, 30))
        cancelLabel.withTextColor(UIColor.defaultBlack()).withFontHeletica(14).withText("Back")
        cancelLabel.addTapGestureTarget(self, action: #selector(backBtnDidClicked))
        topView2.addSubview(cancelLabel)
    }
    
    @objc private func backBtnDidClicked(){
        subTableViewAnimationHide()
    }
    
    private func subTableViewAnimationShow(){
        addSubview(contentView2)
        
        UIView.animateWithDuration(0.3, animations: {
            self.backView.alpha = 1
            self.contentView2.frame = self.contentNormalFrame2
        })
    }
    
    private func subTableViewAnimationHide(){
        if selectedPurpose == nil {
            if let tmp = ConfigDataContainer.sharedInstance.getDefaultSearchPurpose(){
                tableView.resetSelectedName(tmp.name)
            }
        }else{
            if selectedPurpose!.type == .Occasion || selectedPurpose!.type == .BodyIssues{
                for one in whole{
                    if one.type == selectedPurpose!.type {
                        tableView.resetSelectedName(one.name)
                    }
                }
            }else{
                tableView.resetSelectedName(selectedPurpose!.name)
            }
        }
        
        UIView.animateWithDuration(0.3, animations: {
            self.backView.alpha = 1
            self.contentView2.frame = self.contentRightHiddenFrame2
            }, completion: {(Bool) -> Void in
                self.contentView2.removeFromSuperview()
        })
    }
    
    override func showAnimation(){
        self.makeKeyAndVisible()
        
        contentView.frame = contentHiddenFrame
        backView.alpha = 0
        contentView2.frame = contentHiddenFrame2
        UIView.animateWithDuration(0.3, animations: {
            self.backView.alpha = 1
            self.contentView.frame = self.contentNormalFrame
            self.contentView2.frame = self.contentNormalFrame2
        })
    }
    
    override func hideAnimation(){
        backView.alpha = 1
        
        UIView.animateWithDuration(0.3, animations: {
            self.backView.alpha = 0
            self.contentView.frame = self.contentHiddenFrame
            self.contentView2.frame = self.contentHiddenFrame2
            }, completion: {(Bool) -> Void in
                self.hidden = true
        })
    }
    
    @objc private func cancelDidClicked(){
        hideAnimation()
    }
    
    private func doneDidClicked(){
        self.delegate?.findClothPurposeWindowSelectPurpose(self, purpose: selectedPurpose)
        self.hideAnimation()
    }
}
