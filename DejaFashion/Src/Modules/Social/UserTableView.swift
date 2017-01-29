//
//  FriendTableView.swift
//  DejaFashion
//
//  Created by jiao qing on 21/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol UserTableViewEventDelegate : NSObjectProtocol{
    func userTableViewDidClickAdd(userTableView: UserTableView, userId : String, name : String?)
    func userTableViewDidClickConfirm(userTableView: UserTableView, userId : String)
}

let addFriendReuseCellName = "AddFriendCell"

class UserTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var contacts = [Contact]()
    weak var eventDelegate : UserTableViewEventDelegate?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        backgroundColor = UIColor.whiteColor()
        self.delegate = self
        self.dataSource = self
        self.separatorStyle = .None
        self.showsVerticalScrollIndicator = false
        self.registerClass(UserTableCell.self, forCellReuseIdentifier: addFriendReuseCellName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return contacts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 61
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(addFriendReuseCellName) as! UserTableCell
        let oneContact = contacts[indexPath.row]
        cell.selectionStyle = .None
        cell.contact = oneContact
        cell.delegate = self
        if let tmp = oneContact.phoneName{
            cell.resetName(tmp)
        }else if let tmp = oneContact.fbName{
            cell.resetName(tmp)
        }else if let tmp = oneContact.dejaName{
            cell.resetName(tmp)
        }
        cell.resetImage(UIImage(named: defaultBlackAvatarImageName)!)
        
        if oneContact.dejaImageUrl != nil{
            cell.resetImageWithUrl(oneContact.dejaImageUrl!)
        }else if let url = oneContact.fbImageUrl{
            cell.resetImageWithUrl(url)
        }else if let tmp = oneContact.phoneImage{
            cell.resetImage(tmp)
        }
        
        let inAB = (oneContact.phoneNumber != nil)
        let inFB = (oneContact.fbName != nil)
        cell.isInABorFB(inAB, inFB: inFB)
        
        var cellStatus = CellStatus.None
        if let relation = oneContact.relationStatus{
            cellStatus = convertRelationToCellStatus(relation)
        }else{
            if oneContact.uid == nil{
                cellStatus = .Invite
            }
        }
        cell.resetCellStatus(cellStatus)
        
        return cell
    }
    
    func convertRelationToCellStatus(relation : RelationStatus) -> CellStatus{
        var cellStatus = CellStatus.None
        switch relation{
        case .isFriend : cellStatus = .Added
        case .notFriend : cellStatus = .Add
        case .requestAccept : cellStatus = .Confirm
        case .sendedRequest : cellStatus = .RequestSent
        default : break
        }
        return cellStatus
    }
}

extension UserTableView : UserTableCellDelegate{
    func userTableCellDidClickAdd(userTableCell: UserTableCell){
        if let contact = userTableCell.contact{
            if let uid = contact.uid{
                self.eventDelegate?.userTableViewDidClickAdd(self, userId: uid, name: contact.dejaName)
            }
        }
    }
    
    func userTableCellDidClickConfirm(userTableCell: UserTableCell){
        if let contact = userTableCell.contact{
            if let uid = contact.uid{
                self.eventDelegate?.userTableViewDidClickConfirm(self, userId: uid)
            }
        }
    }
    
    func userTableCellDidClickInvite(userTableCell: UserTableCell){
        if let contact = userTableCell.contact{
            if !contact.isKindOfClass(Contact){
                return
            }
            let theDelegate = self.eventDelegate
            if theDelegate == nil {
                return
            }
            let cdelegate = theDelegate as! ContactUserTableViewDelegate
            let rcontact = contact
            if let pN = rcontact.phoneNumber{
                cdelegate.userTableViewDidClickInvite(self, phoneNumber: pN)
            }
        }
    }
}