//
//  BrowerClothHistoryViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 13/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class BrowerClothHistoryViewController: DJBasicViewController, HistoryProductTableViewDelegate {
    private let tableView = HistoryProductTableView()
    private var history = HistoryDataContainer.sharedInstance.queryAll()
    private var data = [String : [Clothes]]()
    private let bottomView = UIView()
    
    private lazy var barItem : UIBarButtonItem = {
        let edit = UIButton.init(type: .Custom)
        edit.withTitle("Edit").withTitleColor(UIColor.whiteColor()).withFontHeletica(15)
        edit.frame = CGRectMake(44, 0, 50, 44)
        edit.contentHorizontalAlignment = .Right
        edit.addTarget(self, action: #selector(editDidClicked), forControlEvents: .TouchUpInside)
        
        return UIBarButtonItem(customView : edit)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = DJStringUtil.localize("History", comment:"")
        tableView.listDelegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        
        view.addSubview(tableView)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 55, 0)
        constrain(tableView) { tableView in
            tableView.top == tableView.superview!.top
            tableView.bottom == tableView.superview!.bottom
            tableView.left == tableView.superview!.left
            tableView.right == tableView.superview!.right
        }
 
        reFetchHistory()
        tableView.clothes = data
        tableView.reloadData()
        
        buildBottomView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = barItem
    }
    
    private func reFetchHistory(){
        history = HistoryDataContainer.sharedInstance.queryAll()
        data.removeAll()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for one in history {
            if let date = one.timeStamp as? NSTimeInterval{
                let key = formatter.stringFromDate(NSDate.init(timeIntervalSince1970: date))
                if data[key] == nil {
                    data[key] = [one]
                }else{
                    data[key]!.append(one)
                }
            }
        }
    }
    
    @objc private func editDidClicked(){
        tableView.setEditing(!tableView.editing, animated: true)
        bottomViewShow(tableView.editing)
    }

    @objc private func removeBtnDidClicked(){
        let clothIds = tableView.getSelectedDeleteClothes()
        
        HistoryDataContainer.sharedInstance.removeClothesFromHistory(clothIds)
        reFetchHistory()
        
        tableView.bulkDeleteSelectedRowsStart()
        tableView.clothes = data
        tableView.bulkDeleteSelectedRowsEnd()
        
        tableView.setEditing(false, animated: true)
        bottomViewShow(false)
    }
    
    @objc private func cancelBtnDidClicked(){
        tableView.setEditing(false, animated: true)
        bottomViewShow(false)
    }
     
    private func bottomViewShow(show : Bool){
        if show {
            view.addSubview(bottomView)
            bottomView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 55)
            UIView.animateWithDuration(0.3, animations: {
                self.bottomView.frame = CGRectMake(0, self.view.frame.size.height - 55, self.view.frame.size.width, 55)
            })
        }else{
            UIView.animateWithDuration(0.3, animations: {
                self.bottomView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 55)
                }, completion: {(Bool) -> Void in
                    self.bottomView.removeFromSuperview()
            })
        }
    }
    
    private func buildBottomView(){
        let removeBtn = UIButton()
        bottomView.backgroundColor = UIColor.whiteColor()
        
        bottomView.addSubview(removeBtn)
        removeBtn.translatesAutoresizingMaskIntoConstraints = false
        removeBtn.addTarget(self, action: #selector(removeBtnDidClicked), forControlEvents: .TouchUpInside)
        removeBtn.withTitle(DJStringUtil.localize("Remove", comment:"")).withFontHeletica(14).withTitleColor(UIColor.defaultBlack())
        NSLayoutConstraint(item: removeBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: bottomView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: removeBtn, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: bottomView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 23).active = true
        NSLayoutConstraint(item: removeBtn, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: bottomView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0).active = true
        
        
        let cancelBtn = UIButton()
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidClicked), forControlEvents: .TouchUpInside)
        cancelBtn.withTitle(DJStringUtil.localize("Cancel", comment:"")).withFontHeletica(14).withTitleColor(UIColor.defaultBlack())
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: bottomView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Right, relatedBy: .Equal, toItem: bottomView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -23).active = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: bottomView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0).active = true
        
        
        bottomView.addTopBorder()
    }
    
    func historyProductTableView(tableview : HistoryProductTableView, didClickDeleteCloth cloth: Clothes?){
        removeBtnDidClicked()
    }
    
    func historyProductTableView(tableview : HistoryProductTableView, didClickCloth cloth: Clothes?){
        pushClothDetailVC(cloth)
    }
    
}
