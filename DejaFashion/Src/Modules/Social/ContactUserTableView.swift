//
//  ContactUserTableView.swift
//  DejaFashion
//
//  Created by jiao qing on 29/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol ContactUserTableViewDelegate : UserTableViewEventDelegate{
    func userTableViewDidClickInvite(userTableView: UserTableView, phoneNumber : String)
}

class ContactUserTableView: UserTableView {
    private let headerLabel = UILabel()
    
    func setHeaderLabelText(str : String){
        headerLabel.text = str
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 47))
        headView.addSubview(headerLabel)
        headView.backgroundColor = UIColor.whiteColor()
        
        headerLabel.withTextColor(UIColor.gray81Color()).withFontHeletica(14)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        constrain(headerLabel, headView) { headerLabel,headView in
            headerLabel.left == headView.left
            headerLabel.top == headView.top + 20
        }
        return headView
    }
    
     
    
}
