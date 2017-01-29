
//
//  SearchFriendView.swift
//  DejaFashion
//
//  Created by jiao qing on 29/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class SearchFriendResultView: UIView {
    let searchTable = SearchUserTableView()
    let noresultLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        noresultLabel.withFontHeleticaMedium(16).withText(DJStringUtil.localize("No Users Found", comment:"")).withTextColor(UIColor.gray81Color())
        noresultLabel.hidden = true
        noresultLabel.textAlignment = .Center
        
        addSubview(searchTable)
    }
    
    func setTableEventDelegate(theObj : SearchUserTableViewDelegate){
        searchTable.eventDelegate = theObj
    }
 
    
    func showNoResultView(show : Bool){
        noresultLabel.hidden = !show
        
        if show{
            addSubview(noresultLabel)
        }else{
            noresultLabel.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchTable.frame =  CGRectMake(23, 0, self.frame.size.width - 2 * 23, self.frame.size.height)
        noresultLabel.frame = CGRectMake(0, 100, frame.size.width, 35)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
