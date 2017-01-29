//
//  ShopListTableView.swift
//  DejaFashion
//
//  Created by jiao qing on 21/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol ShopListTableViewDelegate : NSObjectProtocol{
    func shopListTableView(tableview : ShopListTableView, didSelectShop shop: ShopInfo)
    func shopListTableViewStartScroll(tableview : ShopListTableView)
    
}

class ShopListTableView: UITableView {
    var data : [ShopInfo]?
    weak var shopListDelegate : ShopListTableViewDelegate?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
   
        self.showsVerticalScrollIndicator = false
        separatorStyle = .None
        registerClass(ShopListTableViewCell.self, forCellReuseIdentifier: "ShopListTableViewCell")
        delegate = self
        dataSource = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewWillBeginDragging(scrollView : UIScrollView)
    {
        self.shopListDelegate?.shopListTableViewStartScroll(self)
    }
}

extension ShopListTableView : UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data != nil{
            return data!.count
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let tmp = tableView.dequeueReusableCellWithIdentifier("ShopListTableViewCell"){
            let cell = tmp as! ShopListTableViewCell
            let shopInfo = data![indexPath.row]
            let distance = String(format: "%.1fKM", shopInfo.distance)
            cell.shopName(shopInfo.name, address: shopInfo.shopMallAddress, distance: distance, showMayLike: shopInfo.showMayLike)
            cell.setShopImageUrl(shopInfo.brandInfo?.imageUrl)
            return cell
        }else{
            return ShopListTableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let shopInfo = data![indexPath.row]
        self.shopListDelegate?.shopListTableView(self, didSelectShop: shopInfo)
    }
}
