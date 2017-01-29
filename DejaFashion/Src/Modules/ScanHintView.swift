//
//  ScanHintView.swift
//  DejaFashion
//
//  Created by jiao qing on 3/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ScanHintView: UIView, UIScrollViewDelegate{
    private let scrollView = UIScrollView()
    private let bottomView = UIView()
 
    override init(frame : CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.clipsToBounds = false
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        scrollView.contentInset = UIEdgeInsetsMake(0, 23, 0, 23)
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width - 46, frame.size.height)
        addSubview(scrollView)
        
        let topView = UIView(frame: CGRectMake(-23, 0, scrollView.frame.size.width, 62.5))
        scrollView.addSubview(topView)
        topView.backgroundColor = DJCommonStyle.ColorEA
        
        let title = UILabel(frame : CGRectMake(23, 0, scrollView.frame.size.width - 46, 62.5))
        topView.addSubview(title)
        title.withFontHeleticaMedium(16).withTextColor(UIColor.defaultBlack()).numberOfLines = 0
        title.withText(DJStringUtil.localize("Scan the garment's price tag to find what you want!", comment:""))
        
        var oY = CGRectGetMaxY(topView.frame)
        addLineView(oY)
        oY += buildFirstView(oY) + 30
        addLineView(oY)
        oY += buildSecondView(oY)
        addLineView(oY)
        oY += buildThirdView(oY)
        
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width - 46, oY + 60)
        bottomView.backgroundColor = UIColor.whiteColor()
        bottomView.frame = CGRectMake(0, frame.size.height - 70, frame.size.width, 70)
        addSubview(bottomView)
        let doneButton = DJButton(frame: CGRectMake(frame.size.width / 2 - 115 / 2, 17.5, 115, 35))
        doneButton.setWhiteTitle().withTitle("Got it")
        doneButton.addTarget(self, action: #selector(ScanHintView.done), forControlEvents: .TouchUpInside)
        bottomView.addSubview(doneButton)
    }
    
    func done(){ 
        removeFromSuperview()
    }
    
    func buildFirstView(oY : CGFloat) -> CGFloat{
        let conV = UIView(frame: CGRectMake(0, oY, scrollView.contentSize.width, 429))
        scrollView.addSubview(conV)
        
        let titleView = getSubTitleView(DJStringUtil.localize("Place the complete and clear tag in the scan area.", comment:""), number: "01/")
        conV.addSubview(titleView)
        
        let image1Width : CGFloat = conV.frame.size.width - 15 * 2
        let imageHeight : CGFloat = image1Width * 840 / 897
        let imageV1 = UIImageView(frame: CGRectMake(15, CGRectGetMaxY(titleView.frame) + 10, image1Width, imageHeight))
        conV.addSubview(imageV1)
        imageV1.image = UIImage(named: "TagHint")
        imageV1.contentMode = .ScaleAspectFill
        
        conV.frame = CGRectMake(0, oY, conV.frame.size.width, CGRectGetMaxY(imageV1.frame))
        return conV.frame.size.height
    }
    
    func buildSecondView(oY : CGFloat) -> CGFloat{
        let conV = UIView(frame: CGRectMake(0, oY, scrollView.contentSize.width, 429))
        scrollView.addSubview(conV)
        
        let titleView = getSubTitleView(DJStringUtil.localize("What items are supported?", comment:""), number: "02/")
        conV.addSubview(titleView)
        
        let imageWidth = conV.frame.size.width - 15 * 2
        let imageHeight : CGFloat = imageWidth * 287 / 298
        let imageV = UIImageView(frame: CGRectMake(15, CGRectGetMaxY(titleView.frame), imageWidth, imageHeight))
        conV.addSubview(imageV)
        imageV.image = UIImage(named: "SupportedItem")
        conV.frame = CGRectMake(0, oY, conV.frame.size.width, CGRectGetMaxY(imageV.frame) + 30)
        imageV.contentMode = .ScaleAspectFit
        
        return conV.frame.size.height
    }
    
    func buildThirdView(oY : CGFloat) -> CGFloat{
        let conV = UIView(frame: CGRectMake(0, oY, scrollView.contentSize.width, 429))
        scrollView.addSubview(conV)
        
        let titleView = getSubTitleView(DJStringUtil.localize("The brands we support", comment:""), number: "03/")
        conV.addSubview(titleView)
        
        let recBrandView = BrandImagesView(frame : CGRectMake(0, CGRectGetMaxY(titleView.frame) - 5, conV.frame.size.width, 0))
        var brandList = [BrandInfo]()
        if let tmp = ConfigDataContainer.sharedInstance.getAllBrandList(){
            brandList.appendContentsOf(tmp)
        }
        recBrandView.setBrandList(brandList, fullWidth: conV.frame.size.width)
        recBrandView.frameToFit()
        conV.addSubview(recBrandView)
        
        conV.frame = CGRectMake(0, oY, conV.frame.size.width, CGRectGetMaxY(recBrandView.frame) + 25)
        
        return conV.frame.size.height
    }
    
    func addLineView(oY : CGFloat){
        let lineTop = UIView(frame: CGRectMake(0, oY - 0.5, scrollView.contentSize.width, 0.5))
        lineTop.backgroundColor = DJCommonStyle.ColorCE
        scrollView.addSubview(lineTop)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSubTitleView(text : String, number : String) -> UIView{
        let conV = UIView(frame: CGRectMake(0, 0, scrollView.contentSize.width, 62.5))
        
        let numberTitle = UILabel(frame: CGRectMake(0, 14, conV.frame.size.width, 22))
        numberTitle.withFontHeletica(20).withTextColor(UIColor.defaultBlack())
        numberTitle.withText(number)
        conV.addSubview(numberTitle)
        
        let title = UILabel()
        title.withFontHeletica(15).withTextColor(UIColor.defaultBlack()).numberOfLines = 0
        title.withText(text)
        conV.addSubview(title)
        constrain(title) { title in
            title.top == title.superview!.top + 17
            title.left == title.superview!.left +  35
            title.right == title.superview!.right
        }
        
        return conV
    }
}
