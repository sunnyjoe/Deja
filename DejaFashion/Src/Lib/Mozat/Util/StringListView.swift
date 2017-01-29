//
//  StringListView.swift
//  DejaFashion
//
//  Created by jiao qing on 19/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


class StringListView: UIView {
    private let contentTB = UITableView()
    private var content = [String]()
    
    private weak var selectTarget : AnyObject?
    private var selectSelector : Selector?
    
    private var labelColor = UIColor.defaultBlack()
    private var cellColor = UIColor.whiteColor()
    
    private var selectedName : String?
    var textCenterAligned = true
    
    var showArrowNames = [String]()
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        addSubview(contentTB)
        
        contentTB.showsVerticalScrollIndicator = false
        contentTB.separatorStyle = .None
        contentTB.registerClass(ListSimpleLabelTableCell.self, forCellReuseIdentifier: "ListSimpleLabelTableCell")
        contentTB.delegate = self
        contentTB.dataSource = self
    }
    
    func setTheContent(strs : [String], sort : Bool = true){
        content = strs
        if sort{
            content = content.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        }
        contentTB.reloadData()
    }
    
    func setContentSelector(target : AnyObject, sel : Selector){
        selectTarget = target
        selectSelector = sel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentTB.frame = bounds
    }
    
    func resetSelectedName(name : String?){
        selectedName = name
        contentTB.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StringListView: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 45
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return content.count
    }
    
    // Default is 1 if not implemented
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = ListSimpleLabelTableCell()
        if let tmp = tableView.dequeueReusableCellWithIdentifier("ListSimpleLabelTableCell"){
            cell = (tmp as! ListSimpleLabelTableCell)
            cell.label.text = content[indexPath.row]
            cell.label.withFontHeletica(16)
        }
        if textCenterAligned{
            cell.label.textCentered()
        }else{
            cell.label.textAlignment = .Left
        }
        if selectedName == content[indexPath.row]{
            cell.setTheLableColor(UIColor.defaultRed())
        }else{
            cell.setTheLableColor(labelColor)
        }
        
        if showArrowNames.contains(content[indexPath.row]) {
            cell.addSubview(cell.arrow)
        }else{
            cell.arrow.removeFromSuperview()
        }
        
        cell.backgroundColor = cellColor
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedName = content[indexPath.row]
        contentTB.reloadData()
        if selectTarget != nil && selectSelector != nil{
            if selectTarget!.respondsToSelector(selectSelector!){
                selectTarget!.performSelector(selectSelector!, withObject: content[indexPath.row])
            }
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


class ListSimpleLabelTableCell : SimpleLabelTableCell {
    var border = UIView()
    var arrow = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        
        border.backgroundColor = DJCommonStyle.ColorCE
        addSubview(border)
        
        arrow.contentMode = .ScaleAspectFill
        arrow.image = UIImage(named: "ArrowRight2")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRectMake(23, 0, frame.size.width - 23 * 2, frame.size.height)
        border.frame =  CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)
        arrow.frame = CGRectMake(frame.size.width - 23 - 3, frame.size.height / 2 - 6, 6, 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






