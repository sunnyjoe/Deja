//
//  AddFriendViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 21/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
import AddressBook

class AddFriendViewController: DJBasicViewController, MONetTaskDelegate {
    private let phoneView = UIView()
    private let contactTable = ContactUserTableView()
    private var fbView = UIView()
    private var abView = UIView()
    private let functionHeigth : CGFloat = 70
    
    private var searchField = UITextField()
    var searchBar : UIView?
    let searchResultView = SearchFriendResultView()
    let searchNetTask = SearchFriendNetTask()
    var realSearchField : UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = DJStringUtil.localize("Add Friend", comment:"")
        
        contactTable.eventDelegate = self
        view.addSubview(contactTable)
        
        fbView.frame = CGRectMake(23, 50, view.frame.size.width - 23 * 2, functionHeigth)
        view.addSubview(fbView)
        fbView.addTapGestureTarget(self, action: #selector(AddFriendViewController.importFBDidTapped))
        buildFunctionView(fbView, title: DJStringUtil.localize("Import Facebook Contacts", comment:""), iconImage: UIImage(named: "FBBlueIcon")!)
        if let _ = AccountDataContainer.sharedInstance.bindedFacebookInfo{
            fbView.hidden = true
        }else{
            fbView.hidden = false
        }
        
        abView.frame = CGRectMake(23, CGRectGetMaxY(fbView.frame), view.frame.size.width - 23 * 2, functionHeigth)
        view.addSubview(abView)
        abView.addTapGestureTarget(self, action: #selector(AddFriendViewController.importABDidTapped))
        buildFunctionView(abView, title: DJStringUtil.localize("Import Phone Contacts", comment:""), iconImage: UIImage(named: "AdressBookIcon")!)
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.gray81Color(),
            NSFontAttributeName : DJFont.helveticaFontOfSize(14)
        ]
        searchField.font = DJFont.helveticaFontOfSize(14)
        searchField.textColor = DJCommonStyle.BackgroundColor
        searchField.attributedPlaceholder = NSAttributedString(string: DJStringUtil.localize("Search by Phone Number/Name", comment:""), attributes: attributes)
        searchField.frame = CGRectMake(23, 0, view.frame.size.width - 23 * 2, 50)
        searchField.addSubview(UIView(frame: CGRect(x: 0, y: 49.5, width: view.frame.size.width - 23 * 2, height: 0.5)).withBackgroundColor(DJCommonStyle.DividerColor))
        
        let searchIcon = UIView(frame: CGRectMake(0, 0, 30, 50))
        let image = UIImage(named : "SearchIcon")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 15, image!.size.width, image!.size.height)
        searchIcon.addSubview(imageView)
        searchField.leftView = searchIcon;
        searchField.leftViewMode = UITextFieldViewMode.Always;
        view.addSubview(searchField)
        
        let maskBtn = UIButton(frame: searchField.bounds)
        maskBtn.backgroundColor = UIColor.clearColor()
        maskBtn.addTarget(self, action: #selector(AddFriendViewController.searchareaDidTapped), forControlEvents: .TouchUpInside)
        view.addSubview(maskBtn)
        
        reLoadContactTable()
        checkAdressBookAuth()
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: BindAccountNetTask.uri())
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateViewLayout()
    }
    
    func checkAdressBookAuth(){
        let abS = ABAddressBookGetAuthorizationStatus()
        if abS == .Authorized{
            importABContact()
            abView.hidden = true
        }else{
            SocialDataContainer.sharedInstance.updateAddressBook([])
            reLoadContactTable()
            abView.hidden = false
            
            sendGetContactStatusNetTask()
        }
        updateViewLayout()
    }
    
    func updateViewLayout(){
        var oY : CGFloat = 0
        if fbView.hidden == false{
            oY = CGRectGetMaxY(fbView.frame)
        }else {
            oY = CGRectGetMaxY(searchField.frame)
        }
        
        abView.frame = CGRectMake(23, oY, view.frame.size.width - 23 * 2, functionHeigth)
        
        if fbView.hidden == false && abView.hidden == false{
            contactTable.hidden = true
        }else{
            contactTable.hidden = false
            oY = functionHeigth + CGRectGetMaxY(searchField.frame)
            if fbView.hidden == true && abView.hidden == true{
                oY = CGRectGetMaxY(searchField.frame)
                contactTable.setHeaderLabelText(DJStringUtil.localize("Contacts From Facebook/Phonebook", comment:""))
            }else if fbView.hidden == true{
                contactTable.setHeaderLabelText(DJStringUtil.localize("Contacts From Facebook", comment:""))
            }else{
                contactTable.setHeaderLabelText(DJStringUtil.localize("Contacts From Phonebook", comment:""))
            }
            contactTable.frame = CGRectMake(23, oY, view.frame.size.width - 23 * 2, view.frame.size.height - oY)
        }
    }
    
    func importFBDidTapped(){
        let bi = AccountDataContainer.sharedInstance.bindedFacebookInfo
        if bi == nil{
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            DJLoginLogic.instance().bindFacebook()
            DJLoginLogic.instance().addDelegate(self)
            MONetTaskQueue.instance().addTaskDelegate(self, uri: BindAccountNetTask.uri())
        }else{
            fbView.hidden = true
            updateViewLayout()
        }
    }
    
    func importABDidTapped(){
        let abS = ABAddressBookGetAuthorizationStatus()
        if abS == .NotDetermined{
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        self.abView.hidden = true
                        self.importABContact()
                    }else{
                        self.abView.hidden = false
                        self.showAdressBookAlertView()
                    }
                    self.updateViewLayout()
                }
            }
        }else if abS == .Denied || abS == .Restricted{
            self.showAdressBookAlertView()
        }
    }
    
    func showAdressBookAlertView(){
        let arl = DJAlertView(title: DJStringUtil.localize("'Deja' want to access your phonebook", comment:""), message: DJStringUtil.localize("Please go to settings > Deja and allow the access to contacts", comment:""), cancelButtonTitle: DJStringUtil.localize("Ok", comment:""))
        arl.delegate = self
        arl.show()
    }
    
    
    func importABContact(){
        let abContacts = SocialDataContainer.sharedInstance.getAllABContacts()
        if abContacts.count == 0{
            SocialDataContainer.sharedInstance.reStoreAddressBook({
                self.sendGetContactStatusNetTask(true)
            })
        }else{
            let changedBlock = {
                self.reLoadContactTable()
                self.sendGetContactStatusNetTask(true)
            }
            
            let sameBlock = {
                self.sendGetContactStatusNetTask()
            }
            
            SocialDataContainer.sharedInstance.checkAddressBookChanges(changedBlock, same: sameBlock)
        }
    }
    
    func reLoadContactTable(){
        self.contactTable.contacts = SocialDataContainer.sharedInstance.getMergedContacts()
        self.contactTable.reloadData()
    }
    
    func sendGetContactStatusNetTask(resendAB : Bool = false){
        let getContactNT = AddFriendGetStatusNetTask()
        
        if resendAB{
            getContactNT.phoneNumbers = SocialDataContainer.sharedInstance.getAllPhoneNumbers()
        }
        MONetTaskQueue.instance().addTaskDelegate(self, uri: getContactNT.uri())
        MONetTaskQueue.instance().addTask(getContactNT)
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task.isKindOfClass(AddFriendGetStatusNetTask){
            let rt = task as! AddFriendGetStatusNetTask
            if rt.fbExpired{
                fbView.hidden = false
                updateViewLayout()
            }
            
            reLoadContactTable()
            MBProgressHUD.hideHUDForView(view, animated: true)
        }else if task.isKindOfClass(AddFriendSendRequestNetTask){
            MBProgressHUD.hideHUDForView(view, animated: true)
            MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Request Sent", comment:""), animated: true)
            let rt = task as! AddFriendSendRequestNetTask
            let theUid = rt.friendUid
            for oneContact in contactTable.contacts{
                if oneContact.uid == theUid{
                    oneContact.relationStatus = .sendedRequest
                }
            }
            for oneContact in searchResultView.searchTable.contacts{
                if oneContact.uid == theUid{
                    oneContact.relationStatus = .sendedRequest
                }
            }
            contactTable.reloadData()
            searchResultView.searchTable.reloadData()
        }else if task.isKindOfClass(AddFriendConfrimNetTask){
            MBProgressHUD.hideHUDForView(view, animated: true)
            MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Confirmed", comment:""), animated: true)
            
            let rt = task as! AddFriendConfrimNetTask
            let theUid = rt.friendUid
            for oneContact in contactTable.contacts{
                if oneContact.uid == theUid{
                    oneContact.relationStatus = .isFriend
                }
            }
            for oneContact in searchResultView.searchTable.contacts{
                if oneContact.uid == theUid{
                    oneContact.relationStatus = .isFriend
                }
            }
            contactTable.reloadData()
            searchResultView.searchTable.reloadData()
        }else if task == searchNetTask{
            if searchNetTask.page == 0{
                searchResultView.searchTable.contacts = searchNetTask.searchContact
            }else{
                searchResultView.searchTable.contacts.appendContentsOf(searchNetTask.searchContact)
            }
            
            searchResultView.searchTable.reloadData()
            if searchNetTask.searchContact.count == 0{
                searchResultView.showNoResultView(true)
            }else{
                searchResultView.showNoResultView(false)
            }
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task.isKindOfClass(AddFriendGetStatusNetTask){
            MBProgressHUD.hideHUDForView(view, animated: true)
            if task.error.code == 1{
                sendGetContactStatusNetTask(true)
            }else {
                MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Opps, NetWork is down", comment:""), animated: true)
            }
        }else if let netTask = task as? BindAccountNetTask {
            if netTask.error.code == 7{
                let message = DJStringUtil.localize("This Facebook account has already binding to another phone number.", comment:"")
                let alertView = DJAlertView(title: DJStringUtil.localize("Oops", comment:""), message: message, cancelButtonTitle: "OK")
                alertView.show()
            }else if netTask.error.code == 6{
                let message = DJStringUtil.localize("This Facebook account has already login independent.", comment:"")
                let alertView = DJAlertView(title: DJStringUtil.localize("Oops", comment:""), message: message, cancelButtonTitle: "OK")
                alertView.show()
            }else {
                MBProgressHUD.hideHUDForView(view, animated: true)
                MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Opps, NetWork is down", comment:""), animated: true)
            }
        }else if task.isKindOfClass(AddFriendSendRequestNetTask) ||  task.isKindOfClass(AddFriendConfrimNetTask) || task == searchNetTask{
            MBProgressHUD.hideHUDForView(view, animated: true)
            MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Opps, NetWork is down", comment:""), animated: true)
        }
    }
    
    func getAllContacts(addressBookRef: ABAddressBook){
        let sourcesArray = ABAddressBookCopyArrayOfAllSources(addressBookRef).takeRetainedValue() as Array
        
        for source in sourcesArray{
            let abSource = source
            let name = ABRecordCopyValue(abSource, kABSourceNameProperty)
            print("name is \(name)")
        }
    }
    
    func buildFunctionView(theView : UIView, title : String, iconImage : UIImage){
        let abIcon = UIImageView(frame: CGRectMake(0, functionHeigth / 2 - 27 / 2, 27, 27))
        theView.addSubview(abIcon)
        abIcon.image = iconImage
        
        let abLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(abIcon.frame) + 10, 0, theView.frame.size.width - CGRectGetMaxX(abIcon.frame) - 10 - 50, theView.frame.size.height))
        theView.addSubview(abLabel)
        abLabel.textAlignment = .Left
        abLabel.withFontHeleticaMedium(16).withTextColor(UIColor.defaultBlack()).withText(title)
        if view.frame.size.width < 375{
            abLabel.withFontHeleticaMedium(14)
        }
        
        let arrowIcon = UIImageView(frame: CGRectMake(theView.frame.size.width - 8, functionHeigth / 2 - 12 / 2, 8, 12))
        theView.addSubview(arrowIcon)
        arrowIcon.image = UIImage(named: "ProfileArrow")
        
        let lineView = UIView()
        theView.addSubview(lineView)
        lineView.backgroundColor = UIColor(fromHexString: "cecece")
        lineView.frame = CGRectMake(0, functionHeigth - 0.5, theView.frame.size.width, 0.5)
    }
    
}

extension AddFriendViewController : DJAlertViewDelegate, ThirdPartyLoginDelegate{
    func alertView(alertView: DJAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0{
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    func thirdPartyBindDidSuccess() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        fbView.hidden = true
        updateViewLayout()
        sendGetContactStatusNetTask()
    }
    
    func thirdPartyBindDidCanceled() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func thirdPartyBindDidError() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
}

extension AddFriendViewController : SearchUserTableViewDelegate, ContactUserTableViewDelegate, UITextFieldDelegate{
    func userTableViewDidClickAdd(userTableView: UserTableView, userId : String, name : String?){
        let addNetTask = AddFriendSendRequestNetTask()
        addNetTask.friendUid = userId
        addNetTask.name = name
        MONetTaskQueue.instance().addTaskDelegate(self, uri: addNetTask.uri())
        MONetTaskQueue.instance().addTask(addNetTask)
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func userTableViewDidClickConfirm(userTableView: UserTableView, userId : String){
        let confirmNetTask = AddFriendConfrimNetTask()
        confirmNetTask.friendUid = userId
        MONetTaskQueue.instance().addTaskDelegate(self, uri: confirmNetTask.uri())
        MONetTaskQueue.instance().addTask(confirmNetTask)
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func userTableViewDidClickInvite(userTableView: UserTableView, phoneNumber : String){
        if MFMessageComposeViewController.canSendText() {
            sendSmsMessage(phoneNumber, text: DJStringUtil.localize("Add me on Deja to see my wardrobe and help me put together outfits! http://appsto.re/sg/hQk45.i", comment:""))
        }else {
            let alertView = DJAlertView(title: nil, message: DJStringUtil.localize("SMS not available", comment:""), cancelButtonTitle:  DJStringUtil.localize("OK", comment:""))
            alertView.show()
        }
    }
    
    func sendSearchNetTask(keyWord : String){
        searchNetTask.queryStr = keyWord
        MONetTaskQueue.instance().addTaskDelegate(self, uri: searchNetTask.uri())
        MONetTaskQueue.instance().addTask(searchNetTask)
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text{
            searchNetTask.page = 0
            sendSearchNetTask(text)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func searchareaDidTapped(){
        if searchBar == nil{
            searchBar = UIView()
            searchBar!.backgroundColor = UIColor.defaultBlack()
            searchBar!.frame = CGRectMake(0, 0, view.frame.size.width, 64)
            
            let attributes = [
                NSForegroundColorAttributeName: UIColor.gray81Color(),
                NSFontAttributeName : DJFont.helveticaFontOfSize(14)
            ]
            realSearchField = UITextField(frame : CGRectMake(10, 24, searchBar!.frame.size.width - 10 - 67, 30))
            realSearchField!.clearButtonMode = .WhileEditing
            realSearchField!.font = DJFont.helveticaFontOfSize(14)
            realSearchField!.textColor = DJCommonStyle.BackgroundColor
            realSearchField!.backgroundColor = UIColor.whiteColor()
            realSearchField!.returnKeyType = .Search
            realSearchField!.delegate = self
            realSearchField!.attributedPlaceholder = NSAttributedString(string: DJStringUtil.localize("Search by Phone Number/Name", comment:""), attributes: attributes)
            
            let image = UIImage(named : "SmallSearchIcon")
            let searchIcon = UIView(frame: CGRectMake(0, 0, image!.size.width + 8 + 7, realSearchField!.frame.size.height))
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(8, realSearchField!.frame.size.height / 2 - image!.size.height / 2, image!.size.width, image!.size.height)
            searchIcon.addSubview(imageView)
            realSearchField!.leftView = searchIcon;
            realSearchField!.leftViewMode = UITextFieldViewMode.Always;
            searchBar!.addSubview(realSearchField!)
            
            let cancelBtn = DJButton()
            cancelBtn.withFontHeletica(16).withTitle(DJStringUtil.localize("Cancel", comment:"")).withTitleColor(UIColor.whiteColor())
            cancelBtn.addTarget(self, action: #selector(AddFriendViewController.cancelSearchBtnDidTapped), forControlEvents: .TouchUpInside)
            cancelBtn.sizeToFit()
            let cbwidth = cancelBtn.frame.size.width
            cancelBtn.frame = CGRectMake(searchBar!.frame.size.width - 10 - cbwidth, realSearchField!.frame.origin.y, cbwidth, realSearchField!.frame.size.height)
            searchBar!.addSubview(cancelBtn)
            
            searchResultView.frame = view.bounds
            searchResultView.setTableEventDelegate(self)
        }
        
        navigationController?.view.addSubview(searchBar!)
        
        view.addSubview(searchResultView)
        searchResultView.alpha = 0
        searchBar?.alpha = 0
        UIView.animateWithDuration(0.25, animations: {
            self.searchResultView.alpha = 1
            self.searchBar?.alpha = 1
            self.realSearchField!.becomeFirstResponder()
        })
    }
    
    func userTableViewLoadMore(userTableView: UserTableView) {
        if searchNetTask.end{
            return
        }else{
            if let previousStr = searchNetTask.queryStr{
                searchNetTask.page += 1
                sendSearchNetTask(previousStr)
            }
        }
    }
    
    func cancelSearchBtnDidTapped(){
        realSearchField!.resignFirstResponder()
        UIView.animateWithDuration(0.2, animations: {
            self.searchResultView.alpha = 0
            self.searchBar?.alpha = 0
            }, completion: { (completion : Bool) -> Void in
                self.searchResultView.removeFromSuperview()
                self.searchBar?.removeFromSuperview()
            }
        )
    }
}

import MessageUI
extension AddFriendViewController : MFMessageComposeViewControllerDelegate{
    func sendSmsMessage(number : String, text : String) {
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = text
        messageVC.recipients = [number]
        messageVC.messageComposeDelegate = self
        
        self.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.Cancelled:
            _Log("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResult.Failed:
            _Log("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResult.Sent:
            _Log("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
            MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Invitation sended", comment:""), animated: true)
            if let _ = controller.recipients?.first {
            }
        }
    }
}

extension AddFriendViewController {
    
    
}








