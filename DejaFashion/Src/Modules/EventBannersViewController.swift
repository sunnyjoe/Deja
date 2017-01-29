//
//  EventViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 14/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class EventBannersViewController: DJBasicViewController, UITableViewDelegate, UITableViewDataSource {
    private let data = ConfigDataContainer.sharedInstance.getOfflineEvents()
    private let tableView = UITableView()
    let bannerHeight : CGFloat = 256
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = DJStringUtil.localize("Events", comment:"")
         
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.defaultBlack()
        tableView.separatorStyle = .None
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "EventBannersViewController")
        view.addSubview(tableView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return bannerHeight + 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let iv = UIImageView(frame : CGRectMake(0, 0, view.frame.size.width, bannerHeight))
        iv.sd_setImageWithURLStr(data[indexPath.row].imageUrl)
        iv.backgroundColor = UIColor.whiteColor()
        
        if let tmp = tableView.dequeueReusableCellWithIdentifier("EventBannersViewController"){
            tmp.removeAllSubViews()
            tmp.addSubview(iv)
            tmp.backgroundColor = UIColor.defaultBlack()
            return tmp
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let banner = data[indexPath.row]
        if let urlStr = banner.jumpUrl{
            if let url = NSURL(string : urlStr){
                DJAppCall.handleOpenURL(url, sourceApplication: "deja")
            }
        }
    }
}
