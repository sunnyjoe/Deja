//
//  CuttingSelectView.swift
//  DejaFashion
//
//  Created by jiao qing on 26/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol CuttingSelectViewDelegate : NSObjectProtocol{
    func cuttingSelectViewSelectFilter(cuttingSelectView : CuttingSelectView, filter : Filter?)
}

class CuttingSelectView: UIView {
    weak var delegate : CuttingSelectViewDelegate?
    
    private var selected : Filter?
    private let contentTB = UITableView()
    
    private var filterCondition : FilterCondition!
    private let allFilter = Filter()
    private var filters = [Filter]()
    
    init(frame : CGRect, filterCondition : FilterCondition, choice : [String]) {
        super.init(frame: frame)
        
        self.filterCondition = filterCondition
        
        allFilter.name = DJStringUtil.localize("All", comment:"")
        allFilter.id = "-1"
        filters.append(allFilter)
        
        for one in filterCondition.values {
            if choice.contains(one.id){
                filters.append(one)
            }
        }
        addSubview(contentTB)
        
        contentTB.showsVerticalScrollIndicator = false
        contentTB.separatorStyle = .None
        contentTB.registerClass(ListSimpleLabelTableCell.self, forCellReuseIdentifier: "ListSimpleLabelTableCell")
        contentTB.delegate = self
        contentTB.dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentTB.frame = bounds
    }
    
    func resetSelected(filterId : String?){
        if filterId == nil {
            selected = allFilter
        }else{
            for one in filters{
                if one.id == filterId!{
                    selected = one
                }
            }
        }
        contentTB.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CuttingSelectView: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 45
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filters.count
    }
    
    // Default is 1 if not implemented
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cf = filters[indexPath.row]
        
        var cell = ListSimpleLabelTableCell()
        if let tmp = tableView.dequeueReusableCellWithIdentifier("ListSimpleLabelTableCell"){
            cell = (tmp as! ListSimpleLabelTableCell)
        }
        cell.label.text = cf.name
        cell.label.withFontHeleticaMedium(15)
        
        if selected != nil && selected!.id == cf.id{
            cell.setTheLableColor(UIColor.defaultRed())
        }else{
            cell.setTheLableColor(UIColor.defaultBlack())
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        //        if selected != nil && selected!.id == filters[indexPath.row].id{
        //            selected = allFilter
        //        }else{
        selected = filters[indexPath.row]
        //    }
        contentTB.reloadData()
        if selected != allFilter{
            delegate?.cuttingSelectViewSelectFilter(self, filter: selected)
        }else{
            delegate?.cuttingSelectViewSelectFilter(self, filter: nil)
        }
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            let curCell = cell as! SimpleLabelTableCell
            curCell.didHighlighted(false)
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            let curCell = cell as! SimpleLabelTableCell
            curCell.didHighlighted(true)
        }
    }
}


