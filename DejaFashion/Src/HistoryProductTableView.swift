//
//  HistoryProductTableView.swift
//  DejaFashion
//
//  Created by jiao qing on 13/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


protocol HistoryProductTableViewDelegate : NSObjectProtocol{
    func historyProductTableView(tableview : HistoryProductTableView, didClickDeleteCloth cloth: Clothes?)
    func historyProductTableView(tableview : HistoryProductTableView, didClickCloth cloth: Clothes?)
}

class HistoryProductTableView: UITableView{
    private var data = [String : [Clothes]]()
    weak var listDelegate : HistoryProductTableViewDelegate?
    private var names = [String]()
    
    private var singleSelected : NSIndexPath?
    
    private var deSections = NSMutableIndexSet()
    private var deleteRows = [NSIndexPath]()
    
    private let emptyView = UIView()
    
    var clothes: [String : [Clothes]] {
        get {
            return data
        }
        set {
            data = newValue
            names = Array(data.keys) as [String]
            
            names.sortInPlace ({$0 > $1})
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.showsVerticalScrollIndicator = false
        separatorStyle = .None
        registerClass(DJProductListCell.self, forCellReuseIdentifier: "DJProductListCell")
        delegate = self
        dataSource = self
        
        backgroundColor = UIColor.whiteColor()
        
        self.tintColor = UIColor.defaultRed()
        
        emptyView.frame = bounds
        
        let reminderLabel = UILabel(frame: CGRectMake(20, 60, UIScreen.mainScreen().bounds.size.width - 40, 60))
        emptyView.addSubview(reminderLabel)
        reminderLabel.textAlignment = .Center
        reminderLabel.numberOfLines = 0
        reminderLabel.withFontHeletica(17).withTextColor(UIColor.defaultBlack()).withText("No history yet.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showEmptyView(show : Bool){
        if show{
            addSubview(emptyView)
        }else{
            emptyView.removeFromSuperview()
        }
    }
    
    func getSelectedRows() -> [NSIndexPath]{
        if singleSelected != nil {
            return [singleSelected!]
        }else{
            if let tmp = self.indexPathsForSelectedRows{
                return tmp
            }
        }
        return [NSIndexPath]()
    }
    
    func getSelectedDeleteClothes() -> [String]{
        var ret = [String]()
        let rows = getSelectedRows()
        for one in rows {
            if let tmp = getClothFromIndexPath(one) {
                ret.append(tmp.uniqueID!)
            }
        }
        return ret
    }
    
 
    func bulkDeleteSelectedRowsStart(){
        let rows = getSelectedRows()
        
        let sectionCnt = numberOfSectionsInTableView(self)
        if sectionCnt < 1 {
            return
        }
        var sectionRows = [Int](count: sectionCnt, repeatedValue: 0)
        for one in rows {
            sectionRows[one.section] += 1
        }
        
        deSections = NSMutableIndexSet()
        for one in 0...sectionCnt - 1{
            sectionRows[one] = numberOfRowsInSection(one) - sectionRows[one]
            if sectionRows[one] <= 0 {
                deSections.addIndex(one)
            }
        }
        
        deleteRows.removeAll()
        for one in rows {
            if sectionRows[one.section] > 0 {
                deleteRows.append(one)
            }
        }
    }
    
    func bulkDeleteSelectedRowsEnd(){
        beginUpdates()
        deleteSections(deSections, withRowAnimation: .Fade)
        deleteRowsAtIndexPaths(deleteRows, withRowAnimation: .Fade)
        endUpdates()
    }
    
}

extension HistoryProductTableView: UITableViewDelegate, UITableViewDataSource {
    func getClothFromIndexPath(indexPath : NSIndexPath) -> Clothes?{
        guard let sectionClothes = data[names[indexPath.section]] else {
            return nil
        }
        if indexPath.row >= sectionClothes.count {
            return nil
        }
        return sectionClothes[indexPath.row]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[names[section]]!.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let conV = UIView(frame : CGRectMake(0, 0, self.frame.size.width, 37))
        conV.backgroundColor = UIColor(fromHexString: "fafafa")
        
        let narLabel = UILabel(frame : CGRectMake(23, 0, self.frame.size.width - 23 * 2, 37))
        narLabel.withTextColor(UIColor.defaultBlack())
        narLabel.withText(names[section]).withFontHeletica(14)
        conV.addSubview(narLabel)
        
        return conV
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        showEmptyView(names.count == 0)
        return names.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !tableView.editing {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            listDelegate?.historyProductTableView(self, didClickCloth: getClothFromIndexPath(indexPath))
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let theClothes = getClothFromIndexPath(indexPath) else {
            return DJProductListCell()
        }
        
        if let tmp = tableView.dequeueReusableCellWithIdentifier("DJProductListCell"){
            let cell = tmp as! DJProductListCell
            cell.product = theClothes
            cell.editingAccessoryType = .None
            return cell
        }else{
            return DJProductListCell()
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        singleSelected = indexPath
        listDelegate?.historyProductTableView(self, didClickDeleteCloth: getClothFromIndexPath(indexPath))
    }
    
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath?) {
        singleSelected = nil
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 101
    }
}
