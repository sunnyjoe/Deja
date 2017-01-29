//
//  SearchUserTableView.swift
//  DejaFashion
//
//  Created by jiao qing on 29/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol SearchUserTableViewDelegate : UserTableViewEventDelegate{
    func userTableViewLoadMore(userTableView: UserTableView)
}

class SearchUserTableView: UserTableView {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == contacts.count - 1{
            let theDelegate = self.eventDelegate
            if theDelegate == nil {
                return
            }
            let cdelegate = theDelegate as! SearchUserTableViewDelegate
            cdelegate.userTableViewLoadMore(self)
        }
    }
}
