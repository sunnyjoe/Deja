//
//  ClothMultiColorsView.swift
//  DejaFashion
//
//  Created by jiao qing on 16/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

@objc protocol ClothMultiColorsViewDelegate : NSObjectProtocol{
    func clothMultiColorsViewDidChooseProduct(clothMultiColorsView : ClothMultiColorsView, selectedClothes : Clothes)
}


class ClothMultiColorsView: PullUpHideShowBasicView {
    private var pdt : [Clothes]!
    weak var delegate : ClothMultiColorsViewDelegate?
    private var selectedClothes : Clothes!
    
    private let selectorView = UIImageView()
    private let mainImageV = UIImageView()
    private var nameLabel = UILabel()
    private var brandLabel = UILabel()
    private var priceLabel = UILabel()
    
    init(frame: CGRect, pdt : [Clothes]){
        super.init(frame : frame)
        
        self.pdt = pdt
        selectedClothes = pdt[0]
        
        buildContentView()
        refreshView()
    }
    
    private func refreshView(){
        if let str = selectedClothes.thumbUrl{
            if let tmp = NSURL(string: str){
                mainImageV.sd_setImageWithURL(tmp)
            }
        }
        
        if let tmp = selectedClothes.brandName{
            brandLabel.text = tmp
        }else{
            brandLabel.text = "N.A"
        }
        nameLabel.text = selectedClothes.name
        priceLabel.text = Clothes.getStringPriceWithUnit(selectedClothes)
    }
    
    internal override func buildContentView(){
        if pdt == nil{
            return
        }
        
        contentView.frame = CGRectMake(0, frame.size.height * 22, frame.size.width, frame.size.height * 0.78)
        closeBtn.frame = CGRectMake(23, 45, 30, 30)
        
        let titleLabel = UILabel()
        setBlackStyle(titleLabel, text: DJStringUtil.localize("Item You May Want", comment:""))
        contentView.addSubview(titleLabel)
        constrain(titleLabel) { titleLabel in
            titleLabel.top == titleLabel.superview!.top + 47
            titleLabel.centerX == titleLabel.superview!.centerX
        }
        
        let line = UIView(frame: CGRectMake(23, 80, self.frame.size.width - 23 * 2, 1))
        line.backgroundColor = UIColor.defaultBlack()
        contentView.addSubview(line)
        
        mainImageV.frame = CGRectMake(23, CGRectGetMaxY(line.frame) + 20, 150 * kIphoneSizeScale, 200 * kIphoneSizeScale)
        setImageViewStyle(mainImageV)
        contentView.addSubview(mainImageV)
        
        let oX = CGRectGetMaxX(mainImageV.frame)
        let infoView = UIView(frame: CGRectMake(oX + 20, mainImageV.frame.origin.y, contentView.frame.size.width - 20 * 2 - oX, mainImageV.frame.size.height))
        buildInfoView(infoView)
        contentView.addSubview(infoView)
        
        let chooseLabel = UILabel(frame: CGRectMake(23, CGRectGetMaxY(mainImageV.frame) + 21, 100, 16))
        setBlackStyle(chooseLabel, text: DJStringUtil.localize("Choose color", comment:""))
        contentView.addSubview(chooseLabel)
        
        let scrollView = UIScrollView(frame: CGRectMake(23, CGRectGetMaxY(chooseLabel.frame) + 14, contentView.frame.size.width - 23 * 2, 65))
        contentView.addSubview(scrollView)
        buildScrollView(scrollView)
        
        var bottom : CGFloat = 35
        if UIDevice.isIPhone5(){
            bottom = 10
        }
        let viewBtn = DJButton(frame: CGRectMake(23, contentView.frame.size.height - bottom - 34, contentView.frame.size.width - 23 * 2, 34))
        contentView.addSubview(viewBtn)
        viewBtn.blackTitleWhiteStyle()
        viewBtn.setTitle(DJStringUtil.localize("View Detail", comment:""), forState: .Normal)
        viewBtn.addTarget(self, action: #selector(ClothMultiColorsView.ViewBtnDidClicked), forControlEvents: .TouchUpInside)
    }
    
    func ViewBtnDidClicked(){
        delegate?.clothMultiColorsViewDidChooseProduct(self, selectedClothes : selectedClothes)
    }
    
    func didSelectColorBtn(btn : UIButton){
        btn.addSubview(selectorView)
        
        if let oneCloth = btn.property as? Clothes{
            selectedClothes = oneCloth
            refreshView()
        }
        DJStatisticsLogic.instance().addTraceLog(.Pricetagmiddlepage_Click_Color)
    }
    
    private func buildScrollView(scrollView : UIScrollView){
        let btnWidth : CGFloat = 56
        let btnHeight : CGFloat = 65
        selectorView.frame = CGRectMake(0, 0, btnWidth, btnHeight)
        selectorView.layer.borderColor = UIColor.defaultRed().CGColor
        selectorView.layer.borderWidth = 1.5
        
        let innerIV = UIImageView(frame: CGRectMake(btnWidth - 15, btnHeight - 15, 15, 15))
        innerIV.image = UIImage(named: "FilterSelectedIcon")
        selectorView.addSubview(innerIV)
        
        var oX : CGFloat = 0
        for (_, onePdt) in pdt.enumerate(){
            let btn = UIButton(frame: CGRectMake(oX, 0, btnWidth + 0.5, btnHeight))
            scrollView.addSubview(btn)
            btn.property = onePdt
            btn.addTarget(self, action: #selector(ClothMultiColorsView.didSelectColorBtn(_:)), forControlEvents: .TouchUpInside)
            
            let imageV = UIImageView(frame: btn.bounds)
            if let str = onePdt.thumbUrl{
                if let tmp = NSURL(string: str){
                    imageV.sd_setImageWithURL(tmp)
                }
            }
            setImageViewStyle(imageV)
            btn.addSubview(imageV)
            
            if selectedClothes.uniqueID == onePdt.uniqueID{
                btn.addSubview(selectorView)
            }
            
            oX += btnWidth + 10
        }
        
        scrollView.contentSize = CGSizeMake(btnWidth * CGFloat(pdt.count) + 10 * CGFloat(pdt.count - 1), btnHeight)
    }
    
    private func setImageViewStyle(imageV : UIImageView){
        imageV.contentMode = .ScaleAspectFit
        imageV.layer.borderWidth = 0.5
        imageV.layer.borderColor = UIColor(fromHexString: "cecece").CGColor
    }
    
    private func buildInfoView(cView : UIView){
        let nameView = UIView(frame: CGRectMake(0, 0, cView.frame.size.width, 40))
        nameLabel = basciInfoView(DJStringUtil.localize("Name:", comment:""), cView: nameView)
        cView.addSubview(nameView)
        
        let brandView = UIView(frame: CGRectMake(0, CGRectGetMaxY(nameView.frame) + 10, cView.frame.size.width, 40))
        brandLabel = basciInfoView(DJStringUtil.localize("Brand:", comment:""), cView: brandView)
        cView.addSubview(brandView)
        
//        let priceView = UIView(frame: CGRectMake(0, CGRectGetMaxY(brandView.frame) + 10, cView.frame.size.width, 40))
//        priceLabel = basciInfoView("Price:", cView: priceView)
      //  cView.addSubview(priceView)
    }
    
    private func basciInfoView(name : String, cView : UIView) -> UILabel{
        let nameLabel = UILabel()
        nameLabel.withText(name).withTextColor(UIColor.gray81Color()).withFontHeletica(14)
        cView.addSubview(nameLabel)
        constrain(nameLabel) { nameLabel in
            nameLabel.top == nameLabel.superview!.top
            nameLabel.left == nameLabel.superview!.left
            nameLabel.right == nameLabel.superview!.right
        }
        
        let detailLabel = UILabel()
        setBlackStyle(detailLabel, text: "")
        cView.addSubview(detailLabel)
        constrain(detailLabel, nameLabel) { detailLabel, nameLabel in
            detailLabel.top == nameLabel.bottom + 5
            detailLabel.left == detailLabel.superview!.left
            detailLabel.right == detailLabel.superview!.right
        }
        
        return detailLabel
    }
    
    private func setBlackStyle(label : UILabel, text : String?){
        label.withTextColor(UIColor.defaultBlack()).withFontHeleticaMedium(15)
        label.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
