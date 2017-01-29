//
//  FriendListViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 22/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
import KLCPopup
class FriendListViewController: DJBasicViewController, MONetTaskDelegate {
    
//    let rightIcon = UIButton(frame: CGRectMake(0, 0, 30, 44))
    
    let tableView = UITableView()
    var users = [DejaFriend]()
    
    let refreshControl = UIRefreshControl()
    var listEnded = false
    var loading = false
    var currentPage = 0
    
    var emptyView : UIView?
    var needRefreshData = false
    
    var bottomBar = UIView()
    
    var popup : KLCPopup?
    
    let messageIcon = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = DJStringUtil.localize("Friends", comment: "")
        
        view.addSubviews(tableView, bottomBar)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .None
        tableView.showsVerticalScrollIndicator = false
        
        refreshControl.addTarget(self, action: #selector(FriendListViewController.onPullToFresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: UnFriendNetTask.uri())
        MONetTaskQueue.instance().addTaskDelegate(self, uri: AddFriendConfrimNetTask.uri())
        
        addIcons()
    }
    
 
    func addIcons() {
        let divider = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        divider.withBackgroundColor(DJCommonStyle.DividerColor)
        
        let addFriendIcon = UIButton()
        
        bottomBar.addSubviews(divider,addFriendIcon,messageIcon)
        
        constrain(addFriendIcon, messageIcon) { (addFriendIcon, messageIcon) in
            addFriendIcon.left == addFriendIcon.superview!.left
            addFriendIcon.top == addFriendIcon.superview!.top
            addFriendIcon.height == 70
            
            messageIcon.left == addFriendIcon.right
            messageIcon.top == addFriendIcon.superview!.top
            messageIcon.right == addFriendIcon.superview!.right
            messageIcon.height == 70
            
            addFriendIcon.width == addFriendIcon.width
            addFriendIcon.width == messageIcon.width
        }
        
        addFriendIcon.setImage(UIImage(named: "AddFriendIcon"), forState: .Normal)
        addFriendIcon.addTarget(self, action: #selector(FriendListViewController.addFriend), forControlEvents: .TouchUpInside)

        messageIcon.setImage(UIImage(named: "MessageIcon"), forState: .Normal)
        messageIcon.addTarget(self, action: #selector(FriendListViewController.goToMessageList), forControlEvents: .TouchUpInside)
        
        [addFriendIcon, messageIcon].forEach { (button) in
            button.imageEdgeInsets = UIEdgeInsets(top: -9, left: 0, bottom: 0, right: 0)
        }
        
        let addFriendLabel = UILabel(frame: CGRectMake(0, 41, view.frame.width / 2, 18)).withFontHeletica(12).withTextColor(DJCommonStyle.BackgroundColor).withText(DJStringUtil.localize("Find Friends", comment: "")).textCentered()
        let messagesLabel = UILabel(frame: CGRectMake(0, 41, view.frame.width / 2, 18)).withFontHeletica(12).withTextColor(DJCommonStyle.BackgroundColor).withText(DJStringUtil.localize("Activity", comment: "")).textCentered()
        
        addFriendIcon.addSubview(addFriendLabel)
        messageIcon.addSubview(messagesLabel)

    }
    
    func onPullToFresh() {
        fetchFriendList()
    }
    
    func goToMessageList() {
        messageIcon.hideRedDot()
        let v = MessageListViewController(URLString: ConfigDataContainer.sharedInstance.getMessageListUrl())
        v.useSingleWebview = true
        navigationController?.pushViewController(v, animated: true)
    }
    
    func fetchFriendList(page : Int = 0) {
        let task = FriendListNetTask()
        task.page = page
        MONetTaskQueue.instance().addTask(task)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
        loading = true
    }
    
    func addFriend() {
        navigationController?.pushViewController(AddFriendViewController(), animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 70)
        bottomBar.frame = CGRectMake(0, view.frame.height - 70, view.frame.width, 70)
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if let netTask = task as? FriendListNetTask {
            if netTask.page == 0 {
                if netTask.messageCount > 0 {
                    messageIcon.showRedDot(CGRectMake(view.frame.width / 4 + 10, 20, 14, 14), count: netTask.messageCount)
                }else {
                    messageIcon.hideRedDot()
                }
            }
            refreshControl.endRefreshing()
            if netTask.total == 0 {
                showEmptyView()
            }else {
                hideEmptyView()
                if netTask.page == 0 {
                    users = netTask.friends
                    tableView.setContentOffset(CGPointZero, animated: true)
                }else {
                    users.appendContentsOf(netTask.friends)
                }
            }
            listEnded = netTask.end
            currentPage = netTask.page
            loading = false
            tableView.reloadData()
        }
        
        if let t = task as? UnFriendNetTask {
            MBProgressHUD.hideHUDForView(view, animated: true)
            users = users.filter { $0.uid != t.buddyUid }
            if users.count == 0 {
                showEmptyView()
            }
            tableView.reloadData()
        }
        
        if let t = task as? RejectFriendRequestNetTask {
            MBProgressHUD.hideHUDForView(view, animated: true)
            users = users.filter { $0.uid != t.buddyUid }
            if users.count == 0 {
                showEmptyView()
            }
            tableView.reloadData()
        }
        
        if let t = task as? AddFriendConfrimNetTask {
            MBProgressHUD.hideHUDForView(view, animated: true)
            let user = users.filter { $0.uid == t.friendUid }.first
            user?.status = FriendStatus.normal
            user?.statusDesc = nil
            if user == nil {
                fetchFriendList()
            }else {
                tableView.reloadData()
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if let netTask = task as? FriendListNetTask {
            if netTask.page == 0 {
                showNetworkUnavailableView()
            }
            loading = false
        }
    }
    
    override func emptyViewButtonDidClick(emptyView: DJEmptyView!) {
        hideNetworkUnavailableView()
        fetchFriendList()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showHomeButton(true)
        if needRefreshData || tableView.contentOffset.y < 50{
            fetchFriendList()
            needRefreshData = false
        }
    }
}

extension FriendListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        let v = FriendWardrobeViewController(beginCategoryId : "0")
        v.user = user
        
        if user.status == .friendRequest {
            showFriendRequestDialogOfUser(user)
        }else {
            navigationController?.pushViewController(v, animated: true)
        }
        
        user.isNew = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let user = users[indexPath.row]
        cell.fillWithContentView({ (view : FriendView) -> Void in
            view.backgroundColor = UIColor.whiteColor()
            view.avatarView.frame = CGRectMake(23, 14.5, 41, 41)
            view.avatarView.layer.cornerRadius = 20.5
            view.avatarView.clipsToBounds = true
            view.nameLabel.frame = CGRectMake(view.avatarView.frame.maxX + 11, 19, 300, 18)
            view.nameLabel.withFontHeleticaMedium(15).withTextColor(DJCommonStyle.BackgroundColor)
            view.statusLabel.frame = CGRectMake(view.avatarView.frame.maxX + 9, view.nameLabel.frame.maxY + 5, 300, 16)
            view.statusLabel.withFontHeletica(14).withTextColor(DJCommonStyle.Color81)
            view.actionIcon.frame = CGRectMake(ScreenWidth - 77, 20, 52, 30)
            let divider = UIView(frame: CGRect(x: 23, y: 69.5, width: self.view.frame.width - 46, height: 0.5))
            divider.withBackgroundColor(DJCommonStyle.DividerColor)
            view.addSubviews(view.avatarView,view.nameLabel,view.statusLabel, divider)
            cell.addSubview(view.actionIcon)
            }, fillContentBlock: { (view : FriendView) -> Void in
                if let urlString = user.avatar {
                    if let url = NSURL(string: urlString) {
                        view.avatarView.sd_setImageWithURL(url, placeholderImage: UIImage(named: defaultBlackAvatarImageName))
                    }else {
                        view.avatarView.image = UIImage(named: defaultBlackAvatarImageName)
                    }
                }else {
                    view.avatarView.image = UIImage(named: defaultBlackAvatarImageName)
                }
                
                view.actionIcon.tag = indexPath.row
                if let _ = user.statusDesc {
                    view.statusLabel.text = user.statusDesc
                }else {
                    view.statusLabel.text = "\(user.clothesCount) items"
                }
                switch user.status {
//                case .newMission:
//                    view.actionIcon.hidden = false
//                    if user.missionOutfitId > 0 {
//                        view.actionIcon.setImage(UIImage(named: "StatusTaskDoneIcon"), forState: .Normal)
//                        view.actionIcon.addTarget(self, action: Selector("goToFriendWardrobe:"), forControlEvents: .TouchUpInside)
//                    }else {
//                        view.actionIcon.setImage(UIImage(named: "StatusTaskInvitationIcon"), forState: .Normal)
//                        view.actionIcon.addTarget(self, action: Selector("goToFriendWardrobe:"), forControlEvents: .TouchUpInside)
//                    }
                case .friendRequest:
                    view.actionIcon.hidden = false
                    view.actionIcon.setImage(UIImage(named: "StatusFriendRequestIcon"), forState: .Normal)
                    view.actionIcon.addTarget(self, action: #selector(FriendListViewController.showFriendRequestDialog(_:)), forControlEvents: .TouchUpInside)
                default:
                    view.actionIcon.hidden = true
                    view.actionIcon.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
                }
                
                view.nameLabel.text = user.name
                
                if user.isCelebrity {
                    view.nameLabel.textColor = DJCommonStyle.ColorRed
                    view.backgroundColor = UIColor(fromHexString: "f3f3f3")
                    cell.backgroundColor = UIColor(fromHexString: "f3f3f3")
                }else {
                    view.nameLabel.textColor = DJCommonStyle.BackgroundColor
                    view.backgroundColor = UIColor.whiteColor()
                    cell.backgroundColor = UIColor.whiteColor()
                }
                
                view.userInteractionEnabled = true
        })
        cell.selectionStyle = .None
        return cell
    }
    
    func goToFriendWardrobe(button : UIButton) {
        let user = users[button.tag]
        let v = FriendWardrobeViewController(beginCategoryId : "0")
        v.user = user
        navigationController?.pushViewController(v, animated: true)
    }
    
    func showFriendRequestDialog(button : UIButton) {
        let user = users[button.tag]
        showFriendRequestDialogOfUser(user)
    }
    
    func showFriendRequestDialogOfUser(user : DejaFriend) {
        let contentView = UIView().withBackgroundColor(UIColor(fromHexString: "262729", alpha: 0.95))
        contentView.frame = CGRectMake(0.0, 0.0, 256.0, 249.0);
        
        let avatarImageView = UIImageView()
        if let image = user.avatar {
            if let url = NSURL(string: image) {
                avatarImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "CircleDeja"))
            }
        }else {
            avatarImageView.image = UIImage(named: "CircleDeja")
        }
        avatarImageView.layer.cornerRadius = 29
        
        let titleLabel = UILabel().withTextColor(DJCommonStyle.ColorEA).withFontHeletica(14)
        titleLabel.numberOfLines = 0
        titleLabel.text = user.name + DJStringUtil.localize("wants to be your friend!", comment: "")
        
        let descLabel = UILabel().withTextColor(UIColor.gray81Color()).withFontHeletica(14)
        descLabel.numberOfLines = 1
        if user.fromFacebook {
            descLabel.text = DJStringUtil.localize("from Facebook", comment: "")
        }
        
        let rejectButton = DJButton().whiteTitleTransparentStyle()
        rejectButton.withTitle(DJStringUtil.localize("Decline", comment: ""))
        rejectButton.layer.cornerRadius = 17.5
        rejectButton.property = user
        rejectButton.addTarget(self, action: #selector(FriendListViewController.rejectFriendRequest(_:)), forControlEvents: .TouchUpInside)

        let acceptButton = DJButton().whiteTitleTransparentStyle()
        acceptButton.withTitle(DJStringUtil.localize("Accept", comment: ""))
        acceptButton.layer.cornerRadius = 17.5
        acceptButton.property = user
        acceptButton.addTarget(self, action: #selector(FriendListViewController.acceptFriendRequest(_:)), forControlEvents: .TouchUpInside)
        
        contentView.addSubviews(avatarImageView, titleLabel, descLabel, rejectButton, acceptButton)
        
        constrain(avatarImageView, titleLabel, descLabel, rejectButton, acceptButton) { (avatarImageView, titleLabel, descLabel, rejectButton, acceptButton) in
            avatarImageView.top == avatarImageView.superview!.top + 30
            avatarImageView.centerX == avatarImageView.superview!.centerX
            avatarImageView.width == 58
            avatarImageView.height == 58
            
            titleLabel.top == avatarImageView.bottom + 21
            titleLabel.width == 199
            titleLabel.centerX == titleLabel.superview!.centerX
            
            descLabel.top == titleLabel.bottom + 3
            descLabel.width == 199
            descLabel.centerX == descLabel.superview!.centerX
            
            acceptButton.bottom == acceptButton.superview!.bottom - 30
            acceptButton.width == 95
            acceptButton.height == 35
            acceptButton.right == titleLabel.right
            
            rejectButton.bottom == rejectButton.superview!.bottom - 30
            rejectButton.width == 95
            rejectButton.height == 35
            rejectButton.left == titleLabel.left
        }
        
        popup?.removeFromSuperview()//fix pop up twice
        popup = KLCPopup(contentView: contentView)
        navigationController?.view.addSubview(popup!)
        popup?.shouldDismissOnBackgroundTouch = true
        popup?.maskType = .Clear
        popup!.show()
        
    }
    
    func acceptFriendRequest(button : UIButton) {
        popup?.dismiss(false)
        if let user = button.property as? DejaFriend {
            let task = AddFriendConfrimNetTask()
            task.friendUid = user.uid
            MONetTaskQueue.instance().addTask(task)
            MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
            MBProgressHUD.showHUDAddedTo(view, animated: true)
        }
    }
    
    func rejectFriendRequest(button : UIButton) {
        popup?.dismiss(false)
        if let user = button.property as? DejaFriend {
            let task = RejectFriendRequestNetTask()
            task.buddyUid = user.uid
            MONetTaskQueue.instance().addTask(task)
            MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
            MBProgressHUD.showHUDAddedTo(view, animated: true)
        }
    }
    
    class FriendView : UIView {
        let avatarView = UIImageView()
        let nameLabel = UILabel()
        let statusLabel = UILabel()
        let actionIcon = UIButton()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height)
        {
            if !listEnded && !loading {
                fetchFriendList(currentPage + 1)
            }
        }
    }
}

extension FriendListViewController {
    override func notificationNames() -> [AnyObject]! {
        return [kNotificationMissionOutfitCreated]
    }
    
    override func didReceiveNotification(notification: NSNotification!) {
        if notification.name == kNotificationMissionOutfitCreated {
            if let missionId = notification.userInfo?["mission_id"] as? String {
                if let missionOutfitId = notification.userInfo?["mission_outfit_id"] as? String {
                    for user in users {
                        if user.missionId.description == missionId {
                            if let oId = Int(missionOutfitId) {
                                user.missionOutfitId = oId
                            }
                        }
                    }
                }
            }
        }
    }
}

extension FriendListViewController {
    
    func showEmptyView() {
        if emptyView == nil {
            emptyView = UIView(frame: view.bounds)
            let icon = UIImageView(image: UIImage(named: "NoFriendIcon"))
            let label = UILabel().withFontHeletica(15).withTextColor(DJCommonStyle.BackgroundColor)
            let text = DJStringUtil.localize("You have no friends yet. Add friends to see each other’s wardrobes and create outfits together.", comment: "")
            label.numberOfLines = 0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            let attrString = NSMutableAttributedString(string: text)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            label.attributedText = attrString
            
            let button = DJButton().whiteTitleBlackStyle()
            button.withTitle(DJStringUtil.localize("Add Friend", comment: ""))
            emptyView?.addSubviews(icon,label,button)
            button.addTarget(self, action: #selector(FriendListViewController.addFriend), forControlEvents: .TouchUpInside)
            constrain(icon,label,button, block: { (icon,label,button) in
                icon.top == icon.superview!.top + 130
                icon.centerX == icon.superview!.centerX
                label.top == icon.bottom + 23
                label.left == label.superview!.left + 60
                label.right == label.superview!.right - 60
                button.top == label.bottom + 19
                button.centerX == button.superview!.centerX
                button.width == 132
                button.height == 35
            })
            view.addSubview(emptyView!)
        }
        emptyView?.hidden = false
        tableView.hidden = true
//        rightIcon.hidden = true
    }
    
    func hideEmptyView() {
        emptyView?.hidden = true
        tableView.hidden = false
//        rightIcon.hidden = false
    }
    
}


