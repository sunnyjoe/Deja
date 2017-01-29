//
//  ScollSelectorView.swift
//  DejaFashion
//
//  Created by jiao qing on 2/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol ScollSelectorViewDelegate : NSObjectProtocol{
    func scollSelectorViewDidDone(scollSelectorView : ScollSelectorView, value : String)
}

class ScollSelectorView: UIView, UIPickerViewDataSource, UIPickerViewDelegate{
    var pData = [String : String]()
    var pDataKey = [String]()
    var selectedRow : Int = 0
    let pickerView = UIPickerView()
    weak var delegate : ScollSelectorViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let funcView = UIView(frame: CGRectMake(0, 0, frame.size.width, 36))
        funcView.backgroundColor = UIColor.whiteColor()
        self.addSubview(funcView)
        
        let cancelBtn = UIButton(frame: CGRectMake(25, 0, 100, funcView.frame.size.height))
        funcView.addSubview(cancelBtn)
        cancelBtn.withFontHeletica(16).withTitle(DJStringUtil.localize("Cancel", comment:"")).withTitleColor(UIColor(fromHexString: "71b0ea"))
        cancelBtn.contentHorizontalAlignment = .Left
        cancelBtn.addTarget(self, action: #selector(ScollSelectorView.cancelBtnDidClicked), forControlEvents: .TouchUpInside)
        
        let doneBtn = UIButton(frame: CGRectMake(funcView.frame.size.width - 100 - 25, 0, 100, funcView.frame.size.height))
        funcView.addSubview(doneBtn)
        doneBtn.withFontHeletica(16).withTitle(DJStringUtil.localize("Done", comment:"")).withTitleColor(UIColor(fromHexString: "71b0ea"))
        doneBtn.contentHorizontalAlignment = .Right
        doneBtn.addTarget(self, action: #selector(ScollSelectorView.doneBtnDidClicked), forControlEvents: .TouchUpInside)
        
        
        pickerView.frame = CGRectMake(0, 36, frame.size.width, 222)
        pickerView.backgroundColor = UIColor(fromHexString: "f9f9f9")
        self.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let orgData = ConfigDataContainer.sharedInstance.getCountryCodeDic()
        let orgKeys = orgData.allKeys as! [String]
        
        for oneKey in orgKeys {
            if let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: oneKey){
                let dic = orgData[oneKey] as! NSDictionary
                pData[countryName] = String(dic["CountryCallingCode"]!)
            }
        }
        pDataKey = Array(pData.keys)
        pDataKey = pDataKey.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
    }
    
    
    func setSelectedCountryCode(countryCode : String) {
        for row in 0..<pDataKey.count {
            let name = pDataKey[row]
            let code = pData[name]
            if code == countryCode {
                pickerView.selectRow(row, inComponent: 0, animated: false)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelBtnDidClicked(){
        hideAnimate()
    }
    
    func hideAnimate(){
        UIView.animateWithDuration(0.2, animations: {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height)
            }, completion: { (completion : Bool) -> Void in
                self.removeFromSuperview()
        })
    }
    
    func doneBtnDidClicked(){
        hideAnimate()
        
        let name = pDataKey[selectedRow]
        if let cCode = pData[name] {
            delegate?.scollSelectorViewDidDone(self, value: cCode)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pDataKey.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 31
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var reuseView = view;
        if reuseView == nil {
            reuseView = UIView()
        }
        reuseView?.removeAllSubViews()
        
        let countryCodeLabel = UILabel()
        let countryNameLabel = UILabel()
        reuseView?.addSubviews(countryCodeLabel, countryNameLabel)
        
        constrain(countryCodeLabel, countryNameLabel) { label1, label2 in
            label1.left == label1.superview!.left
            label1.top == label1.superview!.top
            label2.right == label2.superview!.right
            label2.top == label2.superview!.top
            
            label1.width == label1.superview!.width * 135 / 375
            label2.left == label1.right + 23
        }
        
        countryCodeLabel.textAlignment = .Right
        countryCodeLabel.withFontHeletica(22).withTextColor(UIColor.defaultBlack())
        countryNameLabel.textAlignment = .Left
        countryNameLabel.withFontHeletica(22).withTextColor(UIColor.defaultBlack())
        
        let countryName = pDataKey[row]
        if let countryCode = pData[countryName] {
            countryCodeLabel.text = "+" + countryCode
        }
        countryNameLabel.text = countryName
        
        return reuseView!
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let tmp = super.hitTest(point, withEvent: event)
        if tmp == nil {
            hideAnimate()
            return self
        }else{
            return tmp
        }
    }
}

