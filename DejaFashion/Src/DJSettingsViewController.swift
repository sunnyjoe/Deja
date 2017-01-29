//
//  SettingsViewController.swift
//  DejaFashion
//
//  Created by Sun lin on 28/7/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

import UIKit
import SDWebImage

let kDJPhotoPermissionAlertViewTage = 1342
let kDJSettingsClearCacheAlertViewTag = 1001
let kDJSettingsSignOutAlertViewTag = 1000

class SettingsViewController: DJBasicViewController,DJAlertViewDelegate
{
    
    private var tableView = UITableView()
    private var cells = [[MOTableCellBuilder]]()
    private var justClearCache = false
    private let usageLabel = UILabel()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DJStringUtil.localize("Settings", comment:"")
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        self.refreshData()
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: UITableViewStyle.Grouped)
        
        self.tableView.contentInset = UIEdgeInsetsMake(-25, 0, 70, 0);
        self.tableView.autoresizingMask = UIViewAutoresizing.FlexibleHeight;
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor(fromHexString: "e4e4e4")
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        self.view.addSubview(self.tableView)
        
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        let task = DJSetDeviceSettingNetTask()
        MONetTaskQueue.instance().addTask(task)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func notificationNames() -> [AnyObject]!
    {
        return [kDJAppWillEnterForeground]
    }
    
    override func didReceiveNotification(notification: NSNotification!)
    {
        if notification.name == kDJAppWillEnterForeground
        {
            self.appWillEnterForeground()
        }
    }
    
    func appWillEnterForeground()
    {
        self.tableView.reloadData()
    }
    
    func refreshData()
    {
        
        var section0 = [MOTableCellBuilder]()
        var section1 = [MOTableCellBuilder]()
        var section2 = [MOTableCellBuilder]()
        var section3 = [MOTableCellBuilder]()
        
        if let cell = self.buildFacebookConnectCell()
        {
            section0.append(cell)
        }
        section1.append(self.buildDealAlertCell())
        section2.append(self.buildClearImageCacheCell())
        section2.append(self.buildAboutCell())
        section2.append(self.buildRateInAppStoreCell())
        section2.append(self.buildFacebookCell())
        section2.append(self.buildInstagramCell())
        section2.append(self.buildTermsCell())
        section2.append(self.buildContactUsCell())
        if let cell = self.buildSignOutCell()
        {
            section3.append(cell)
        }
        
        self.cells = [[MOTableCellBuilder]]()
        self.cells.append(section0)
        self.cells.append(section1)
        self.cells.append(section2)
        self.cells.append(section3)
    }
    
    
    func didChangeDealAlert(pushControlSwitch : UISwitch){
        DJConfigDataContainer.instance().pushControlDealAlertOn = pushControlSwitch.on
    }
    
    
    func alertView(alertView: DJAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        switch alertView.tag {
        case kDJSettingsClearCacheAlertViewTag:
            if buttonIndex == 1 {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                
                weak var weakSelf = self
                SDImageCache.sharedImageCache().clearDiskOnCompletion(){
                    if weakSelf == nil {
                        return
                    }
                    
                    weakSelf?.justClearCache = true
                    weakSelf?.resetCacheUsageLabel()
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
                        MBProgressHUD.hideHUDForView(weakSelf!.view, animated: true)
                    }
                }
            }
        case kDJSettingsSignOutAlertViewTag:
            if buttonIndex == 1 {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                let lnt = LogoutNetTask()
                MONetTaskQueue.instance().addTaskDelegate(self, uri: lnt.uri())
                MONetTaskQueue.instance().addTask(lnt)
            }
        default:
            return
        }
    }
    
    
    func resetCacheUsageLabel(){
        usageLabel.withText("0 MB")
        usageLabel.sizeToFit()
    }
    
    
    
}

extension SettingsViewController : MONetTaskDelegate
{
    
    func sendUnBindFacebookNetTask() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task = UnBindAccountNetTask()
        task.accountType = AccountType.Facebook
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
        MONetTaskQueue.instance().addTask(task)
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        
        MBProgressHUD.hideHUDForView(view, animated: true)
        if let netTask = task as? UnBindAccountNetTask {
            if netTask.accountType == .Facebook {
                self.tableView.reloadData()
            }
        }
        
        if task.isKindOfClass(LogoutNetTask){
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    
    
    func netTaskDidFail(task: MONetTask!) {
        MBProgressHUD.hideHUDForView(view, animated: true)
        if let netTask = task as? BindAccountNetTask {
            if netTask.error.code == 7{
                let message = DJStringUtil.localize("This Facebook account has already binding to another phone number.", comment:"")
                let alertView = DJAlertView(title: DJStringUtil.localize("Oops", comment:""), message: message, cancelButtonTitle: "OK")
                alertView.show()
            }else if netTask.error.code == 6{
                let message = DJStringUtil.localize("This Facebook account has already login independent.", comment:"")
                let alertView = DJAlertView(title: DJStringUtil.localize("Oops", comment:""), message: message, cancelButtonTitle: "OK")
                alertView.show()
            }else {
                
            }
        }
        
        if task.isKindOfClass(LogoutNetTask){
            MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Failed to sign out. Network is not available.", comment:""), animated: true)
        }
    }
    
}

extension SettingsViewController : UIActionSheetDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == 2 {
            if buttonIndex == 1 {
                sendUnBindFacebookNetTask()
            }
        }
    }
    
    
}


extension SettingsViewController: ThirdPartyLoginDelegate
{
    
    
    func thirdPartyBindDidError() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func thirdPartyBindDidSuccess() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
//        fbLabel.text = AccountDataContainer.sharedInstance.bindedFacebookInfo?.identifier
//        arrowIcon.hidden = true
//        connectStateLabel.hidden = false
        self.tableView.reloadData()
    }
    
    func thirdPartyBindDidCanceled() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
}
extension SettingsViewController
{
    
    
    func buildFacebookConnectCell() -> MOTableCellBuilder?
    {
        if AccountDataContainer.sharedInstance.isAnonymous()
        {
            return nil
        }
        if AccountDataContainer.sharedInstance.currentAccountType != .Facebook {
            let cellBuilder = MOTableCellBuilder()
            cellBuilder.height = 55
            let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
                
                if let _ = AccountDataContainer.sharedInstance.bindedFacebookInfo {
                    let popup = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: DJStringUtil.localize("Cancel", comment:""), destructiveButtonTitle: nil, otherButtonTitles: DJStringUtil.localize("Unbind Facebook", comment:""))
                    popup.tag = 2
                    popup.showInView(self.view)
                }else {
                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    DJLoginLogic.instance().setContainerView(self.view)
                    DJLoginLogic.instance().bindFacebook()
                    DJLoginLogic.instance().addDelegate(self)
                    MONetTaskQueue.instance().addTaskDelegate(self, uri: BindAccountNetTask.uri())
                }
                return false
            }
            let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
                let cell = self.commonCell(tableView, title: "")
                cell.imageView?.image = UIImage(named: "FBIcon")
    
                
                if let info = AccountDataContainer.sharedInstance.bindedFacebookInfo {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                    cell.textLabel?.text = info.identifier
                    cell.detailTextLabel?.text = DJStringUtil.localize("Connected", comment:"")
                }else {
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
                    cell.textLabel?.text = DJStringUtil.localize("Connect Facebook", comment:"")
                    cell.detailTextLabel?.text = nil
                }
                return cell
            }
            cellBuilder.action = action
            cellBuilder.builder = view
            return cellBuilder
        }
        return nil
    }
    
    
    
    func buildDealAlertCell() -> MOTableCellBuilder
    {
        let cellBuilder = MOTableCellBuilder()
        cellBuilder.height = 55
        weak var weakSelf = self;
        let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
            if DJDeviceOS.enableNotification() == false
            {
                
                let dialog = Dialog().withIcon(UIImage(named: "NotificationIcon")).withText(DJStringUtil.localize("Please turn on Notification Services in your device settings to get deal alert.", comment:"")).withOkBtnText(DJStringUtil.localize("Go To Settings", comment:"")).withCancelBtnText(DJStringUtil.localize("No Thanks", comment:""))
                dialog.show({
                    
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString)
                    {
                        UIApplication.sharedApplication().openURL(url)
                    }
                    }, didClickCancel: {
                        
                })
                
            }
            return false
        }
        let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
            let cell = self.commonCell(tableView, title: DJStringUtil.localize("Deal Alert", comment:""))
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            let pushControlSwitch = UISwitch()
            pushControlSwitch.on = DJConfigDataContainer.instance().pushControlDealAlertOn
            pushControlSwitch.addTarget(weakSelf, action: #selector(SettingsViewController.didChangeDealAlert(_:)), forControlEvents: UIControlEvents.ValueChanged)
            cell.accessoryView = pushControlSwitch;
            if DJDeviceOS.enableNotification()
            {
                pushControlSwitch.enabled  = true
            }
            else
            {
                pushControlSwitch.enabled  = false
                pushControlSwitch.on = false
            }
            return cell;
        }
        cellBuilder.action = action
        cellBuilder.builder = view
        return cellBuilder
    }
    
    func buildClearImageCacheCell() -> MOTableCellBuilder
    {
        let cellBuilder = MOTableCellBuilder()
        cellBuilder.height = 55
        let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
            weak var weakSelf = self
            let alertView = DJAlertView(title: DJStringUtil.localize("Are you sure you want to clear all image cache?", comment:""),
                                        message: DJStringUtil.localize("Clearing image cache will help you save space and does not affect your style list.", comment:""),
                                        delegate: weakSelf,
                                        cancelButtonTitle:DJStringUtil.localize("Cancel", comment:""),
                                        otherButtonTitlesArray: ["Clear Cache"])
            alertView.tag = kDJSettingsClearCacheAlertViewTag
            alertView.show()
            
            return false
        }
        let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
            let cell = self.commonCell(tableView, title: DJStringUtil.localize("Clear Image Cache", comment:""))
            
            self.usageLabel.withTextColor(UIColor(fromHexString: "cecece")).withFontHeletica(15)
            cell.accessoryView = self.usageLabel
            
            if !self.justClearCache{
                weak var weakUsageLabel = self.usageLabel
                weak var weakclearCache = cell
                SDImageCache.sharedImageCache().calculateSizeWithCompletionBlock() {(fileCount:UInt, totalSize:UInt) in
                    let size = Float(totalSize) / 1024.0 / 1024.0
                    if weakclearCache == nil || weakclearCache == nil {
                        return
                    }
                    weakUsageLabel!.text = String(format: "%.2f MB", size)
                    weakUsageLabel!.sizeToFit()
                    weakUsageLabel!.frame = CGRectMake(weakclearCache!.frame.size.width - 20 - weakUsageLabel!.frame.size.width, 0, weakUsageLabel!.frame.size.width, weakclearCache!.frame.size.height)
                }
            }else{
                self.usageLabel.withText("0 MB")
                self.usageLabel.sizeToFit()
                self.usageLabel.frame =  CGRectMake(cell.frame.size.width - 20 - self.usageLabel.frame.size.width, 0, self.usageLabel.frame.size.width, cell.frame.size.height)
            }
            return cell;
        }
        cellBuilder.action = action
        cellBuilder.builder = view
        return cellBuilder
    }
    
    
    func buildAboutCell() -> MOTableCellBuilder
    {
        let cellBuilder = MOTableCellBuilder()
        cellBuilder.height = 55
        let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
            self.navigationController?.pushViewController(DJAboutViewController(), animated: true)
            return false
        }
        let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
            let cell = self.commonCell(tableView, title: DJStringUtil.localize("About Deja", comment:""))
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            return cell;
        }
        cellBuilder.action = action
        cellBuilder.builder = view
        return cellBuilder
    }
    
    
    func buildRateInAppStoreCell() -> MOTableCellBuilder
    {
        let cellBuilder = MOTableCellBuilder()
        cellBuilder.height = 55
        let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
            var urlStr = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(kDJAppstoreId)"
            if Float(UIDevice.currentDevice().systemVersion) > 7 {
                urlStr = "itms-apps://itunes.apple.com/app/id\(kDJAppstoreId)"
            }
            UIApplication.sharedApplication().openURL(NSURL(string: urlStr)!)
            return false
        }
        let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
            let cell = self.commonCell(tableView, title: DJStringUtil.localize("Rate us in the App Store", comment:""))
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            return cell;
        }
        cellBuilder.action = action
        cellBuilder.builder = view
        return cellBuilder
    }
    
    
    func buildFacebookCell() -> MOTableCellBuilder
    {
        let cellBuilder = MOTableCellBuilder()
        cellBuilder.height = 55
        let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
            UIApplication.sharedApplication().openURL(NSURL(string: "https://m.facebook.com/profile.php?id=358351671023124")!)
            return false
        }
        let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
            let cell = self.commonCell(tableView, title: DJStringUtil.localize("Like us on Facebook", comment:""))
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            return cell;
        }
        cellBuilder.action = action
        cellBuilder.builder = view
        return cellBuilder
    }
    
    
    func buildInstagramCell() -> MOTableCellBuilder
    {
        let cellBuilder = MOTableCellBuilder()
        cellBuilder.height = 55
        let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.instagram.com/dejastyling/")!)
            return false
        }
        let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
            let cell = self.commonCell(tableView, title: DJStringUtil.localize("Follow us on Instagram", comment:""))
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            return cell;
        }
        cellBuilder.action = action
        cellBuilder.builder = view
        return cellBuilder
    }
    
    func buildTermsCell() -> MOTableCellBuilder
    {
        let cellBuilder = MOTableCellBuilder()
        cellBuilder.height = 55
        let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
            let webVC = TermsViewController(URLString: ConfigDataContainer.sharedInstance.getTermsUrl())
            webVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(webVC, animated: true)
            return false
        }
        let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
            let cell = self.commonCell(tableView, title: DJStringUtil.localize("Terms of Service", comment:""))
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            return cell;
        }
        cellBuilder.action = action
        cellBuilder.builder = view
        return cellBuilder
    }
    
    
    func buildContactUsCell() -> MOTableCellBuilder
    {
        
        let cellBuilder = MOTableCellBuilder()
        cellBuilder.height = 55
        let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
            
            //        Feedback-${user_id}-${platform}-${version}
            
            DJStatisticsLogic.instance().addTraceLog(.Setting_Click_ContactUs)
            if let recipient = ConfigDataContainer.sharedInstance.getFeedbackEmail() {
                //mailto:sample@163.com?subject=test&cc=sample@hotmail.com&body=use mailto sample
                var subject = "Feedback-"
                
                if let uid = AccountDataContainer.sharedInstance.userID {
                    subject += uid + "-"
                }
                
                if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
                    subject += version + "-"
                }
                
                subject += "iOS"
                
                
                UIApplication.sharedApplication().openURL(NSURL(string: "mailto:\(recipient)?subject=\(subject)" )!)
            }
            return false
        }
        let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
            let cell = self.commonCell(tableView, title: DJStringUtil.localize("Contact Us", comment:""))
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            return cell;
        }
        cellBuilder.action = action
        cellBuilder.builder = view
        return cellBuilder
    }
    
    
    func buildSignOutCell() -> MOTableCellBuilder?
    {
        if AccountDataContainer.sharedInstance.currentAccountType != .Anonymous {
            
            let cellBuilder = MOTableCellBuilder()
            cellBuilder.height = 55
            let action : (UITableView!, NSIndexPath!) -> Bool = { tableView, indexPath in
                weak var weakSelf = self
                let alertView = DJAlertView(title: "", message: DJStringUtil.localize("Are you sure you want to sign out?", comment:""), delegate: weakSelf, cancelButtonTitle:DJStringUtil.localize("Cancel", comment:""), otherButtonTitlesArray: ["Sign Out"])
                alertView.tag = kDJSettingsSignOutAlertViewTag
                alertView.show()
                return false
                }
            let view : (UITableView!, NSIndexPath!) -> UITableViewCell! = { tableView, indexPath in
                let cell = self.commonCell(tableView, title: DJStringUtil.localize("Sign Out", comment:""))
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
                return cell;
            }
            cellBuilder.action = action
            cellBuilder.builder = view
            return cellBuilder
        }
        return nil
    }
    
    
    
    func commonCell(tableView : UITableView, title: String) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        cell.selectedBackgroundView = UIView(frame: cell.bounds)
        cell.selectedBackgroundView!.backgroundColor = UIColor(fromHexString: "f9f9f9")
        cell.textLabel?.text = title
        cell.textLabel?.textColor = UIColor(fromHexString: "414141")
        cell.textLabel?.font = DJFont.contentFontOfSize(16)
        return cell
    }
    
}

extension SettingsViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let sections : [MOTableCellBuilder] = self.cells[indexPath.section]
        return CGFloat(sections[indexPath.row].height)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sections : [MOTableCellBuilder] = self.cells[section]
        return sections.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if section == 1
        {
            let view = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 50))
            let footView = UILabel(frame: CGRectMake(10, 0, view.bounds.size.width - 20, view.bounds.size.height))
            footView.text = DJStringUtil.localize("We will give you an alert when items in your Favorites List offers a promotion.", comment:"")
            footView.textColor = UIColor.gray81Color()
            footView.font = DJFont.fontOfSize(14)
            footView.lineBreakMode = NSLineBreakMode.ByWordWrapping
            footView.numberOfLines = 2
            view.addSubview(footView)
            return view;
        }
        return nil
    }
    
    // Default is 1 if not implemented
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.cells.count
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if section == 1
        {
            return 32
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let sections : [MOTableCellBuilder] = self.cells[indexPath.section]
        let cell = sections[indexPath.row].builder(tableView, indexPath)
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = DJCommonStyle.DividerColor.CGColor
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let sections : [MOTableCellBuilder] = self.cells[indexPath.section]
        if sections[indexPath.row].action != nil
        {
            sections[indexPath.row].action(tableView, indexPath)
        }
        
    }
    
}
