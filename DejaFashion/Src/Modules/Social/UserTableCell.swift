
//
//  UserTableCell.swift
//  DejaFashion
//
//  Created by jiao qing on 21/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
let imageSize : CGFloat = 41
let iconSize : CGFloat = 15

enum CellStatus{
    case Add
    case Confirm
    case Added
    case RequestSent
    case Invite
    case None
}

protocol UserTableCellDelegate : NSObjectProtocol{
    func userTableCellDidClickAdd(userTableCell: UserTableCell)
    func userTableCellDidClickConfirm(userTableCell: UserTableCell)
    func userTableCellDidClickInvite(userTableCell: UserTableCell)
}

class UserTableCell: UITableViewCell {
    private let avatarIV = UIImageView()
    private let nameLabel = UILabel()
    private let fromIV1 = UIImageView()
    private let fromIV2 = UIImageView()
    
    private let statusBtn = UIButton()
    private let statusLabel = UILabel()
    private var cellSS = CellStatus.None
    var contact : Contact?
    
    weak var delegate : UserTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        statusBtn.hidden = true
        self.addSubview(statusBtn)
        statusBtn.backgroundColor = UIColor.defaultBlack()
        statusBtn.layer.cornerRadius = 4
        statusBtn.withTitleColor(UIColor.whiteColor()).withFontHeletica(13)
        statusBtn.setBackgroundColor(UIColor.defaultRed(), forState: .Highlighted)
        statusBtn.translatesAutoresizingMaskIntoConstraints = false
        constrain(statusBtn) { statusBtn in
            statusBtn.right == statusBtn.superview!.right
            statusBtn.centerY == statusBtn.superview!.centerY
        }
        statusBtn.addTarget(self, action: #selector(UserTableCell.statusBtnDidClicked), forControlEvents: .TouchUpInside)
        NSLayoutConstraint(item: statusBtn,attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30).active = true
        NSLayoutConstraint(item: statusBtn,attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 67).active = true
        
        statusLabel.hidden = true
        self.addSubview(statusLabel)
        statusLabel.withFontHeletica(13).withTextColor(UIColor(fromHexString: "b5b7b6"))
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        constrain(statusLabel) { statusLabel in
            statusLabel.right == statusLabel.superview!.right
            statusLabel.centerY == statusLabel.superview!.centerY
        }
        
        avatarIV.contentMode = .ScaleAspectFill
        addSubview(avatarIV)
        addSubview(nameLabel)
        
        addSubview(fromIV1)
        addSubview(fromIV2)
        
        fromIV1.hidden = true
        fromIV2.hidden = true
        
        avatarIV.contentMode = .ScaleAspectFill
        avatarIV.layer.cornerRadius = imageSize / 2
        avatarIV.clipsToBounds = true
        avatarIV.translatesAutoresizingMaskIntoConstraints = false
        constrain(avatarIV) { avatarIV in
            avatarIV.left == avatarIV.superview!.left
            avatarIV.centerY == avatarIV.superview!.centerY
        }
        NSLayoutConstraint(item: avatarIV,attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: imageSize).active = true
        NSLayoutConstraint(item: avatarIV,attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: imageSize).active = true
        
        nameLabel.withFontHeleticaMedium(15).withTextColor(UIColor.defaultBlack())
        nameLabel.textAlignment = .Left
        constrain(nameLabel, avatarIV) { nameLabel,avatarIV in
            nameLabel.left == avatarIV.right + 10
            nameLabel.top == nameLabel.superview!.top
            nameLabel.bottom == nameLabel.superview!.bottom
        }
        
        fromIV1.translatesAutoresizingMaskIntoConstraints = false
        constrain(fromIV1, nameLabel) { fromIV1, nameLabel in
            fromIV1.left == nameLabel.right + 3
            fromIV1.centerY == fromIV1.superview!.centerY
        }
        NSLayoutConstraint(item: fromIV1,attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: iconSize).active = true
        NSLayoutConstraint(item: fromIV1,attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: iconSize).active = true
        
        fromIV2.translatesAutoresizingMaskIntoConstraints = false
        constrain(fromIV1, fromIV2) { fromIV1, fromIV2 in
            fromIV2.left == fromIV1.right + 3
            fromIV2.centerY == fromIV2.superview!.centerY
        }
        NSLayoutConstraint(item: fromIV2,attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: iconSize).active = true
        NSLayoutConstraint(item: fromIV2,attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: iconSize).active = true
        
        let lineView = UIView()
        self.addSubview(lineView)
        lineView.backgroundColor = DJCommonStyle.DividerColor
        lineView.translatesAutoresizingMaskIntoConstraints = false
        constrain(lineView) { lineView in
            lineView.left == lineView.superview!.left
            lineView.right == lineView.superview!.right
            lineView.bottom == lineView.superview!.bottom
        }
        NSLayoutConstraint(item: lineView,attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0.5).active = true
    }
    
    func resetName(name : String?){
        if name == nil{
            nameLabel.text = ""
            return
        }
        
        var trimmedStr = name!
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        if screenWidth < 375{
            if trimmedStr.characters.count > 14{
                let ts = (trimmedStr as NSString).substringToIndex(12)
                trimmedStr = "\(ts)..."
            }
        }else if screenWidth == 375{
            if trimmedStr.characters.count > 20{
                let ts = (trimmedStr as NSString).substringToIndex(18)
                trimmedStr = "\(ts)..."
            }
        }else if screenWidth == 414{
            if trimmedStr.characters.count > 25{
                let ts = (trimmedStr as NSString).substringToIndex(24)
                trimmedStr = "\(ts)..."
            }
        }
        nameLabel.text = trimmedStr
    }
    
    func resetImage(image : UIImage){
        avatarIV.image = image
    }
    
    func resetImageWithUrl(urlStr : String){
        if let url = NSURL(string: urlStr){
            avatarIV.sd_setImageWithURL(url)
        }
    }
    
    func resetCellStatus(cellStatus : CellStatus){
        cellSS = cellStatus
        switch cellStatus{
        case .None :
            statusBtn.hidden = true;
            statusLabel.hidden = true
        case .Invite :
            statusBtn.hidden = false;
            statusBtn.withTitle("Invite");
            statusLabel.hidden = true
        case .Add :
            statusBtn.hidden = false;
            statusBtn.withTitle("Add");
            statusLabel.hidden = true
        case .Added :
            statusLabel.hidden = false;
            statusLabel.text = "Added";
            statusBtn.hidden = true
        case .Confirm :
            statusBtn.hidden = false;
            statusBtn.withTitle("Confirm");
            statusLabel.hidden = true
        case .RequestSent :
            statusLabel.hidden = false;
            statusLabel.text = "Request Sent";
            statusBtn.hidden = true
        }
    }
    
    func statusBtnDidClicked(){
        switch cellSS{
        case .Invite :
            delegate?.userTableCellDidClickInvite(self)
        case .Add :
            delegate?.userTableCellDidClickAdd(self)
        case .Confirm :
            delegate?.userTableCellDidClickConfirm(self)
        default :
            break
        }
    }
    
    func isInABorFB(inAB : Bool, inFB : Bool){
        fromIV1.hidden = false
        fromIV2.hidden = false
        
        let abI = UIImage(named: "AdressBookSmallIcon")
        let fbI = UIImage(named: "FBSmallIcon")
        if inAB && inFB{
            fromIV1.image = abI
            fromIV2.image = fbI
        }else{
            fromIV2.hidden = true
            if inAB{
                fromIV1.image = abI
            }else if inFB{
                fromIV1.image = fbI
            }else{
                fromIV1.hidden = true
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
