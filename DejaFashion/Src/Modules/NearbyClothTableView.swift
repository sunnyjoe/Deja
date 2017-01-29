//
//  NearbyClothTableView.swift
//  DejaFashion
//
//  Created by jiao qing on 7/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


protocol NearbyClothTableViewDelegate : NSObjectProtocol{
    func nearbyShopInfo(tableview : NearbyClothTableView, didSelectShop shop: NearbyShopInfo?)
    func nearbyShopInfo(tableview : NearbyClothTableView, didSelectCloth cloth: Clothes?)
    func nearbyShopInfo(tableview : NearbyClothTableView, didClickMoreCloth shop: NearbyShopInfo?)
}

class NearbyClothTableView: UITableView,  NearbyClothTableViewCellDelegate{
    var data = [NearbyShopInfo]()
    weak var listDelegate : NearbyClothTableViewDelegate?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.showsVerticalScrollIndicator = false
        separatorStyle = .None
        registerClass(NearbyClothTableViewCell.self, forCellReuseIdentifier: "NearbyClothTableViewCell")
        delegate = self
        dataSource = self
        
        backgroundColor = UIColor(fromHexString: "f6f6f6")
        
        buildTableHeaderView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func nearbyClothTableViewCellDidClickProduct(nearbyClothTableViewCell: NearbyClothTableViewCell, product: Clothes?) {
        listDelegate?.nearbyShopInfo(self, didSelectCloth: product)
    }
    
    func nearbyClothTableViewCellDidClickShop(nearbyClothTableViewCell: NearbyClothTableViewCell, nearbyShopInfo: NearbyShopInfo?) {
        listDelegate?.nearbyShopInfo(self, didSelectShop: nearbyShopInfo)
    }
    
    func nearbyClothTableViewCellDidClickMoreProduct(nearbyClothTableViewCell: NearbyClothTableViewCell, nearbyShopInfo: NearbyShopInfo?) {
        listDelegate?.nearbyShopInfo(self, didClickMoreCloth: nearbyShopInfo)
    }
}

extension NearbyClothTableView: UITableViewDelegate, UITableViewDataSource {
    func buildTableHeaderView() {
        let narLabel = UILabel(frame : CGRectMake(0, 0, frame.size.width, 60))
        narLabel.backgroundColor = UIColor.whiteColor()
        narLabel.withTextColor(UIColor.defaultBlack()).textCentered()
        narLabel.withText(DJStringUtil.localize("These items nearby may interest you", comment: "")).withFontHeleticaMedium(14)
        
        tableHeaderView = narLabel
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let tmp = tableView.dequeueReusableCellWithIdentifier("NearbyClothTableViewCell"){
            let cell = tmp as! NearbyClothTableViewCell
            let shopInfo = data[indexPath.row]
            cell.resetInfo(shopInfo)
            cell.delegate = self
            return cell
        }else{
            return ShopListTableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 175
    }
}
