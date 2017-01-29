//
//  ColorSelectView.swift
//  DejaFashion
//
//  Created by jiao qing on 26/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol ColorSelectViewDelegate : NSObjectProtocol{
    func colorSelectViewSelectColor(colorSelectView : ColorSelectView, color : ColorFilter?)
}

class ColorSelectView: UIView {
    weak var delegate : ColorSelectViewDelegate?
    
    private var selected : ColorFilter?
    private let contentTB = UITableView()
    private var colorFilters = [ColorFilter]()
    private let allCF = ColorFilter()
    
    init(frame : CGRect, filters : [ColorFilter]) {
        super.init(frame: frame)
        
        allCF.name = DJStringUtil.localize("All Colors", comment:"")
        allCF.id = "-1"
        allCF.colorValue = DJCommonStyle.ColorEA
        
        colorFilters.append(allCF)
        colorFilters.appendContentsOf(filters)
        
        addSubview(contentTB)
        
        contentTB.showsVerticalScrollIndicator = false
        contentTB.separatorStyle = .None
        contentTB.registerClass(ColorSelectTableCell.self, forCellReuseIdentifier: "ColorSelectTableCell")
        contentTB.delegate = self
        contentTB.dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentTB.frame = bounds
    }
    
    func resetSelected(color : ColorFilter?){
        if color == nil {
            selected = allCF
        }else{
            selected = color
        }
        contentTB.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorSelectView: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 45
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return colorFilters.count
    }
    
    // Default is 1 if not implemented
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cf = colorFilters[indexPath.row]
        
        var cell = ColorSelectTableCell()
        if let tmp = tableView.dequeueReusableCellWithIdentifier("ColorSelectTableCell"){
            cell = (tmp as! ColorSelectTableCell)
        }
        cell.label.text = cf.name
        cell.colorIV.backgroundColor = cf.colorValue
        
        if indexPath.row == 0 {
             cell.addSubview(cell.allLabel)
        }else{
            cell.allLabel.removeFromSuperview()
        }
        
        if indexPath.row == colorFilters.count - 1 {
            cell.colorIV.layer.borderWidth = 0.5
            cell.colorIV.layer.borderColor = DJCommonStyle.ColorCE.CGColor
        }else{
            cell.colorIV.layer.borderWidth = 0
        }
        if selected != nil && selected!.id == cf.id{
            cell.setTheLableColor(UIColor.defaultRed())
            cell.addSubview(cell.circleIV)
        }else{
            cell.setTheLableColor(UIColor.defaultBlack())
            cell.circleIV.removeFromSuperview()
        }
  
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selected = colorFilters[indexPath.row]
        contentTB.reloadData()
        if selected != allCF{
            delegate?.colorSelectViewSelectColor(self, color: selected)
        }else{
            delegate?.colorSelectViewSelectColor(self, color: nil)
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

class ColorSelectTableCell : ListSimpleLabelTableCell {
    let colorIV = UIImageView()
    let circleIV = UIImageView()
    let allLabel = DJLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        colorIV.layer.cornerRadius = 13
        addSubview(colorIV)
        
        label.withFontHeletica(16)
        
        circleIV.layer.borderWidth = 1
        circleIV.layer.borderColor = UIColor.defaultRed().CGColor
        circleIV.layer.cornerRadius = 18
        
        backgroundColor = UIColor.whiteColor()
        
        allLabel.withText("ALL").withFontHeletica(11).withTextColor(DJCommonStyle.Color81).textCentered()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorIV.frame = CGRectMake(23, frame.size.height / 2 - 13, 26, 26)
        allLabel.frame = colorIV.frame
        circleIV.frame = CGRectMake(colorIV.frame.origin.x - 5, colorIV.frame.origin.y - 5, 36, 36)
        label.frame = CGRectMake(73, 0, frame.size.width - 73 - 26, frame.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
