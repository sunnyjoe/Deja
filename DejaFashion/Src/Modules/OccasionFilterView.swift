//
//  OccasionFilterView.swift
//  DejaFashion
//
//  Created by DanyChen on 19/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//
import UIKit

@objc  protocol OccasionFilterViewDelegate : NSObjectProtocol{
    func refineViewDone(refineView : OccasionFilterView)
}

class OccasionFilterView: UIView {
    
    var filterConditions = [FilterCondition]()
    
    var selectedFilters = [Filter]()
    
    weak var delegate : OccasionFilterViewDelegate?
    
    var containerView : UIView?
    
    var scrollView = UIScrollView()
    
    let funcView = UIView()
    
    var occasionIconViews = [UIView]()
    
    var nothingChangeAfterPoped = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterConditions = ConfigDataContainer.sharedInstance.getConfigStyleCategory()
        
        self.addTapGestureTarget(self, action: #selector(OccasionFilterView.backgroundViewDidTapped))
        
        containerView = UIView(frame: CGRectMake(0, 98, self.frame.size.width, frame.height - 98))
        containerView?.backgroundColor = UIColor.whiteColor()
        addSubview(containerView!)
        containerView!.addSubview(funcView)
        containerView?.userInteractionEnabled = true
        containerView!.addTapGestureTarget(self, action: #selector(OccasionFilterView.doNoting))
        
        let header = getViewHeader()
        containerView?.addSubview(header)
        
        funcView.frame = CGRectMake(23, containerView!.frame.height - 60, containerView!.frame.size.width - 46, 60)
        let btnWidth : CGFloat = frame.width - 46
        let doneBtn = DJButton(frame: CGRectMake(0, 12, btnWidth, 36))
        doneBtn.setWhiteTitle()
        doneBtn.withTitle(DJStringUtil.localize("DONE", comment:""))
        doneBtn.addTarget(self, action: #selector(OccasionFilterView.doneBtnDidTap), forControlEvents: UIControlEvents.TouchUpInside)
        funcView.addSubview(doneBtn)
        
        scrollView.frame = CGRect(x: 12, y: header.frame.height, width: frame.width - 24, height: containerView!.frame.height - header.frame.height - 60)
        containerView?.addSubview(scrollView)
        var yOffset = 0.0 as CGFloat
        let itemWidth = (scrollView.frame.width) / 4.0 as CGFloat
        let imageWidth = (frame.width - 66 - 46) / 4.0 as CGFloat
        let labelHeight = 42 as CGFloat
        for (i, condition) in filterConditions.enumerate() {
            let nameLabel = UILabel(frame: CGRectMake(11, yOffset, frame.width, 45))
            nameLabel.withFontHeleticaMedium(16).withTextColor(UIColor.defaultBlack()).withText(condition.name)
            nameLabel.textAlignment = .Left
            scrollView.addSubview(nameLabel)
            yOffset += nameLabel.frame.height
            var xOffset = 0.0 as CGFloat
            for (j, filter) in condition.values.enumerate() {
                
                if j > 0 && j % 4 == 0 {
                    xOffset = 0.0
                    yOffset += imageWidth + labelHeight
                }
                
                let imageView = UIImageView(frame: CGRect(x: 11, y: 0, width: imageWidth, height: imageWidth))
                imageView.layer.borderColor = DJCommonStyle.DividerColor.CGColor
                imageView.layer.borderWidth = 1
                if let icon = filter.icon {
                    if let url = NSURL(string: icon) {
                        imageView.sd_setImageWithURL(url)
                    }
                }
                
                let item = UIView(frame: CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemWidth + labelHeight))
                item.addSubview(imageView)
                let label = UILabel(frame: CGRectMake(0,  imageWidth, itemWidth, labelHeight))
                label.withFontHeletica(14).withTextColor(UIColor.defaultBlack()).withText(filter.name).textCentered()
                label.numberOfLines = 0
                item.addSubview(label)
                
                occasionIconViews.append(imageView)
                
                imageView.addTapGestureTarget(self, action: #selector(OccasionFilterView.tapImage(_:)))
                imageView.property = filter
                
                xOffset += item.frame.width
                scrollView.addSubview(item)
            }
            yOffset += imageWidth + labelHeight
            
            if i < filterConditions.count - 1 {
                let divider = UIView(frame: CGRect(x: 11, y: yOffset, width: scrollView.frame.width - 22, height: 1))
                divider.backgroundColor = DJCommonStyle.DividerColor
                scrollView.addSubview(divider)
            }
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yOffset)
    }
    
    func tapImage(reg: UITapGestureRecognizer) {
        self.nothingChangeAfterPoped = false
        
        if let filter = reg.view?.property as? Filter {
            let originSelectedFilter = selectedFilters.first
            selectedFilters.removeAll()
            for v in occasionIconViews {
                if let f = v.property as? Filter{
                    if f.id == filter.id {
                        if originSelectedFilter?.id == filter.id {
                            v.layer.borderColor = DJCommonStyle.DividerColor.CGColor
                        }else {
                            v.layer.borderColor = DJCommonStyle.ColorRed.CGColor
                            selectedFilters.append(filter)
                        }
                    }else {
                        v.layer.borderColor = DJCommonStyle.DividerColor.CGColor
                    }
                }
            }
        }
    }
    
    func backgroundViewDidTapped(){
        self.hideAnimation()
    }
    
    func getViewHeader() -> UIView{
        let hView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, 50))
        
        let nameLabel = UILabel(frame: CGRectMake(23, 0, frame.size.width - 46, 49))
        nameLabel.withFontHeleticaBold(15).withTextColor(UIColor.defaultBlack()).withText(DJStringUtil.localize("OCCASIONS", comment:""))
        nameLabel.textAlignment = .Left
        hView.addSubview(nameLabel)
        
        let border = UIView(frame: CGRectMake(23, hView.frame.size.height - 1, hView.frame.size.width - 46, 1))
        border.backgroundColor = UIColor(fromHexString: "272629")
        hView.addSubview(border)
        return hView;
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func containerViewHiddenFrame() -> CGRect{
        return CGRectMake(0, containerView!.frame.size.height, containerView!.frame.size.width, containerView!.frame.size.height)
    }
    
    func showAnimation(){
        self.hidden = false
        self.nothingChangeAfterPoped = true
        let tmp = containerView!.frame
        self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0)
        containerView!.frame = containerViewHiddenFrame()
        UIView.animateWithDuration(0.3, animations: {
            self.containerView!.frame = tmp
            self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.75)
            }, completion:  nil)
    }
    
    func hideAnimation(){
        let tmp = containerView!.frame
        let ret = containerViewHiddenFrame()
        UIView.animateWithDuration(0.3, animations: {
            self.containerView!.frame = ret
            self.backgroundColor = UIColor(fromHexString: "262729", alpha: 0)
            }, completion: { (completion : Bool) -> Void in
                self.containerView!.frame = tmp
                self.hidden = true
        })
    }
    
    func doneBtnDidTap(){
        if nothingChangeAfterPoped {
            hideAnimation()
        }else {
            delegate?.refineViewDone(self)
        }
    }
    
    func doNoting(){
    }
    
    func resetSelectedFilters(newfilters : [Filter]){
        selectedFilters.removeAll()
        for v in occasionIconViews {
            v.layer.borderColor = DJCommonStyle.DividerColor.CGColor
            if let f = v.property as? Filter{
                if let filter = newfilters.first {
                    if f.id == filter.id {
                        v.layer.borderColor = DJCommonStyle.ColorRed.CGColor
                        selectedFilters.append(f)
                    }
                }
            }
        }
        
    }
    
}
