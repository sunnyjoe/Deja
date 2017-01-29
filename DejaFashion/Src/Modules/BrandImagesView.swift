//
//  BrandImagesView.swift
//  DejaFashion
//
//  Created by jiao qing on 3/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class BrandImagesView: UIView {
    private weak var selectTarget : AnyObject?
    private var selectSelector : Selector?
  
    private var tmpFrame = CGRectZero
    private var frameHeight : CGFloat = 0
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        tmpFrame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBrandList(brandList : [BrandInfo], fullWidth : CGFloat){
        tmpFrame.size.width = fullWidth
        
        let width = (fullWidth - 5 * 3) / 4
        
        var oX : CGFloat = 0
        var oY : CGFloat = 0
        
        var lastV : UIView?
        for index in 0 ..< brandList.count{
            let brand = brandList[index]
            
            let imageBtn = BrandButton(frame: CGRectMake(oX, oY, width, 30))
            lastV = imageBtn
            imageBtn.setBackgroundColor(UIColor.whiteColor(), forState: .Highlighted)
            imageBtn.brand = brand
            if let tmpSel = selectSelector{
                imageBtn.addTarget(selectTarget, action: tmpSel, forControlEvents: .TouchUpInside)
            }
            imageBtn.layer.borderWidth = 0.5
            imageBtn.layer.borderColor = UIColor(fromHexString: "cecece").CGColor
            addSubview(imageBtn)
            imageBtn.imageView?.contentMode = .ScaleAspectFit
           // let bIV = UIImageView(frame: imageBtn.bounds)
           // bIV.contentMode = .ScaleAspectFit
            if let url = NSURL(string: brand.imageUrl){
                imageBtn.sd_setImageWithURL(url, forState: .Normal)
               // bIV.sd_setImageWithURL(url)
            }
           // imageBtn.addSubview(bIV)
            
            oX += width + 5
            if oX > fullWidth{
                oX = 0
                oY += imageBtn.frame.size.height + 5
            }
        }
        
        if lastV != nil{
            frameHeight = CGRectGetMaxY(lastV!.frame)
        }
    }
    
    func frameToFit(){
        frame = CGRectMake(tmpFrame.origin.x, tmpFrame.origin.y, tmpFrame.size.width, frameHeight)
    }
    
    func setImageClickSelector(target : AnyObject, sel : Selector){
        selectTarget = target
        selectSelector = sel
    }
    
    
}
