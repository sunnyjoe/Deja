//
//  SuggestionView.swift
//  DejaFashion
//
//  Created by jiao qing on 17/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit


enum ReportStatus {
    case Start
    case Loading
    case Done
}

protocol SuggestionViewDelegate : NSObjectProtocol{
    func suggestionViewReportDidClickSubmit(suggestionView: SuggestionView)
    func suggestionViewTakePhotoDidClick(suggestionView: SuggestionView)
}

class SuggestionView: UIView, UITextViewDelegate {
    weak var delegate: SuggestionViewDelegate?
    
    var reportStatus = ReportStatus.Start
    private let takePhotoBtn = UIButton()
    private let imageBtn = UIButton()
    private let reportBtn = DJButton()
    private let contentView = UIView()
    let textView = UITextView()
    var image : UIImage?
    
    private let indicator = UIActivityIndicatorView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        contentView.frame = CGRectMake(frame.size.width / 2 - 130, 100, 260, 246)
        contentView.backgroundColor = UIColor(fromHexString: "000000", alpha: 0.9)
        self.addSubview(contentView)
        
        let firstLabel = UILabel(frame: CGRectMake(0, 20, 100, 20))
        contentView.addSubview(firstLabel)
        firstLabel.withFontHeleticaMedium(15).withTextColor(UIColor(fromHexString: "eaeaea")).withText(DJStringUtil.localize("Tell us what you are looking for", comment:""))
        firstLabel.sizeToFit()
        firstLabel.frame = CGRectMake(contentView.frame.size.width / 2 - firstLabel.frame.size.width / 2, 20, firstLabel.frame.size.width, firstLabel.frame.size.height)
        
        let lineView = UIView(frame: CGRectMake(21, CGRectGetMaxY(firstLabel.frame) + 17, contentView.frame.size.width - 42, 1.5))
        lineView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(lineView)
        
        let secondLabel = UILabel(frame: CGRectMake(21, CGRectGetMaxY(lineView.frame) + 10, contentView.frame.size.width - 23 - 45, 47))
        contentView.addSubview(secondLabel)
        secondLabel.numberOfLines = 0
        secondLabel.withFontHeletica(12).withTextColor(UIColor(fromHexString: "eaeaea")).withText(DJStringUtil.localize("Take a photo or write description below:", comment:""))
        secondLabel.sizeToFit()
        
        takePhotoBtn.frame = CGRectMake(contentView.frame.size.width - 21 - 23, CGRectGetMaxY(lineView.frame) + 13, 23, 20)
        contentView.addSubview(takePhotoBtn)
        takePhotoBtn.setImage(UIImage(named: "CameraIcon"), forState: .Normal)
        takePhotoBtn.addTarget(self, action: #selector(SuggestionView.takePhotoDidClick), forControlEvents: .TouchUpInside)
        
        imageBtn.frame = CGRectMake(contentView.frame.size.width - 21 - 32, lineView.frame.origin.y + 8, 32, 32)
        contentView.addSubview(imageBtn)
        imageBtn.addTarget(self, action: #selector(SuggestionView.takePhotoDidClick), forControlEvents: .TouchUpInside)
        imageBtn.hidden = true
        
        textView.frame = CGRectMake(21, CGRectGetMaxY(lineView.frame) + 48, contentView.frame.size.width - 42, 76)
        textView.returnKeyType = .Done
        textView.delegate = self
        contentView.addSubview(textView)
        textView.font = DJFont.helveticaFontOfSize(14)
        
        let btnWidth = (contentView.frame.size.width - 42 - 10) / 2
        
        let cancelBtn = DJButton(frame : CGRectMake(21, CGRectGetMaxY(textView.frame) + 15, btnWidth, 32))
        contentView.addSubview(cancelBtn)
        cancelBtn.withTitle(DJStringUtil.localize("Cancel", comment:""))
        cancelBtn.cornerRadius(16).setWhiteTitle()
        cancelBtn.layer.borderColor = UIColor.whiteColor().CGColor
        cancelBtn.layer.borderWidth = 1;
        cancelBtn.addTarget(self, action: #selector(SuggestionView.cancelBtnDidClick), forControlEvents: .TouchUpInside)
        
        reportBtn.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame) + 10, CGRectGetMaxY(textView.frame) + 15, btnWidth, 32)
        contentView.addSubview(reportBtn)
        reportBtn.withTitle(DJStringUtil.localize("Submit", comment:""))
        reportBtn.cornerRadius(16).setWhiteTitle()
        reportBtn.setBackgroundImage(UIImage(color: UIColor.blackColor()), forState: .Disabled)
        reportBtn.layer.borderWidth = 1;
        reportBtn.addTarget(self, action: #selector(SuggestionView.reportBtnDidClick), forControlEvents: .TouchUpInside)
        reportBtn.enabled = false
        setSubmitBtnState(false)
        
        indicator.frame = reportBtn.bounds
        indicator.contentMode = .Center
    }
    
    func setSelectedImage(img: UIImage){
        image = img
        imageBtn.hidden = false
        imageBtn.setImage(image, forState: .Normal)
        
        reportBtn.enabled = true
        setSubmitBtnState(true)
    }
    
    func reportBtnDidClick(){
        reportBtn.withTitle("")
        reportBtn.addSubview(indicator)
        indicator.startAnimating()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            self.delegate?.suggestionViewReportDidClickSubmit(self)
            self.indicator.stopAnimating()
        }
    }
    
    func cancelBtnDidClick(){
        removeAnimation()
    }
    
    func removeAnimation(){
        UIView.animateWithDuration(0.2, animations: {
            self.alpha = 0
            }, completion: { (completion : Bool) -> Void in
                self.removeFromSuperview()
                self.alpha = 1
        })
    }
    
    func takePhotoDidClick(){
        self.delegate!.suggestionViewTakePhotoDidClick(self)
    }
    
    func setSubmitBtnState(enabled : Bool){
        if enabled {
            reportBtn.withTitleColor(UIColor(fromHexString: "ffffff"))
            reportBtn.layer.borderColor = UIColor(fromHexString: "ffffff").CGColor
        }else{
            reportBtn.withTitleColor(UIColor(fromHexString: "4f4f4f"))
            reportBtn.layer.borderColor = UIColor(fromHexString: "4f4f4f").CGColor
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let trimmedString =  textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedString.characters.count > 0 {
            reportBtn.enabled = true
            setSubmitBtnState(true)
        }else{
            if image == nil {
                reportBtn.enabled = false
                setSubmitBtnState(false)
            }
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
