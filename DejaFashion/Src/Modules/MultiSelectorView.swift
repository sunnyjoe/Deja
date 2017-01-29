//
//  MultiSelectorView.swift
//  DejaFashion
//
//  Created by jiao qing on 15/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

@objc protocol MultiSelectorViewDelegate {
    func multiSelectorViewValueDidChanged(multiSelectorView: MultiSelectorView, value: String)
}

class MultiSelectorView: UIView {
    weak var delegate : MultiSelectorViewDelegate?
    
    internal var rangeValues: [String] {
        get{
            return self.rangeData
        }
        set(newRangeData){
            rangeData = newRangeData
            realValue = rangeData[0]
            self.buildSelectorView()
        }
    }
    
    internal var setInfoValues: [String] {
        get{
            return self.infoValues
        }
        set(newData){
            infoValues = newData
            infoValue = infoValues[0]
        }
    }
    private var rangeData = [String]()
    
    private var infoValues = [String]()
    private var selectorView = UIView()
    
    var infoLabel = UILabel()
    private var titleLabel = UILabel()
    private var valueLabel = UILabel()
    
    var realValue : String = ""
    private var infoValue : String = ""
    var wholeWidth : CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        titleLabel.withFontHeletica(15).withTextColor(UIColor(fromHexString: "414141"))
        titleLabel.textAlignment = .Center
        
        valueLabel.withFontHeletica(13).withTextColor(UIColor(fromHexString: "b5b6b7"))
        valueLabel.textAlignment = .Center
        
        addSubview(infoLabel)
        infoLabel.withFontHeletica(13).withTextColor(UIColor(fromHexString: "b5b6b7"))
        infoLabel.textAlignment = .Center
        
        addSubview(selectorView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectorView.frame = CGRectMake(0, frame.size.height / 2 - 16 / 2, self.frame.size.width, 40)
        infoLabel.frame = CGRectMake(0, CGRectGetMaxY(selectorView.frame), self.frame.size.width, 16)
        
        buildSelectorView()
        resetTitleFrame()
    }
    
    func setTitle(title : String){
        titleLabel.withText(title)
        
        resetTitleFrame()
    }
    
    func resetTitleFrame(){
        //  valueLabel.withText("(\(realValue.uppercaseString))")
        
        titleLabel.sizeToFit()
        valueLabel.sizeToFit()
        let totalWidth = titleLabel.frame.size.width + valueLabel.frame.size.width + 2
        titleLabel.frame = CGRectMake(frame.size.width / 2 - totalWidth / 2, CGRectGetMinY(selectorView.frame) - titleLabel.frame.size.height, titleLabel.frame.size.width, titleLabel.frame.size.height)
        valueLabel.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame) + 2, CGRectGetMinY(selectorView.frame) - valueLabel.frame.size.height, valueLabel.frame.size.width, valueLabel.frame.size.height)
    }
    
    func buildSelectorView(){
        if rangeData.count <= 1 {
            return
        }
        
        if selectorView.subviews.count == 0{
            for data in rangeData{
                let one = OneSelectorButton()
                let size = one.setName(data)
                one.setSelfSelected(false)
                one.frame = CGRectMake(0, 0, size.width, size.height)
                selectorView.addSubview(one)
                one.addTarget(self, action: #selector(MultiSelectorView.oneSelectorDidClicked(_:)), forControlEvents: .TouchUpInside)
                
                wholeWidth += size.width
            }
        }
        
        let space = (selectorView.frame.size.width - wholeWidth - 12) / CGFloat(rangeData.count + 1)
        var oX = space + 6
        for index in 0  ..< selectorView.subviews.count {
            let sub = selectorView.subviews[index]
            sub.frame = CGRectMake(oX, 0, sub.frame.size.width, sub.frame.size.height)
            oX = CGRectGetMaxX(sub.frame) + space
        }
    }
    
    func setSelectorWithInitValue(theRealValue: String){
        realValue = theRealValue
        for index in 0  ..< selectorView.subviews.count {
            let sub = selectorView.subviews[index] as! OneSelectorButton
            if theRealValue.uppercaseString == sub.nameLabel.text!.uppercaseString{
                sub.setSelfSelected(true)
                infoLabel.text = infoValues[index]
            }else{
                sub.setSelfSelected(false)
            }
        }
        resetTitleFrame()
    }
    
    func oneSelectorDidClicked(btn: UIButton){
        for index in 0  ..< selectorView.subviews.count {
            let sub = selectorView.subviews[index] as! OneSelectorButton
            if sub == btn{
                sub.setSelfSelected(true)
                realValue = rangeData[index]
                infoLabel.text = infoValues[index]
            }else{
                sub.setSelfSelected(false)
            }
        }
        resetTitleFrame()
        delegate?.multiSelectorViewValueDidChanged(self, value: realValue)
    }
}

class OneSelectorButton: UIButton {
    let dotView = UIImageView()
    let cicleView = UIImageView()
    let nameLabel = UILabel()
    
    let circleSize : CGFloat = 12
    let dotSize : CGFloat = 7
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cicleView.layer.borderWidth = 1
        cicleView.layer.cornerRadius = circleSize / 2
        addSubview(cicleView)
        cicleView.addSubview(dotView)
        dotView.layer.cornerRadius = dotSize / 2
        dotView.backgroundColor = UIColor(fromHexString: "414141")
        addSubview(nameLabel)
        
        nameLabel.userInteractionEnabled = false
        nameLabel.text = ""
        nameLabel.numberOfLines = 1
        nameLabel.withFontHeletica(14)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cicleView.frame = CGRectMake(10, frame.size.height / 2 - circleSize / 2, circleSize, circleSize)
        dotView.frame = CGRectMake(circleSize / 2 - dotSize / 2, circleSize / 2 - dotSize / 2, dotSize, dotSize)
        nameLabel.frame = CGRectMake(CGRectGetMaxX(cicleView.frame) + 5, 0, nameLabel.frame.size.width + 10, frame.size.height)
    }
    
    func setName(name : String) -> CGSize{
        nameLabel.withText(name)
        nameLabel.sizeToFit()
        
        let width = circleSize + 5 + nameLabel.frame.size.width + 20
        return CGSizeMake(width, nameLabel.frame.size.height + 26)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setSelfSelected(selected : Bool){
        var color = UIColor(fromHexString: "b5b6b7")
        if selected{
            color = UIColor(fromHexString: "414141")
        }
        cicleView.layer.borderColor = color.CGColor
        dotView.hidden = !selected
        nameLabel.withTextColor(color)
    }
}
