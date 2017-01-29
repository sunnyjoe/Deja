//
//  RefineView.swift
//  DejaFashion
//
//  Created by jiao qing on 10/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

@objc  protocol RefineViewDelegate : NSObjectProtocol{
    func refineViewDone(refineView : RefineView)
}

class RefineView: UIView
{
    let viewHeaderHeight : CGFloat = 49
    
    var vcName : String?
    
    var tableView : UITableView?
    weak var delegate : RefineViewDelegate?
    var allBtns = [RefineFilterBtn]()
    let funcView = UIView()
    var selectedFilters = [Filter]()
    
    var rowViews = [Int : UIView]()
    var sectionViews = [Int : UIView]()
    var arrowBtns = [Int : ArrowButton]()
    
    var containerView : UIScrollView?
    
    var filterConditions = [FilterCondition]()
    
    var expandSections = [Int : Bool]()
    
    let resetBtn = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterConditions = getFilterCondition()
        
        self.addTapGestureTarget(self, action: Selector("backgroundViewDidTapped"))
        
        containerView = UIScrollView(frame: CGRectMake(0, 0, self.frame.size.width, 423))
        containerView?.backgroundColor = UIColor.whiteColor()
        addSubview(containerView!)
        let hView = getViewHeader()
        tableView = UITableView(frame: CGRectMake(23, 0, containerView!.frame.size.width - 46, hView.frame.size.height + viewHeaderHeight * CGFloat(filterConditions.count)))
        tableView?.contentInset = UIEdgeInsetsMake(hView.frame.size.height, 0, 0, 0)
        tableView!.addSubview(hView)
        tableView!.delegate = self
        tableView!.separatorStyle = .None
        tableView!.dataSource = self
        tableView!.showsVerticalScrollIndicator = false
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        containerView!.addSubview(tableView!)
        containerView!.addSubview(funcView)
        containerView?.userInteractionEnabled = true
        containerView!.addTapGestureTarget(self, action: Selector("doNoting"))
        
        funcView.frame = CGRectMake(23, CGRectGetMaxY(tableView!.frame), containerView!.frame.size.width - 46, 72)
        resetBtn.frame = CGRectMake(0, 18, (funcView.frame.size.width - 10) * 105 / 320, 36)
        resetBtn.withFontHeletica(14)
        resetBtn.layer.borderWidth = 1
        resetBtn.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        resetBtn.setBackgroundImage(UIImage(color: DJCommonStyle.ColorRed), forState: .Highlighted)
        resetBtn.withTitle("RESET")
        setResetBtnState(false)
        resetBtn.addTarget(self, action: Selector("resetBtnDidTap"), forControlEvents: UIControlEvents.TouchUpInside)
        funcView.addSubview(resetBtn)
        
        let doneBtn = DJButton(frame: CGRectMake(CGRectGetMaxX(resetBtn.frame) + 10, 18, (funcView.frame.size.width - 10) * 215 / 320, 36))
        doneBtn.setWhiteTitle()
        doneBtn.withTitle("DONE")
        doneBtn.addTarget(self, action: Selector("doneBtnDidTap"), forControlEvents: UIControlEvents.TouchUpInside)
        funcView.addSubview(doneBtn)
        
        containerView?.frame = CGRectMake(0, getContainerOriginY(CGRectGetMaxY(funcView.frame)), self.frame.size.width, CGRectGetMaxY(funcView.frame))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getContainerOriginY(height : CGFloat) -> CGFloat{
        return 0
    }
    
    func setResetBtnState(enable : Bool){
        if enable {
            resetBtn.layer.borderColor = UIColor(fromHexString: "272629").CGColor
            resetBtn.withTitleColor(UIColor(fromHexString: "272629"))
        }else{
            resetBtn.layer.borderColor = UIColor(fromHexString: "cecece").CGColor
            resetBtn.withTitleColor(UIColor(fromHexString: "cecece"))
        }
    }
    
    func doNoting(){
    }
    
    func resetFilterBtns(){
        for btn in allBtns {
            btn.setSelectedIcon(false)
        }
        setResetBtnState(false)
        if selectedFilters.count == 0 {
            return
        }
        setResetBtnState(true)
        for sF in selectedFilters{
            for btn in allBtns {
                if let tmpF = btn.filter {
                    if tmpF.id == sF.id {
                        btn.setSelectedIcon(true)
                    }
                }
            }
        }
    }
    
    
    func resetSelectedFilters(newfilters : [Filter]){
        selectedFilters = newfilters
        
        resetFilterBtns()
        for cd in filterConditions{
            expandSections[filterConditions.indexOf(cd)!] = false
        }
        
        for sf in selectedFilters{
            var index = 0
            TheWhile : while index < filterConditions.count {
                for sfv in filterConditions[index].values {
                    if sfv.id == sf.id {
                        expandSections[index] = true
                        break TheWhile
                    }
                }
                index += 1
            }
        }
        
        tableView!.reloadData()
    }
    
    func checkInSelected(filter : Filter) -> Bool{
        for sfr in selectedFilters {
            if sfr.id == filter.id {
                return true
            }
        }
        return false
    }
    
    func getFilterCondition() -> [FilterCondition]{
        return [FilterCondition]()
    }
    
    func doneBtnDidTap(){
        delegate?.refineViewDone(self)
    }
    
    func resetBtnDidTap(){
        resetSelectedFilters([Filter]())
    }
    
    func getViewHeader() -> UIView{
        let hView = UIView(frame: CGRectZero)
        return hView;
    }
    
    func containerViewHiddenFrame() -> CGRect{
        return CGRectMake(0, -containerView!.frame.size.height, containerView!.frame.size.width, containerView!.frame.size.height)
    }
    
    func showAnimation(){
        self.hidden = false
        
        let tmp = containerView!.frame
        self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0)
        containerView!.frame = containerViewHiddenFrame()
        UIView.animateWithDuration(0.3, animations: {
            self.containerView!.frame = tmp
            self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.75)
            }, completion:  nil)
    }
    
    func hideAnimation(){
        let tmp = containerView!.frame
        let ret = containerViewHiddenFrame()
        
        UIView.animateWithDuration(0.2, animations: {
            self.containerView!.frame = ret
            self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0)
            }, completion: { (completion : Bool) -> Void in
                self.containerView!.frame = tmp
                self.hidden = true
        })
    }
    
    func backgroundViewDidTapped(){
        self.hideAnimation()
    }
}

extension RefineView : UITableViewDataSource, UITableViewDelegate {
    func arrowBtnDidClicked(btn : UIButton){
        let secNS = btn.property as! NSNumber
        let section = secNS.integerValue
        
        if inExpanded(section) {
            self.collapseSection(section)
        }else{
            self.expandSection(section)
        }
    }
    
    func expandSection(section : NSInteger) {
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
            self.tableView!.endUpdates()
            if section == self.tableView!.numberOfSections - 1 {
                let offSetY = self.tableView!.contentOffset.y + tableView(self.tableView!, heightForRowAtIndexPath: path)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    self.tableView!.setContentOffset(CGPointMake(0, offSetY), animated: true)
                }
            }
        }
    }
    
    func collapseSection(section : NSInteger) {
        if section < 0 || section >= self.tableView!.numberOfSections {
            return
        }
        
        let cnt = self.tableView!.numberOfRowsInSection(section)
        if cnt == 2 {
            if let tBtn = arrowBtns[section] {
                tBtn.setIndicator(false)
            }
            expandSections[section] = false
            self.tableView!.beginUpdates()
            let path = NSIndexPath(forRow: 1, inSection: section)
            self.tableView!.deleteRowsAtIndexPaths([path], withRowAnimation: .Top)
            self.tableView!.endUpdates()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inExpanded(section) {
            if let tBtn = arrowBtns[section] {
                tBtn.setIndicator(true)
            }
            return 1 + 1
        }else{
            if let tBtn = arrowBtns[section] {
                tBtn.setIndicator(false)
            }
            return 0 + 1
        }
    }
    
    func inExpanded(section : Int) -> Bool{
        if expandSections[section] != nil{
            return expandSections[section]!
        }else{
            return false
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filterConditions.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return viewHeaderHeight
        }
        if let view = rowViews[indexPath.section] {
            return view.frame.size.height
        }else{
            let view = buildRowView(indexPath.section)
            rowViews[indexPath.section] = view
            return view.frame.size.height
        }
    }
    
    func viewForFakeHeaderInSection(section: Int) -> UIView? {
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if rowViews[indexPath.section] == nil {
            rowViews[indexPath.section] = buildRowView(indexPath.section)
        }
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")
            cell?.removeAllSubViews()
            if let hv = viewForFakeHeaderInSection(indexPath.section){
                cell?.addSubview(hv)
            }
            return cell!
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")
            cell?.removeAllSubViews()
            cell?.addSubview(rowViews[indexPath.section]!)
            return cell!
        }
    }
    
    func buildRowView(section : Int) -> UIView{
        let containerView = UIView()
        
        if filterConditions.count == 0 {
            return containerView
        }
        containerView.backgroundColor = UIColor.whiteColor()
        var oX : CGFloat = 0
        var oY : CGFloat = 15
        let btnWidth = (tableView!.frame.size.width - 20) / 3
        let btnHeight : CGFloat = 28
        
        let filters = filterConditions[section].values
        for filter in filters {
            let filterBtn = RefineFilterBtn(frame: CGRectMake(oX, oY, btnWidth, btnHeight))
            filterBtn.withTitle(filter.name)
            filterBtn.filter = filter
            filterBtn.titleLabel?.numberOfLines = 1
            filterBtn.sizeToFit()
            if oX + filterBtn.frame.size.width + 32 > tableView!.frame.size.width && oX > 0{
                oX = 0
                oY += btnHeight + 14
            }
            filterBtn.contentHorizontalAlignment = .Right
            filterBtn.frame = CGRectMake(oX, oY, min(filterBtn.frame.size.width + 32, tableView!.frame.size.width), btnHeight)
            filterBtn.addTarget(self, action: Selector("filterBtnDidTap:"), forControlEvents: UIControlEvents.TouchUpInside)
            containerView.addSubview(filterBtn)
            allBtns.append(filterBtn)
            if filterInSelection(filter){
                filterBtn.setSelectedIcon(true)
            }
            oX += filterBtn.frame.size.width + 10
            if oX > tableView!.frame.size.width && filters.indexOf(filter) < filters.count - 1{
                oX = 0
                oY += btnHeight + 15
            }
        }
        containerView.frame = CGRectMake(0, 0, tableView!.frame.size.width, oY + btnHeight + 15)
        let border = UIView(frame: CGRectMake(0, containerView.frame.size.height - 1, containerView.frame.size.width, 1))
        border.backgroundColor = UIColor(fromHexString: "eaeaea")
        containerView.addSubview(border)
        
        return containerView
    }
    
    func filterInSelection(filter : Filter) -> Bool{
        for fr in selectedFilters {
            if fr.id == filter.id {
                return true
            }
        }
        return false
    }
    
    func filterBtnDidTap(btn : RefineFilterBtn){
    }
    
    func removeFilterInSelection(filter : Filter){
        var index = 0
        for tmFilter in selectedFilters {
            if tmFilter.id == filter.id {
                selectedFilters.removeAtIndex(index)
                break
            }
            index += 1
        }
    }
    
}

class ArrowButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setIndicator(false)
    }
    
    func setIndicator(expand : Bool){
        if expand {
            setImage(UIImage(named:"FilterArrowUp"), forState: .Normal)
        }else{
            setImage(UIImage(named:"FilterArrowDown"), forState: .Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RefineFilterBtn : UIButton{
    var selectorIV = UIImageView()
    var filter : Filter?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, frame.size.height / 2)
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1
        clipsToBounds = true
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(UIColor.defaultRed(), forState: .Highlighted)
        layer.cornerRadius = frame.size.height / 2
        titleLabel?.numberOfLines = 0
        withFontHeletica(14)
        
        selectorIV.backgroundColor = UIColor.whiteColor()
        selectorIV.frame =  CGRectMake(8, frame.size.height / 2 - 19 / 2, 19, 19)
        setSelectedIcon(false)
        addSubview(selectorIV)
    }
    
    func setSelectedIcon(selected : Bool){
        if selected {
            selectorIV.image = UIImage(named:"RefineSelectedCircle")
        }else{
            selectorIV.image = UIImage(named:"RefineCircle")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
























