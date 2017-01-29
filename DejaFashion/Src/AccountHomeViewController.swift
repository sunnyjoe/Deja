//
//  AccountHomeViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 1/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class AccountHomeViewController: DJBasicViewController, MONetTaskDelegate, ThirdPartyLoginDelegate {
    let profileView = UIView()
    
    let photoImageView = UIImageView()
    let photoFullImageView = UIImageView()
    let nameLabel = UILabel()
    let nameTextField = UITextField()
    
    let fbView = UIView()
    let fbLabel = UILabel()
    let connectStateLabel = UILabel()
    let arrowIcon = UIButton()
    
    let friendLabel = UIButton().withFontHeletica(16).withTitleColor(UIColor.defaultBlack()).withTitle(DJStringUtil.localize("Friends", comment:""))
    let taskLabel = UIButton().withFontHeletica(16).withTitleColor(UIColor.defaultBlack()).withTitle(DJStringUtil.localize("My Tasks", comment:""))
    let favouriteLabel = UIButton().withFontHeletica(16).withTitleColor(UIColor.defaultBlack()).withTitle(DJStringUtil.localize("Favourites", comment:""))
    
    var showReddotOnFriendLabel = false
    
    func resetAvatarProfile(){
        if let av = AccountDataContainer.sharedInstance.avatar{
            photoImageView.sd_setImageWithURL(NSURL(string:  av), placeholderImage: UIImage(named: "MeDefaultAvatar")!)
        }else{
            photoImageView.image = UIImage(named: "MeDefaultAvatar")
        }
 
        var nameStr = DJStringUtil.localize("Your Name", comment:"")
        if let str = AccountDataContainer.sharedInstance.userName {
            if str.characters.count > 0 {
                nameStr = str
            }
        }
        nameLabel.withText(nameStr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(profileView)
        profileView.backgroundColor = UIColor.defaultBlack()
        profileView.addSubview(photoImageView)
        profileView.addSubview(nameLabel)
        
        let rightIcon = UIButton(frame: CGRectMake(0, 0, 30, 44))
        rightIcon.setImage(UIImage(named: "SettingIcon"), forState: .Normal)
        rightIcon.addTarget(self, action: #selector(AccountHomeViewController.gotoSettings),forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightIcon)
        
        DJLoginLogic.instance()
        
        photoImageView.addTapGestureTarget(self, action: #selector(AccountHomeViewController.photoDidTapped))
        photoImageView.layer.cornerRadius = 36
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .ScaleAspectFill
        photoImageView.backgroundColor = UIColor.defaultBlack()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        constrain(photoImageView) { photoImageView in
            photoImageView.top == photoImageView.superview!.top + 5
        }
        NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 72).active = true
        NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
            attribute: .NotAnAttribute,  multiplier: 1,  constant: 72).active = true
        
        resetAvatarProfile()
        nameLabel.withTextColor(UIColor(fromHexString: "ffffff")).withFontHeletica(16)
        nameLabel.textAlignment = .Center
        nameLabel.addTapGestureTarget(self, action: #selector(AccountHomeViewController.nameLabelDidTapped))
        constrain(nameLabel, photoImageView) { nameLabel, photoImageView in
            nameLabel.top == photoImageView.bottom + 20
            nameLabel.left == nameLabel.superview!.left
            nameLabel.right == nameLabel.superview!.right
        }
        
        if AccountDataContainer.sharedInstance.currentAccountType != .Facebook {
            view.addSubview(fbView)
            let lineView = UIView()
            fbView.addSubview(lineView)
            lineView.backgroundColor = DJCommonStyle.DividerColor
            lineView.translatesAutoresizingMaskIntoConstraints = false
            constrain(lineView) { lineView in
                lineView.left == lineView.superview!.left
                lineView.right == lineView.superview!.right
                lineView.bottom == lineView.superview!.bottom
            }
            NSLayoutConstraint(item: lineView,attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0.5).active = true
            
            fbView.addTapGestureTarget(self, action: #selector(AccountHomeViewController.connectFBDidTapped))
            fbView.addSubviews(fbLabel, connectStateLabel)
            fbLabel.textAlignment = .Left
            fbLabel.withFontHeletica(16).withTextColor(UIColor.defaultBlack()).withText(DJStringUtil.localize("Connect Facebook", comment:""))
            connectStateLabel.textAlignment = .Right
            connectStateLabel.withFontHeletica(16).withTextColor(UIColor.defaultBlack()).withText(DJStringUtil.localize("Connected", comment:""))

            constrain(fbLabel) { fbLabel in
                fbLabel.left == fbLabel.superview!.left + 65
                fbLabel.bottom == fbLabel.superview!.bottom
                fbLabel.top == fbLabel.superview!.top
            }
            
            constrain(connectStateLabel) { fbLabel in
                fbLabel.right == fbLabel.superview!.right - 23
                fbLabel.bottom == fbLabel.superview!.bottom
                fbLabel.top == fbLabel.superview!.top
            }
            
            let fbIcon = UIButton()
            fbView.addSubview(fbIcon)
            fbIcon.userInteractionEnabled = false
            fbIcon.setImage(UIImage(named: "FBIcon"), forState: .Normal)
            constrain(fbIcon) { fbIcon in
                fbIcon.left == fbIcon.superview!.left + 23
            }
            NSLayoutConstraint(item: fbIcon, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: fbIcon.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0).active = true
            NSLayoutConstraint(item: fbIcon, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                attribute: .NotAnAttribute, multiplier: 1, constant: 30).active = true
            NSLayoutConstraint(item: fbIcon, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
                attribute: .NotAnAttribute,  multiplier: 1,  constant: 30).active = true
            
            arrowIcon.userInteractionEnabled = false
            fbView.addSubview(arrowIcon)
            arrowIcon.setImage(UIImage(named: "ProfileArrow"), forState: .Normal)
            constrain(arrowIcon) { arrowIcon in
                arrowIcon.right == arrowIcon.superview!.right - 20
            }
            NSLayoutConstraint(item: arrowIcon, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: arrowIcon.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 1).active = true
            NSLayoutConstraint(item: arrowIcon, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                attribute: .NotAnAttribute, multiplier: 1, constant: 12).active = true
            NSLayoutConstraint(item: arrowIcon, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
                attribute: .NotAnAttribute,  multiplier: 1,  constant: 8).active = true
            
            if let info = AccountDataContainer.sharedInstance.bindedFacebookInfo {
                fbLabel.text = info.identifier
                arrowIcon.hidden = true
                connectStateLabel.hidden = false
            }else {
                fbLabel.text = DJStringUtil.localize("Connect Facebook", comment:"")
                arrowIcon.hidden = false
                connectStateLabel.hidden = true
            }
        }else {
            fbView.hidden = true
        }
        
        
        addFriendLabel()
//        addMyTaskLabel()
        addFavouriteLabel()
        
        addContactUsLabel()
    }
    
    func addFriendLabel() {
        let divider = UIView(frame: CGRect(x: 0, y: 60.5, width: view.frame.width, height: 0.5)).withBackgroundColor(DJCommonStyle.DividerColor)
        let arrowImageView = UIImageView(image: UIImage(named: "ProfileArrow"))
        arrowImageView.frame = CGRectMake(view.frame.width - 23 - 8, 30.5 - 6, 8, 12)
        friendLabel.addSubviews(divider, arrowImageView)
        friendLabel.contentHorizontalAlignment = .Left
        friendLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        friendLabel.addTarget(self, action: #selector(AccountHomeViewController.gotoFriendList), forControlEvents: .TouchUpInside)
        view.addSubviews(friendLabel)
        if showReddotOnFriendLabel {
            friendLabel.showRedDot(CGRectMake(70, 21, 8, 8))
        }
    }
    
    func addMyTaskLabel() {
        let divider = UIView(frame: CGRect(x: 0, y: 60.5, width: view.frame.width, height: 0.5)).withBackgroundColor(DJCommonStyle.DividerColor)
        let arrowImageView = UIImageView(image: UIImage(named: "ProfileArrow"))
        arrowImageView.frame = CGRectMake(view.frame.width - 23 - 8, 30.5 - 6, 8, 12)
        taskLabel.addSubviews(divider, arrowImageView)
        taskLabel.contentHorizontalAlignment = .Left
        taskLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        taskLabel.addTarget(self, action: #selector(AccountHomeViewController.gotoStylingMissions), forControlEvents: .TouchUpInside)
        
        view.addSubviews(taskLabel)
    }
    
    func addFavouriteLabel() {
        let divider = UIView(frame: CGRect(x: 0, y: 60.5, width: view.frame.width, height: 0.5)).withBackgroundColor(DJCommonStyle.DividerColor)
        let arrowImageView = UIImageView(image: UIImage(named: "ProfileArrow"))
        arrowImageView.frame = CGRectMake(view.frame.width - 23 - 8, 30.5 - 6, 8, 12)
        favouriteLabel.addSubviews(divider, arrowImageView)
        favouriteLabel.contentHorizontalAlignment = .Left
        favouriteLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        favouriteLabel.addTarget(self, action: #selector(AccountHomeViewController.gotoFavourites), forControlEvents: .TouchUpInside)
        view.addSubviews(favouriteLabel)
    }
    
    func addContactUsLabel() {
        /**
         NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
         myLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Test string"
         attributes:underlineAttribute];
         **/
        
        let label = UILabel().withText(DJStringUtil.localize("Contact Us", comment:"")).withTextColor(DJCommonStyle.BackgroundColor).withFontHeletica(16).textCentered()
        label.frame = CGRectMake(0, view.frame.height - 125, view.frame.width, 50)
        view.addSubview(label)
        label.addTapGestureTarget(self, action: #selector(AccountHomeViewController.contactUs))
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        profileView.frame = CGRectMake(0, 0, view.frame.size.width, 151)
        if fbView.hidden {
            friendLabel.frame = CGRectMake(0, CGRectGetMaxY(profileView.frame), view.frame.size.width, 61)
        }else {
            fbView.frame = CGRectMake(0, CGRectGetMaxY(profileView.frame), view.frame.size.width, 61)
            friendLabel.frame = CGRectMake(0, CGRectGetMaxY(fbView.frame), view.frame.size.width, 61)
        }
//        taskLabel.frame = CGRectMake(0, CGRectGetMaxY(friendLabel.frame), view.frame.size.width, 61)
        favouriteLabel.frame = CGRectMake(0, CGRectGetMaxY(friendLabel.frame), view.frame.size.width, 61)
    }
    
    func connectFBDidTapped(){
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
    }
    
    func thirdPartyBindDidError() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func thirdPartyBindDidSuccess() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        fbLabel.text = AccountDataContainer.sharedInstance.bindedFacebookInfo?.identifier
        arrowIcon.hidden = true
        connectStateLabel.hidden = false
    }
    
    func thirdPartyBindDidCanceled() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func photoDidTapped(){
        let popup = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: DJStringUtil.localize("Cancel", comment:""), destructiveButtonTitle: nil, otherButtonTitles: DJStringUtil.localize("View", comment:""), DJStringUtil.localize("Change Photo", comment:""))
        popup.tag = 1
        popup.showInView(self.view)
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Avatar)
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task.isKindOfClass(DJUploadFileNetTask) {
            let upTask = task as! DJUploadFileNetTask
            upTask.property = nil
            sendChangeProfileNetTask(upTask.fileUrl, nickName: nil)
        }
        
        if let netTask = task as? UnBindAccountNetTask {
            if netTask.accountType == .Facebook {
                MBProgressHUD.hideHUDForView(view, animated: true)
                fbLabel.text = DJStringUtil.localize("Connect Facebook", comment:"")
                arrowIcon.hidden = false
                connectStateLabel.hidden = true
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task.isKindOfClass(DJUploadFileNetTask) {
            MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Network is down", comment:""), animated: true)
            resetAvatarProfile()
        }else if task.isKindOfClass(ChangeProfileNetTask) {
            MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Network is down", comment:""), animated: true)
            resetAvatarProfile()
        }
        
        if let netTask = task as? BindAccountNetTask {
            if netTask.error.code == 7{
                let message = DJStringUtil.localize("This Facebook account has already binding to another phone number.", comment:"")
                let alertView = DJAlertView(title: DJStringUtil.localize("Oops", comment:""), message: message, cancelButtonTitle: DJStringUtil.localize("OK", comment:""))
                alertView.show()
            }else if netTask.error.code == 6{
                let message = DJStringUtil.localize("This Facebook account has already login independent.", comment:"")
                let alertView = DJAlertView(title: DJStringUtil.localize("Oops", comment:""), message: message, cancelButtonTitle: DJStringUtil.localize("OK", comment:""))
                alertView.show()
            }else {
                
            }
        }
    }
}

extension AccountHomeViewController : UIActionSheetDelegate, DJTakePhotoViewControllerDelegate, UITextFieldDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == 1 {
            if buttonIndex == 1 {
                gotoViewFullPhoto()
            }else if buttonIndex == 2{
                gotoEditPhoto()
            }
        } else if actionSheet.tag == 2 {
            if buttonIndex == 1 {
                sendUnBindFacebookNetTask()
            }
        }
    }
    
    func sendUnBindFacebookNetTask() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task = UnBindAccountNetTask()
        task.accountType = AccountType.Facebook
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
        MONetTaskQueue.instance().addTask(task)
    }
    
    func nameLabelDidTapped(){
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
        maskView.addTapGestureTarget(self, action: #selector(AccountHomeViewController.nameLabelMaskViewDidTapped))
        
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
    
    func sendChangeProfileNetTask(imageUrl : String?, nickName : String?){
        let cNT = ChangeProfileNetTask()
        cNT.imageURL = imageUrl
        cNT.newName = nickName
        MONetTaskQueue.instance().addTaskDelegate(self, uri: cNT.uri())
        MONetTaskQueue.instance().addTask(cNT)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameLabelMaskViewDidTapped()
        let newStr = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if newStr != nameLabel.text && newStr?.characters.count > 0 {
            sendChangeProfileNetTask(nil, nickName: newStr)
            nameLabel.text = newStr
        }
        return true
    }
    
    func nameLabelMaskViewDidTapped(){
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
        photoFullImageView.frame = (navigationController?.view.convertRect(photoImageView.frame, fromView:view))!
        photoFullImageView.backgroundColor = UIColor.defaultBlack()
        photoFullImageView.image = photoImageView.image
        navigationController?.view.addSubview(photoFullImageView)
        photoFullImageView.contentMode = .ScaleAspectFit
        photoFullImageView.addTapGestureTarget(self, action: #selector(AccountHomeViewController.fullImageViewDidTapped))
        UIView.animateWithDuration(0.3, animations: {
            self.photoFullImageView.frame = (self.navigationController?.view.bounds)!
        })
    }
    
    func fullImageViewDidTapped(){
        let orRect = (navigationController?.view.convertRect(photoImageView.frame, fromView:view))!
        UIView.animateWithDuration(0.3, animations: {
            self.photoFullImageView.frame = orRect
            }, completion: { (completion : Bool) -> Void in
                self.photoFullImageView.removeFromSuperview()
        })
    }
    
    func gotoEditPhoto(){
        let takePhotoVC = DJTakePhotoViewController()
        takePhotoVC.delegate = self
        takePhotoVC.title = "Photo"
        navigationController?.presentViewController(UINavigationController(rootViewController: takePhotoVC), animated: true, completion: nil)
    }
    
    func takePhotoViewController(takePhototVC: DJTakePhotoViewController!, didUseImage image: UIImage!) {
        photoImageView.image = image
        
        let uploadNT = DJUploadFileNetTask()
        uploadNT.property = self //to avoid instance release while still has not finish feedbacknettask
        uploadNT.data = UIImageJPEGRepresentation(image, 0.5)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: uploadNT.uri())
        MONetTaskQueue.instance().addTask(uploadNT)
    }
    
    func gotoStylingMissions() {
        let v = StylingMissionsViewController(URLString: ConfigDataContainer.sharedInstance.getMissionListUrl())
        self.navigationController?.pushViewController(v, animated: true)
    }
    
    func gotoFriendList() {
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Friends)
        friendLabel.hideRedDot()
        navigationController?.pushViewController(FriendListViewController(), animated: true)
    }
    
    func gotoFavourites() {
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_Favorites)
        let v = StyleBookViewController(URLString: ConfigDataContainer.sharedInstance.getStyleBookUrl())
        navigationController?.pushViewController(v, animated: true)
    }
    
    func gotoSettings() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    func contactUs() {
        //        Feedback-${user_id}-${platform}-${version}
        
        DJStatisticsLogic.instance().addTraceLog(.Account_Click_ContactUs)
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
    }

}

