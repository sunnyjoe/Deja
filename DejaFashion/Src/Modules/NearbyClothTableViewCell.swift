//
//  NearbyClothTableViewCell.swift
//  DejaFashion
//
//  Created by jiao qing on 5/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol NearbyClothTableViewCellDelegate : NSObjectProtocol{
    func nearbyClothTableViewCellDidClickProduct(nearbyClothTableViewCell : NearbyClothTableViewCell, product : Clothes?)
    func nearbyClothTableViewCellDidClickMoreProduct(nearbyClothTableViewCell : NearbyClothTableViewCell, nearbyShopInfo: NearbyShopInfo?)
    func nearbyClothTableViewCellDidClickShop(nearbyClothTableViewCell : NearbyClothTableViewCell, nearbyShopInfo : NearbyShopInfo?)
}

class NearbyClothTableViewCell: UITableViewCell {
    private let imgIV = UIImageView()
    private let nameLabel = UILabel()
    private let numberLabel = UILabel()
    private let scrollView = UIScrollView()
    
    var nearbyShopInfo : NearbyShopInfo?
    
    weak var delegate : NearbyClothTableViewCellDelegate?
    
    private let topControl = UIControl()
    private let lineBorder = UIView()
    private let topHeight : CGFloat = 50
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(fromHexString: "f6f6f6")
        
        imgIV.frame = CGRectMake(23, 10, 30, 30)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        nameLabel.withTextColor(UIColor.defaultBlack()).withFontHeleticaMedium(15)
        nameLabel.textAlignment = .Left
        numberLabel.textAlignment = .Right
        numberLabel.withFontHeletica(14).withTextColor(DJCommonStyle.Color81)
        addSubviews(imgIV, nameLabel, numberLabel, topControl, scrollView)
        self.selectionStyle = .None
        
        topControl.addTarget(self, action: #selector(didClickTopControl), forControlEvents: .TouchUpInside)
        
        lineBorder.backgroundColor = UIColor.whiteColor()
        addSubview(lineBorder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
        nameLabel.frame = CGRectMake(CGRectGetMaxX(imgIV.frame) + 10, 0, frame.size.width - CGRectGetMaxX(imgIV.frame) - 10 - 23 - 113 - 10, topHeight)
        numberLabel.frame = CGRectMake(frame.size.width - 23 - 113, 0, 113, topHeight)
        
        topControl.frame = CGRectMake(0, 0, frame.size.width, topHeight)
        scrollView.frame = CGRectMake(23, topHeight, frame.size.width - 23 * 2, 110)
        rebuildScrollView()
        
        lineBorder.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1)
    }
    
    func didClickTopControl(){
        delegate?.nearbyClothTableViewCellDidClickShop(self, nearbyShopInfo: nearbyShopInfo)
    }
    
    func resetInfo(nearbyShopInfo : NearbyShopInfo){
        self.nearbyShopInfo = nearbyShopInfo
        
        if let tmp = nearbyShopInfo.brandInfo {
            if let url = NSURL(string : tmp.imageUrl){
                imgIV.sd_setImageWithURL(url)
            }
            nameLabel.withText(tmp.name)
        }
        if nearbyShopInfo.shopNumber > 1 {
            numberLabel.text = "\(nearbyShopInfo.shopNumber) stores nearby >"
        }else{
            numberLabel.text = "\(nearbyShopInfo.shopNumber) store nearby >"
        }
        
        
        rebuildScrollView()
    }
    
    func productDidClicked(btn : UIButton){
        if let tmp = btn.property as? Clothes{
            delegate?.nearbyClothTableViewCellDidClickProduct(self, product: tmp)
        }
    }
    
    func productDidClickedMore(){
        delegate?.nearbyClothTableViewCellDidClickMoreProduct(self, nearbyShopInfo: nearbyShopInfo)
    }
    
    func rebuildScrollView(){
        scrollView.removeAllSubViews()
        if nearbyShopInfo == nil {
            return
        }
        
        let width = scrollView.frame.size.width / 3
        let height = scrollView.frame.size.height
        
        for (index, oneCloth) in nearbyShopInfo!.sampleProducts.enumerate() {
            let clBtn = UIButton(frame : CGRectMake(CGFloat(index) * width, 0, width - 1, height))
            scrollView.addSubview(clBtn)
            
            let imgV = UIImageView(frame : clBtn.bounds)
            imgV.backgroundColor = UIColor.whiteColor()
            
            clBtn.addSubview(imgV)
            imgV.contentMode = .ScaleAspectFit
            if let thumbUrl = oneCloth.thumbUrl{
                if let url = NSURL(string : thumbUrl){
                    imgV.sd_setImageWithURL(url)
                }
            }
            clBtn.property = oneCloth
            if index == nearbyShopInfo!.sampleProducts.count - 1 && nearbyShopInfo!.clothNumber > 3{
                let maskIV = UIImageView(frame: clBtn.bounds)
                clBtn.addSubview(maskIV)
                
                maskIV.backgroundColor = UIColor(fromHexString: "000000", alpha: 0.35)
                let hintLabel = UILabel(frame: clBtn.bounds)
                clBtn.addSubview(hintLabel)
                hintLabel.withText("+ \(nearbyShopInfo!.clothNumber)").withTextColor(UIColor.whiteColor()).withFontHeleticaMedium(15).textCentered()
                 clBtn.addTarget(self, action: #selector(productDidClickedMore), forControlEvents: .TouchUpInside)
            }else{
                clBtn.addTarget(self, action: #selector(productDidClicked(_:)), forControlEvents: .TouchUpInside)
            }
        }
        
        scrollView.contentSize = CGSizeMake(width * CGFloat(nearbyShopInfo!.sampleProducts.count), scrollView.frame.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
