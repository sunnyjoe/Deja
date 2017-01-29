//
//  StyleRefineView.swift
//  DejaFashion
//
//  Created by jiao qing on 11/1/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class SelectorImageView: UIImageView {
    func setSelectorImage(selected : Bool){
        if selected {
            image = UIImage(named:"RefineSelectedCircle")
        }else{
            image = UIImage(named:"RefineCircle")
        }
    }
    
    func setDotImage(){
        image = UIImage(named:"RefineCircleDot")
    }
}

class StyleRefineView: RefineView {
    var sectionIconIVs = [SelectorImageView]()
    
    override func getViewHeader() -> UIView{
        let hView = UIView(frame: CGRectMake(0, -50, self.frame.size.width, 50))
        
        let nameLabel = UILabel(frame: CGRectMake(0, 0, frame.size.width - 46, 49))
        nameLabel.withFontHeleticaBold(15).withTextColor(UIColor.defaultBlack()).withText("OCCASIONS")
        nameLabel.textAlignment = .Left
        hView.addSubview(nameLabel)
        
        let border = UIView(frame: CGRectMake(0, hView.frame.size.height - 1, hView.frame.size.width, 1))
        border.backgroundColor = UIColor(fromHexString: "272629")
        hView.addSubview(border)
        return hView;
    }
    
    override func getFilterCondition() -> [FilterCondition]{
        return ConfigDataContainer.sharedInstance.getConfigStyleCategory();
    }
    
    override func containerViewHiddenFrame() -> CGRect{
        return CGRectMake(0, self.frame.size.height, containerView!.frame.size.width, containerView!.frame.size.height)
    }
    
    override func getContainerOriginY(height : CGFloat) -> CGFloat{
        return frame.size.height - height
    }
    
    override func viewForFakeHeaderInSection(section: Int) -> UIView? {
        if let tmp = sectionViews[section] {
            return tmp
        }else{
            let cond = filterConditions[section]
            let headerView = UIView(frame: CGRectMake(0, 0, tableView!.frame.size.width, viewHeaderHeight))
            headerView.backgroundColor = UIColor.whiteColor()
            
            let icon = SelectorImageView(frame: CGRectMake(0, viewHeaderHeight / 2 - 19 / 2, 19, 19))
            icon.setSelectorImage(false)
            icon.property = cond
            sectionIconIVs.append(icon)
            headerView.addSubview(icon)
            
            for sfr in selectedFilters {
                if cond.id == sfr.condtionId {
                    icon.setSelectorImage(true)
                    break
                }
            }
            
            let btn = UIButton(frame: CGRectMake(0, 0, 26, viewHeaderHeight))
            btn.property = cond
            headerView.addSubview(btn)
            btn.addTarget(self, action: Selector("conditionDidSelected:"), forControlEvents: .TouchUpInside)
            headerView.addSubview(btn)
            
            let nameLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(icon.frame) + 7, 0, tableView!.frame.size.width - 30, viewHeaderHeight))
            nameLabel.withFontHeleticaMedium(16).withTextColor(UIColor.defaultBlack()).withText(cond.name)
            nameLabel.textAlignment = .Left
            nameLabel.sizeToFit()
            nameLabel.frame = CGRectMake(CGRectGetMaxX(icon.frame) + 7, 0, nameLabel.frame.size.width, viewHeaderHeight)
            headerView.addSubview(nameLabel)
            
            let arrowBtn = ArrowButton(frame: CGRectMake(tableView!.frame.size.width - 22, viewHeaderHeight / 2 - 19 / 2, 22, 19))
            headerView.addSubview(arrowBtn)
            arrowBtns[section] = arrowBtn
            
            let actionbtn = UIButton(frame: CGRectMake(nameLabel.frame.origin.x, 0, tableView!.frame.size.width - nameLabel.frame.origin.x, viewHeaderHeight))
            actionbtn.property = NSNumber(integer: section)
            headerView.addSubview(actionbtn)
            actionbtn.addTarget(self, action: Selector("arrowBtnDidClicked:"), forControlEvents: .TouchUpInside)
            headerView.addSubview(actionbtn)
            
            let border = UIView(frame: CGRectMake(0, viewHeaderHeight - 1, tableView!.frame.size.width, 1))
            border.backgroundColor = UIColor(fromHexString: "eaeaea")
            headerView.addSubview(border)
            sectionViews[section] = headerView
            return headerView
        }
    }
    
    override func expandSection(section : NSInteger) {
        if section < 0 || section >= self.tableView!.numberOfSections {
            return
        }
        
        let cnt = self.tableView!.numberOfRowsInSection(section)
        if cnt == 1 {
            expandSections[section] = true
            if let tBtn = arrowBtns[section] {
                tBtn.setIndicator(true)
            }
            
            self.tableView!.beginUpdates()
            let path = NSIndexPath(forRow: 1, inSection: section)
            self.tableView!.insertRowsAtIndexPaths([path], withRowAnimation: .Top)
            let sectionKeys = expandSections.keys
            for sc in sectionKeys {
                let decnt = self.tableView!.numberOfRowsInSection(sc)
                if expandSections[sc]! && decnt > 1{
                    let depath = NSIndexPath(forRow: 1, inSection: sc)
                    expandSections[sc] = false
                    self.tableView!.deleteRowsAtIndexPaths([depath], withRowAnimation: .Top)
                    break
                }
            }
            self.tableView!.endUpdates()
            let offSetY = viewHeaderHeight * CGFloat(section)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.tableView!.setContentOffset(CGPointMake(0, offSetY), animated: true)
            }
        }
    }
    
    func resetSectionIcon(){
        for sectionIcon in sectionIconIVs {
            sectionIcon.setSelectorImage(false)
        }
        if selectedFilters.count == 0 {
            return
        }
      
        let sfr = selectedFilters[0]
        var tmpIcon : SelectorImageView?
        for sectionIcon in sectionIconIVs {
            if let xtmp = sectionIcon.property as? FilterCondition {
                if xtmp.id == sfr.condtionId {
                    tmpIcon = sectionIcon
                    break
                }
            }
        }
        
        if tmpIcon == nil{
            return
        }
        
        if let xtmp = tmpIcon!.property as? FilterCondition {
            if selectedFilters.count == 0 {
                tmpIcon!.setSelectorImage(false)
            }else if selectedFilters.count < xtmp.values.count {
                tmpIcon!.setDotImage()
            }else{
                tmpIcon!.setSelectorImage(true)
            }
        }
    }
    
    func resetSectionIconAndFilterBtns(){
        resetSectionIcon()
        resetFilterBtns()
    }
    
    override func resetSelectedFilters(newfilters : [Filter]){
        super.resetSelectedFilters(newfilters)
        resetSectionIcon()
    }
    
    func setSectionWithConditionId(cid : String, selected : Bool){
        var fcd : FilterCondition?
        for sectionIcon in sectionIconIVs {
            if let xtmp = sectionIcon.property as? FilterCondition {
                if xtmp.id == cid {
                    fcd = xtmp
                    break
                }
            }
        }
        if selected {
            selectedFilters = fcd!.values
        }else{
            selectedFilters.removeAll()
        }
        
        resetSectionIconAndFilterBtns()
    }
    
    func isBtnInSelection(btn : RefineFilterBtn) -> Bool{
        if let sfilter = btn.filter {
            for filter in selectedFilters {
                if filter.id == sfilter.id{
                    return true
                }
            }
        }
        return false
    }
    
    override func filterBtnDidTap(btn : RefineFilterBtn){
        let filter = btn.filter
        if filter == nil {
            return
        }
        
        if isBtnInSelection(btn){
            removeFilterInSelection(filter!)
        }else{
            for tmpBtn in allBtns {
                if let sfilter = tmpBtn.filter {
                    if isBtnInSelection(tmpBtn){
                        if sfilter.condtionId != filter!.condtionId {
                            selectedFilters.removeAll()
                            break
                        }
                    }
                }
            }
            selectedFilters.append(filter!)
        }
        resetSectionIconAndFilterBtns()
    }
    
    func conditionDidSelected(btn : UIButton){
        let tmp = btn.property as? FilterCondition
        if  tmp == nil{
            return
        }
        
        var selected = false
        for filter in selectedFilters {
            if filter.condtionId == tmp?.id {
                selected = true
                break
            }
        }
        if selected {
            selectedFilters.removeAll()
        }else{
            selectedFilters = tmp!.values
        }
        
        resetSectionIconAndFilterBtns()
    }
    
}
