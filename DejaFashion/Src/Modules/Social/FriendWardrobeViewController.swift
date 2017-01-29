//
//  FriendWardrobeViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 23/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class FriendWardrobeViewController: CategoryIndexableViewController, MONetTaskDelegate {
    
    var user : DejaFriend?
    
    var userId : String?
    
    let rightIcon = UIControl(frame: CGRectMake(0, 0, 44, 44))
    
    var clothesList = [Clothes]()
    
    var resultFetched = false
    
    override func viewDidLoad() {
        needAllCategory = true
        super.viewDidLoad()
        var url : NSURL?
        if let name = user?.name {
            title = "\(name)'s Wardrobe"
        }
        
        if let urlString = user?.avatar {
            url = NSURL(string: urlString)
        }

        let rightAvatar = UIImageView(frame: CGRect(x: 14, y: 12, width: 24, height: 24))
        if let u = url {
            rightAvatar.sd_setImageWithURL(u, placeholderImage: UIImage(named: "MeDefaultAvatar"))
        }else {
            rightAvatar.image = UIImage(named: "MeDefaultAvatar")
        }
        rightIcon.addSubview(rightAvatar)
        rightAvatar.layer.cornerRadius = 12
        rightAvatar.clipsToBounds = true
//        rightAvatar.addTapGestureTarget(self, action: Selector("unFriend"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightIcon)
        fetchClothesList()
    }
    
    func fetchClothesList() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        let task = GetFriendWardrobeNetTask()
        if let uid = user?.uid {
            task.buddyUid = uid
        }else {
            task.buddyUid = self.userId
        }
        MONetTaskQueue.instance().addTask(task)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if let t = task as? GetFriendWardrobeNetTask {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.clothesList = t.clothesList
            refreshWardrobe()
            if t.missionOutfitId != 0 {
                user?.missionOutfitId = t.missionOutfitId
            }
            if let id = t.mission?.id {
                user?.missionId = Int(id)!
            }
            if user == nil {
                user = t.friendInfo
                if let name = user?.name {
                    title = "\(name)'s Wardrobe"
                }
            }
            resultFetched = true
        }
        
        if let _ = task as? UnFriendNetTask {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if let _ = task as? UnFriendNetTask {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
        if let _ = task as? GetFriendWardrobeNetTask {
            showNetworkUnavailableView()
        }
    }
    
    override func emptyViewButtonDidClick(emptyView: DJEmptyView!) {
        hideNetworkUnavailableView()
        fetchClothesList()
    }
    
    func unFriend() {
        let popup = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: DJStringUtil.localize("Cancel", comment:""), destructiveButtonTitle: nil, otherButtonTitles: DJStringUtil.localize("Unfriend", comment:""))
        popup.showInView(self.view)
    }
    
    func refreshWardrobe() {
        if let drawer = currentCategoryView as? FriendDrawerView {
            let categoryToClothes = WardrobeDataContainer.sharedInstance.categoryClothes(clothesList)
            drawer.name = categoryView.currentCategory!.name
            if resultFetched {
                drawer.enableEmptyView()
            }
            drawer.items = categoryToClothes[categoryView.currentCategory!.name]
            drawer.showContent()
        }
    }
    
    func sendUnFriendNetTask() {
        let task = UnFriendNetTask()
        task.buddyUid = user?.uid
        MONetTaskQueue.instance().addTask(task)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
    }
    
    override func categoryForView(categoryView: CategoryView, category: ClothCategory) -> UIView {
        let categoryToClothes = WardrobeDataContainer.sharedInstance.categoryClothes(clothesList)
        let drawer = FriendDrawerView()
        drawer.frame = view.bounds
        drawer.showContent()
        drawer.name = category.name
        drawer.items = categoryToClothes[category.name]
        categoryIdToView[category.categoryId] = drawer
        return drawer
    }
    
    override func categoryViewCategoryDidChange(categoryView: CategoryView) {
        super.categoryViewCategoryDidChange(categoryView)
        WardrobeDataContainer.sharedInstance.clearNewAddedClothesIds()
        if let drawer = currentCategoryView as? FriendDrawerView {
            let categoryToClothes = WardrobeDataContainer.sharedInstance.categoryClothes(clothesList)
            if resultFetched {
                drawer.enableEmptyView()
            }
            drawer.name = categoryView.currentCategory!.name
            drawer.items = categoryToClothes[categoryView.currentCategory!.name]
            drawer.showContent()
        }
    }
}

extension FriendWardrobeViewController : UIActionSheetDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            sendUnFriendNetTask()
        }
    }
}
