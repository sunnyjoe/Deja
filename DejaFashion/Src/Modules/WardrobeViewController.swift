//
//  DJWardrobeViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 8/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit
import KLCPopup

class WardrobeViewController: CategoryIndexableViewController, MONetTaskDelegate {
    
    var lastRequestNewOutfitReddot = 0 as UInt64;
    
    let rightIcon = UIControl(frame: CGRectMake(0, 0, 60, 44))
    var radarView : WKFRadarView?
    
    private var popup : KLCPopup?
    
    init() {
        super.init(beginCategoryId: "0")
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        needAllCategory = true
        super.viewDidLoad()
        title = DJStringUtil.localize("My Wardrobe", comment: "")
    
        let rightLabel = DJButton(frame: CGRect(x: 10, y: 9, width: 60, height: 25)).withFontHeletica(15).withTitle(DJStringUtil.localize("Outfits", comment: "")).withHighlightTitleColor(UIColor.gray81Color())
        rightIcon.addSubview(rightLabel)
        rightLabel.addTapGestureTarget(self, action: #selector(WardrobeViewController.goToOutfits))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightIcon)
 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willEnterForground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        addDemoClothes()
        refreshWardrobe()
        MONetTaskQueue.instance().addTaskDelegate(self, uri: LogoutNetTask.uri())
    }
    
 
    func willEnterForground() {
        if self.isViewAppeared {
            sendReddotNetTask()
        }
    }
    
    func addRadarView() {
        removeRadarView()
        radarView = WKFRadarView(frame: CGRectMake(20, 0, 44, 44))
        radarView?.userInteractionEnabled = false
        rightIcon.addSubview(radarView!)
    }
    
    func removeRadarView() {
        radarView?.removeFromSuperview()
        radarView = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        registerIfNeeded()
        let lastHandleTime = WardrobeDataContainer.sharedInstance.uploadWardrobeCountTimeStamp.doubleValue
        let date = NSDate(timeIntervalSince1970: lastHandleTime)
    
        if date.pastMoreThanOneNaturalDay()
        {
            WardrobeDataContainer.sharedInstance.uploadWardrobeCountTimeStamp = NSNumber(double: NSDate().timeIntervalSince1970)
        }
        if radarView?.superview != nil {
            //re-add the view instead of resume it
            addRadarView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sendReddotNetTask()
    }
    
    
    func sendAdHocInfoNetTask() {
        let task = UserGuideMissionNetTask()
        MONetTaskQueue.instance().addTask(task)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
    }
    
    func sendReddotNetTask() {
        MONetTaskQueue.instance().addTask(ReddotNetTask())
        MONetTaskQueue.instance().addTaskDelegate(self, uri: ReddotNetTask.uri())
    }
    
    
    func netTaskDidEnd(task: MONetTask!) {
        if let reddotNetTask = task as? ReddotNetTask {
            if reddotNetTask.outfitNew > 0 {
                addRadarView()
                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
                    if sharedWebView?.superview == nil {
                        appDelegate.resetWebView()
                    }
                }
            }
        }
        
        if let t = task as? UserGuideMissionNetTask {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            if let user = t.userInfo {
                if let mission = t.mission {
                    showMissionInfoPopup(mission, user: user)
                }
            }
        }
        if let _ = task as? LogoutNetTask {
            refreshWardrobe()
        }
        
    }
    
    func showMissionInfoPopup(missionInfo : StylingMission, user : DejaFriend) {
        let contentView = MissionInfoView(frame: CGRectMake(0.0, 0.0, 256.0, 249.0), user: user, missionInfo: missionInfo)
        contentView.helpButton.addTarget(self, action: #selector(WardrobeViewController.helpToCreateOutfit(_:)), forControlEvents: .TouchUpInside)
        popup?.removeFromSuperview()//fix pop up twice
        popup = KLCPopup(contentView: contentView)
        navigationController?.view.addSubview(popup!)
        popup?.shouldDismissOnBackgroundTouch = true
        popup?.maskType = .Clear
        popup!.show()
    }
    
    func helpToCreateOutfit(button : UIButton) {
        popup?.dismiss(true)
        let v = LoginViewController()
        v.gotoFittingRoomIfSuccess = true
        if let f = button.property as? DejaFriend {
            v.friend = f
        }
        navigationController?.pushViewController(v, animated: true)
    }
    
    func netTaskDidFail(task: MONetTask!) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func registerIfNeeded() {
        if AccountDataContainer.sharedInstance.userID?.characters.count > 0 {
            
        }else {
            MONetTaskQueue.instance().addTask(RegisterNetTask())
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        WardrobeDataContainer.sharedInstance.clearNewAddedClothesIds()
        WardrobeDataContainer.sharedInstance.clearNewStreetSnapClothesIds()
    }
    
    func refreshWardrobe() {
        let categoryToClothes = WardrobeDataContainer.sharedInstance.queryWardrobe()
        if categoryToClothes["All"]?.count == 0 {
            rightIcon.hidden = true
        }else {
            rightIcon.hidden = false
        }
        if let drawer = currentCategoryView as? MyDrawerView {
            drawer.name = categoryView.currentCategory!.name
            drawer.delegate = self
            drawer.items = categoryToClothes[categoryView.currentCategory!.name]
            drawer.showContent()
        }
    }
    

    func goToOutfits() {
        DJStatisticsLogic.instance().addTraceLog(.Wardrobe_Click_Outfits)
        removeRadarView()
        let v = StyleViewController(URLString: ConfigDataContainer.sharedInstance.getOutfitsUrl())
        navigationController?.pushViewController(v, animated: true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func categoryForView(categoryView: CategoryView, category: ClothCategory) -> UIView {
        let categoryToClothes = WardrobeDataContainer.sharedInstance.queryWardrobe()
        let drawer = MyDrawerView()
        drawer.frame = view.bounds
        drawer.showContent()
        drawer.name = category.name
        drawer.delegate = self
        drawer.items = categoryToClothes[category.name]
        drawer.categoryId = category.categoryId
        categoryIdToView[category.categoryId] = drawer
        return drawer
    }
    
    override func categoryViewCategoryDidChange(categoryView: CategoryView) {
        super.categoryViewCategoryDidChange(categoryView)
        if let drawer = currentCategoryView as? MyDrawerView {
            let categoryToClothes = WardrobeDataContainer.sharedInstance.queryWardrobe()
            drawer.name = categoryView.currentCategory!.name
            drawer.delegate = self
            drawer.items = categoryToClothes[categoryView.currentCategory!.name]
            drawer.showContent()
        }
    }
}

extension WardrobeViewController {
    override func notificationNames() -> [AnyObject]! {
        return [syncSuccessNotification, DJNotifyDejaModelShapeChanged]
    }
    
    override func didReceiveNotification(notification: NSNotification!) {
        if notification.name == syncSuccessNotification {
            if let refreshCount = notification.object as? NSNumber {
                if refreshCount.integerValue > 0 {
                    refreshWardrobe()
                }
                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
                    if sharedWebView?.superview == nil {
                        appDelegate.resetWebView()
                    }else {
                        needRefreshOutfits = true
                    }
                }
            }
        }
        
        if notification.name == DJNotifyDejaModelShapeChanged {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
                if sharedWebView?.superview == nil {
                    appDelegate.resetWebView()
                }else {
                    needRefreshOutfits = true
                }
            }
        }
    }
}

extension WardrobeViewController : DrawerViewDelegate{
    func addDemoClothes() {
        
        let categoryToClothes = WardrobeDataContainer.sharedInstance.queryWardrobe()
        if categoryToClothes["All"]?.count == 0
        {
            let clothesList = ConfigDataContainer.sharedInstance.getDemoClothesList()
            WardrobeDataContainer.sharedInstance.addClothesListToWardrobe(clothesList)
            refreshWardrobe()
            dispatch_after(NSEC_PER_SEC / 5, dispatch_get_main_queue()) {
                let tutorialView = DJTutorialView(frame: CGRectMake(self.view.frame.width * 3 / 4 - 85.5, 200, 160, 55), direction: DJTurorialViewArrowDirectionTop)
                tutorialView.label.font = DJFont.fontOfSize(14)
                tutorialView.setText(DJStringUtil.localize("Check this Demo for it’s Style guide.", comment: ""))
                self.view.addSubview(tutorialView)
            }
        }
    }
}

extension WardrobeViewController {
    func onClickDeleteButton(ids: [String]) {
        WardrobeDataContainer.sharedInstance.removeClothesFromWardrobe(ids)
        refreshWardrobe()
    }
}

