//
//  MeViewController.swift
//  DejaFashion
//
//  Created by Sun lin on 8/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation
import RAReorderableLayout

class MeViewController: DJBasicViewController, UIActionSheetDelegate, DJTakePhotoViewControllerDelegate, UITextFieldDelegate {
    private let topBannerView = UIView()
    private var actionCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    private var cells = [MOCollectionCellBuilder]()
    private var avatarView = UIImageView()
    private var nameLabel = UILabel()
    private let nameTextField = UITextField()
    private let photoFullImageView = UIImageView()
    
    override init() {
        super.init()
        hidesBottomBarWhenPushed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(fromHexString: "f6f6f6")
        
        self.topBannerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 257)
        self.view.addSubview(topBannerView)
        buildTopBanner(topBannerView)
        
        self.resetProfile()
         
        let defaultLayout = CHTCollectionViewWaterfallLayout()
        defaultLayout.columnCount = 3
        defaultLayout.sectionInset = UIEdgeInsetsMake(20, 23, 20, 23)
        let raLayout = RAReorderableLayout()
        raLayout.sectionInset = UIEdgeInsetsMake(20, 23, 20, 23)
        
        actionCollectionView = UICollectionView(frame: CGRectMake(0, 260, ScreenWidth, ScreenHeight - self.topBannerView.bounds.size.height - 20), collectionViewLayout: 9.0.operatingSystemIsSameOrHigher ? defaultLayout : raLayout)
        actionCollectionView.backgroundColor = UIColor.whiteColor()
        
        actionCollectionView.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Cell")
        actionCollectionView.showsVerticalScrollIndicator = false
        actionCollectionView.dataSource = self
        actionCollectionView.alwaysBounceVertical = true
        actionCollectionView.delegate = self
        actionCollectionView.backgroundColor = UIColor.whiteColor()
        actionCollectionView.layer.cornerRadius = 5
        self.view.addSubview(actionCollectionView)
        
        cells.append(self.buildWardrobeCell())
        cells.append(self.buildFavoritesCell())
        cells.append(self.buildHistoryCell())
        cells.append(self.buildFriendsCell())
        cells.append(self.buildFittingRoomCell())
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: LoginNetTask.uri())
        MONetTaskQueue.instance().addTaskDelegate(self, uri: LogoutNetTask.uri())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.actionCollectionView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        
    }
    
    func buildTopBanner(containterView : UIView){
        let imageView = UIImageView(frame : containterView.bounds)
        imageView.image = UIImage(named: "MeBg")
        containterView.addSubview(imageView)
        
        
        let rightIcon = UIButton(frame: CGRectMake(containterView.bounds.size.width - 50, 30, 27, 22))
        rightIcon.setImage(UIImage(named: "SettingIcon"), forState: .Normal)
        rightIcon.addTarget(self, action: #selector(MeViewController.gotoSettings),forControlEvents: .TouchUpInside)
        containterView.addSubview(rightIcon)
        
        
        
        avatarView = UIImageView(frame : CGRectMake((containterView.frame.size.width - 84) / 2, 90, 84, 84))
        avatarView.layer.cornerRadius = avatarView.bounds.size.width / 2
        avatarView.clipsToBounds = true
        avatarView.contentMode = .ScaleAspectFill
        avatarView.image = UIImage(named: "DefaultAvatar")
        avatarView.addTapGestureTarget(self, action: #selector(didTapAvatar))
        containterView.addSubview(avatarView)
        
        
        
        nameLabel = UILabel().textCentered().withText(DJStringUtil.localize("Login", comment: "")).withTextColor(UIColor.whiteColor()).withFontHeletica(14)
        nameLabel.frame = CGRectMake(0, CGRectGetMaxY(avatarView.frame) + 17, containterView.frame.size.width, 16)
        nameLabel.addTapGestureTarget(self, action: #selector(MeViewController.didTapUserName))
        containterView.addSubview(nameLabel)
    }
    
    
    
    func didTapAvatar(){
        if AccountDataContainer.sharedInstance.isAnonymous() {
            self.gotoLoginViewController()
            return
        }
        let popup = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: DJStringUtil.localize("Cancel", comment:""), destructiveButtonTitle: nil, otherButtonTitles: DJStringUtil.localize("View", comment:""), DJStringUtil.localize("Change Photo", comment:""))
        popup.tag = 1
        popup.showInView(self.view)
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Avatar)
        
    }
    
    func didTapUserName(){
        
        if AccountDataContainer.sharedInstance.isAnonymous() {
            self.gotoLoginViewController()
            return
        }
        
        let orRect = (navigationController?.view.convertRect(nameLabel.frame, fromView:view))!
        nameTextField.frame = CGRectMake(orRect.origin.x + (orRect.size.width - 135) / 2, orRect.origin.y, 135, orRect.size.height)
        nameTextField.contentMode = .Center
        nameTextField.backgroundColor = UIColor.whiteColor()
        nameTextField.textColor = UIColor.defaultBlack()
        nameTextField.textAlignment = .Center
        nameTextField.text = nameLabel.text
        nameTextField.font = nameLabel.font
        nameTextField.returnKeyType = .Done
        nameTextField.delegate = self
        nameTextField.clearButtonMode = .WhileEditing
        
        let maskView = UIView(frame: (navigationController?.view.bounds)!)
        navigationController?.view.addSubview(maskView)
        maskView.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.95)
        maskView.addSubview(nameTextField)
        maskView.alpha = 0
        maskView.addTapGestureTarget(self, action: #selector(MeViewController.didTappedNameLabelMask))
        
        let infoLabel = UILabel(frame: CGRectMake(0,0, maskView.frame.size.width, 10))
        infoLabel.withText(DJStringUtil.localize("Set Your Nickname", comment:"")).withTextColor(UIColor(fromHexString: "eaeaea")).withFontHeleticaMedium(16)
        infoLabel.textAlignment = .Center
        infoLabel.sizeToFit()
        infoLabel.frame = CGRectMake(0, 120, maskView.frame.size.width, infoLabel.frame.size.height)
        maskView.addSubview(infoLabel)
        
        UIView.animateWithDuration(0.3, animations: {
            maskView.alpha = 1
            },  completion: { (completion : Bool) -> Void in
                self.nameTextField.becomeFirstResponder()
        })
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Nickname)
        
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == 1 {
            if buttonIndex == 1 {
                gotoViewFullPhoto()
            }else if buttonIndex == 2{
                gotoEditPhoto()
            }
        } else if actionSheet.tag == 2 {
            if buttonIndex == 1 {
//                sendUnBindFacebookNetTask()
            }
        }
    }
    
    func sendChangeProfileNetTask(imageUrl : String?, nickName : String?){
        let cNT = ChangeProfileNetTask()
        cNT.imageURL = imageUrl
        cNT.newName = nickName
        MONetTaskQueue.instance().addTaskDelegate(self, uri: cNT.uri())
        MONetTaskQueue.instance().addTask(cNT)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        didTappedNameLabelMask()
        let newStr = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if newStr != nameLabel.text && newStr?.characters.count > 0 {
            sendChangeProfileNetTask(nil, nickName: newStr)
            nameLabel.text = newStr
        }
        return true
    }
    
    func didTappedNameLabelMask(){
        nameTextField.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: {
            self.nameTextField.superview?.alpha = 0
            self.nameTextField.alpha = 0
            },  completion: { (completion : Bool) -> Void in
                self.nameTextField.superview?.removeFromSuperview()
                self.nameTextField.removeFromSuperview()
                self.nameTextField.alpha = 1
        })
    }

    
    
    func gotoViewFullPhoto(){
        photoFullImageView.frame = (navigationController?.view.convertRect(avatarView.frame, fromView:view))!
        photoFullImageView.backgroundColor = UIColor.defaultBlack()
        photoFullImageView.image = avatarView.image
        navigationController?.view.addSubview(photoFullImageView)
        photoFullImageView.contentMode = .ScaleAspectFit
        photoFullImageView.addTapGestureTarget(self, action: #selector(AccountHomeViewController.fullImageViewDidTapped))
        UIView.animateWithDuration(0.3, animations: {
            self.photoFullImageView.frame = (self.navigationController?.view.bounds)!
        })
    }
    
    func fullImageViewDidTapped(){
        let orRect = (navigationController?.view.convertRect(avatarView.frame, fromView:view))!
        UIView.animateWithDuration(0.3, animations: {
            self.photoFullImageView.frame = orRect
            }, completion: { (completion : Bool) -> Void in
                self.photoFullImageView.removeFromSuperview()
        })
    }
    
    func gotoLoginViewController()
    {
        self.navigationController?.pushViewController(LoginViewController(), animated: true)
    }
    
    func gotoSettings() {
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Setting)
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    func gotoWardrobe()
    {
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Wardrobe)
        let v = WardrobeViewController()
        navigationController?.pushViewController(v, animated: true)
    }
    
    func gotoEditPhoto(){
        let takePhotoVC = DJTakePhotoViewController()
        takePhotoVC.delegate = self
        takePhotoVC.title = DJStringUtil.localize("Photo", comment:"")
        navigationController?.presentViewController(UINavigationController(rootViewController: takePhotoVC), animated: true, completion: nil)
    }
    
    func takePhotoViewController(takePhototVC: DJTakePhotoViewController!, didUseImage image: UIImage!) {
        avatarView.image = image
        
        let uploadNT = DJUploadFileNetTask()
        uploadNT.property = self //to avoid instance release while still has not finish feedbacknettask
        uploadNT.data = UIImageJPEGRepresentation(image, 0.5)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: uploadNT.uri())
        MONetTaskQueue.instance().addTask(uploadNT)
    }

    
    func gotoFriendList() {
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Friends)
//        friendLabel.hideRedDot()
        navigationController?.pushViewController(FriendListViewController(), animated: true)
    }
    
    func gotoHistory() {
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_History)
        let v = BrowerClothHistoryViewController()
        navigationController?.pushViewController(v, animated: true)
    }
    
    func gotoFavourites() {
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Favorites)
        let v = StyleBookViewController(URLString: ConfigDataContainer.sharedInstance.getStyleBookUrl())
        navigationController?.pushViewController(v, animated: true)
    }
    
    
    func gotoFittingRoom() {
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_FittingRoom)
        let fr = FittingRoomViewController()
        fr.setEnterCondition(nil, filters: nil)
        navigationController?.pushViewController(fr, animated: true)
    }
}

extension MeViewController : MONetTaskDelegate
{
    
    
    func netTaskDidEnd(task: MONetTask!) {
        if task.isKindOfClass(DJUploadFileNetTask) {
            let upTask = task as! DJUploadFileNetTask
            upTask.property = nil
            sendChangeProfileNetTask(upTask.fileUrl, nickName: nil)
        }
        
        if let netTask = task as? UnBindAccountNetTask {
            if netTask.accountType == .Facebook {
                MBProgressHUD.hideHUDForView(view, animated: true)
//                fbLabel.text = "Connect Facebook"
//                arrowIcon.hidden = false
//                connectStateLabel.hidden = true
            }
        }
        
        if task.uri() == LoginNetTask.uri()
        {
            self.resetProfile()
        }
        
        if task.uri() == LogoutNetTask.uri()
        {
            self.resetProfile()
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task.isKindOfClass(DJUploadFileNetTask) {
            MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Network is down", comment:""), animated: true)
            resetProfile()
        }else if task.isKindOfClass(ChangeProfileNetTask) {
            MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Network is down", comment:""), animated: true)
            resetProfile()
        }
        
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
    }
    
    
    func resetProfile(){
        
        if AccountDataContainer.sharedInstance.isAnonymous()
        {
            avatarView.image = UIImage(named: "DefaultAvatar")
            nameLabel.withText(DJStringUtil.localize("Login", comment:""))
            return
        }
        
        if let av = AccountDataContainer.sharedInstance.avatar{
            avatarView.sd_setImageWithURL(NSURL(string:  av), placeholderImage: UIImage(named: "DefaultAvatar")!)
        }else{
            avatarView.image = UIImage(named: "DefaultAvatar")
        }
        
        var nameStr = "Your Name"
        if let str = AccountDataContainer.sharedInstance.userName {
            if str.characters.count > 0 {
                nameStr = str
            }
        }
        nameLabel.withText(nameStr)
    }
    
}


extension MeViewController
{
    
    func buildCommonCell(cell: UICollectionViewCell, indexPath: NSIndexPath, imageName: String, title: String) -> UIView
    {
        
        let contentView = UIView()
        contentView.frame = cell.bounds
        
        let icon = UIImageView()
        icon.frame = CGRectMake((cell.bounds.size.width - 41) / 2, 32, 41, 33)
        icon.image = UIImage(named: imageName)
        
        let name = UILabel().withText(title).withTextColor(UIColor.blackColor()).withFontHeletica(14).textCentered()
        name.frame = CGRectMake(0, 68, contentView.bounds.size.width, 30)
        
        if indexPath.row % 3 < 2
        {
            let verticalLine = UIView(frame:CGRectMake(contentView.bounds.size.width - 0.5, 0, 0.5, contentView.bounds.size.height))
            verticalLine.backgroundColor = UIColor.lightGrayColor()
            verticalLine.alpha = 0.5;
            contentView.addSubview(verticalLine)
        }
        
        let horizentalLine = UIView(frame:CGRectMake(0, contentView.bounds.size.height - 0, contentView.bounds.size.width, 0.5))
        horizentalLine.backgroundColor = UIColor.lightGrayColor()
        horizentalLine.alpha = 0.5;
        contentView.addSubview(horizentalLine)
        
        contentView.addSubview(icon)
        contentView.addSubview(name)
        
        return contentView
    }
    
    
    func buildFriendsCell() -> MOCollectionCellBuilder
    {
        let cellBuidler = MOCollectionCellBuilder()
        let action : (UICollectionView!, NSIndexPath!) -> Bool = { collectionView, indexPath in
            
            if AccountDataContainer.sharedInstance.isAnonymous()
            {
                self.gotoLoginViewController()
                return false
            }
            else
            {
                self.gotoFriendList()
            }
            
            return false
        }
        let view : (UICollectionViewCell!, NSIndexPath!) -> UIView! = { cell, indexPath in
            return self.buildCommonCell(cell, indexPath: indexPath, imageName: "MeIconFriends", title: "Friends")
        }
        cellBuidler.action = action
        cellBuidler.builder = view
        return cellBuidler
    }
    
    
    func buildWardrobeCell() -> MOCollectionCellBuilder
    {
        let cellBuidler = MOCollectionCellBuilder()
        let action : (UICollectionView!, NSIndexPath!) -> Bool = { collectionView, indexPath in
            self.gotoWardrobe()
            return false
        }
        let view : (UICollectionViewCell!, NSIndexPath!) -> UIView! = { cell, indexPath in
            let view = self.buildCommonCell(cell, indexPath: indexPath, imageName: "MeIconWardrobe", title: DJStringUtil.localize("Wardrobe", comment:""))
            let nc = WardrobeDataContainer.sharedInstance.newAddedClothNumber()
            if nc > 0
            {
                let newCount = UILabel().withText(String(nc)).withTextColor(UIColor.whiteColor()).withFontHeleticaMedium(12).textCentered().withBackgroundColor(DJCommonStyle.ColorRed)
                newCount.layer.cornerRadius = 7
                newCount.clipsToBounds = true
                newCount.frame = CGRectMake(view.bounds.size.width - 54, 25, 14, 14)
                view.addSubview(newCount)
            }
            return view
        }
        cellBuidler.action = action
        cellBuidler.builder = view
        return cellBuidler
    }
    
    
    func buildHistoryCell() -> MOCollectionCellBuilder
    {
        let cellBuidler = MOCollectionCellBuilder()
        let action : (UICollectionView!, NSIndexPath!) -> Bool = { collectionView, indexPath in
            self.gotoHistory()
            return false
        }
        let view : (UICollectionViewCell!, NSIndexPath!) -> UIView! = { cell, indexPath in
            let view = self.buildCommonCell(cell, indexPath: indexPath, imageName: "MeIconHistory", title: DJStringUtil.localize("History", comment:""))
            return view
        }
        cellBuidler.action = action
        cellBuidler.builder = view
        return cellBuidler
    }
    
    
    func buildFavoritesCell() -> MOCollectionCellBuilder
    {
        
        let cellBuidler = MOCollectionCellBuilder()
        let action : (UICollectionView!, NSIndexPath!) -> Bool = { collectionView, indexPath in
            DJConfigDataContainer.instance().newFavouriteCount = 0
            self.gotoFavourites()
            return false
        }
        let view : (UICollectionViewCell!, NSIndexPath!) -> UIView! = { cell, indexPath in
            let view = self.buildCommonCell(cell, indexPath: indexPath, imageName: "MeIconFavorites", title: DJStringUtil.localize("Favourites", comment:""))
            
            if DJConfigDataContainer.instance().newFavouriteCount > 0
            {
                let newCount = UILabel().withText(String(DJConfigDataContainer.instance().newFavouriteCount)).withTextColor(UIColor.whiteColor()).withFontHeleticaMedium(12).textCentered().withBackgroundColor(DJCommonStyle.ColorRed)
                newCount.layer.cornerRadius = 7
                newCount.clipsToBounds = true
                newCount.frame = CGRectMake(view.bounds.size.width - 50, 25, 14, 14)
                view.addSubview(newCount)
            }
            return view
        }
        cellBuidler.action = action
        cellBuidler.builder = view
        return cellBuidler
    }
    
    
    func buildFittingRoomCell() -> MOCollectionCellBuilder
    {
        
        let cellBuidler = MOCollectionCellBuilder()
        let action : (UICollectionView!, NSIndexPath!) -> Bool = { collectionView, indexPath in
            self.gotoFittingRoom()
            return false
        }
        let view : (UICollectionViewCell!, NSIndexPath!) -> UIView! = { cell, indexPath in
            return self.buildCommonCell(cell, indexPath: indexPath, imageName: "MeIconFittingRoom", title:  DJStringUtil.localize("Fitting Room", comment:""))
        }
        cellBuidler.action = action
        cellBuidler.builder = view
        return cellBuidler
    }
    
}


extension MeViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.contentView.removeAllSubViews()
        cell.contentView.addSubview(cells[indexPath.row].builder(cell, indexPath))
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return products.count
        return cells.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if cells[indexPath.row].action != nil
        {
            cells[indexPath.row].action(collectionView, indexPath)
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(ScreenWidth / 3, 115)
    }
}
