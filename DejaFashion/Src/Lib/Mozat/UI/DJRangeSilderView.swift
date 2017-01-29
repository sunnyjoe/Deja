//
//  DJRangeSilderView.swift
//  DejaFashion
//
//  Created by jiao qing on 2/11/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

@objc protocol DJRangeSilderViewDelegate {
    func rangeValueDidChanged(rangeSliderView: DJRangeSilderView, lowerValue: CGFloat, higherValue: CGFloat)
}

class DJRangeSilderView: UIView {
    static let DJRangePointerSize : CGFloat = 25.5
    static let DJRangeSliderHeight : CGFloat = 1
    static let DJRangeDotSize : CGFloat = 6.5
    static let DJMaxPrice : CGFloat = 0
    
    weak var delegate : DJRangeSilderViewDelegate?
    internal var rangeValues: [CGFloat] {
        get{
            return self.rangeData
        }
        set(newRangeData){
            rangeData = newRangeData
            leftRealValue = rangeData[0]
            rightRealValue = DJRangeSilderView.DJMaxPrice
            self.layoutSliderDots()
        }
    }
    
    private var rangeData = [CGFloat]()
    private var dotDistance: CGFloat = 10.0
    private var dataLabelView = UIView()
    
    private var rightThumb = UIImageView()
    private var leftThumb = UIImageView()
    private var leftPanGesture = UIPanGestureRecognizer()
    private var rightPanGesture = UIPanGestureRecognizer()
    private var slider = UIImageView()
    
    private var rangeMaskView = UIView()
    private var rangeSliderView = UIImageView()
    private var rangeView = UIImageView()
    
    private var leftPercentage: CGFloat = 0.0
    private var rightPercentage: CGFloat = 0.0
    
    private var leftRealValue: CGFloat = 0.0
    private var rightRealValue: CGFloat = DJRangeSilderView.DJMaxPrice
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(){
        leftPercentage = 0
        rightPercentage = 1
        
        self.addSubview(dataLabelView)
        
        slider.backgroundColor = UIColor.gray81Color()
        slider.userInteractionEnabled = true
        self.addSubview(slider)
        
        rangeView.clipsToBounds = true
        self.addSubview(rangeView)
        
        rangeSliderView.backgroundColor = UIColor(fromHexString: "f81f34")
        rangeView.addSubview(rangeSliderView)
        rangeView.addSubview(rangeMaskView)
        
        leftThumb.image = UIImage(named: "FilterPrice")
        leftThumb.userInteractionEnabled = true
        self.addSubview(leftThumb)
        leftPanGesture.addTarget(self, action:#selector(DJRangeSilderView.handlePanGesture(_:)))
        leftThumb.addGestureRecognizer(leftPanGesture)
        
        rightThumb.image = UIImage(named: "FilterPrice")
        rightThumb.userInteractionEnabled = true
        self.addSubview(rightThumb)
        rightPanGesture.addTarget(self, action:#selector(DJRangeSilderView.handlePanGesture(_:)))
        rightThumb.addGestureRecognizer(rightPanGesture)
        
        addTapGestureTarget(self, action: #selector(DJRangeSilderView.handleTap(_:)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dataLabelView.frame = CGRectMake(20, 0, self.frame.size.width - 40, 11)
        slider.frame = CGRectMake(20, 33.5, self.frame.size.width - 40, DJRangeSilderView.DJRangeSliderHeight)
        
        let oX = leftPercentage * self.slider.frame.size.width + self.slider.frame.origin.x
        let width = (rightPercentage - leftPercentage) * self.slider.frame.size.width
        
        rangeView.frame = CGRectMake(oX, slider.frame.origin.y - DJRangeSilderView.DJRangeDotSize, width, DJRangeSilderView.DJRangeDotSize + DJRangeSilderView.DJRangeSliderHeight)
        rangeSliderView.frame = CGRectMake(0, DJRangeSilderView.DJRangeDotSize, rangeView.frame.size.width, DJRangeSilderView.DJRangeSliderHeight)
        
        rangeMaskView.frame = CGRectMake(slider.frame.origin.x - rangeView.frame.origin.x, 0, slider.frame.size.width, rangeView.frame.size.height)
        self.layoutSliderDots()
        
        leftThumb.frame = CGRectMake(oX - DJRangeSilderView.DJRangePointerSize / 2, slider.frame.origin.y + DJRangeSilderView.DJRangeSliderHeight / 2 - DJRangeSilderView.DJRangePointerSize / 2, DJRangeSilderView.DJRangePointerSize, DJRangeSilderView.DJRangePointerSize)
        rightThumb.frame = CGRectMake(CGRectGetMaxX(rangeView.frame) - DJRangeSilderView.DJRangePointerSize / 2, leftThumb.frame.origin.y, DJRangeSilderView.DJRangePointerSize, DJRangeSilderView.DJRangePointerSize)
    }
    
    func layoutSliderDots(){
        if rangeData.count < 2 {
            return
        }
        
        dataLabelView.removeAllSubViews()
        slider.removeAllSubViews()
        rangeMaskView.removeAllSubViews()
        
        var oX: CGFloat = 0;
        dotDistance = slider.frame.size.width / CGFloat(rangeData.count)
        
        var cnt = 0
        while cnt <= rangeData.count {
            var rangeValue : CGFloat = 0
            let dataLabel = UILabel()
            dataLabelView.addSubview(dataLabel)
            dataLabel.textColor = UIColor(fromHexString: "cecece")
            dataLabel.font = DJFont.helveticaFontOfSize(14)
            
            let sliderDot = UIImageView(frame: CGRectMake(oX, -DJRangeSilderView.DJRangeDotSize, DJRangeSilderView.DJRangeSliderHeight, DJRangeSilderView.DJRangeDotSize))
            sliderDot.backgroundColor = UIColor.gray81Color()
            slider.addSubview(sliderDot)
            
            if cnt < rangeData.count {
                rangeValue = rangeData[cnt]
                dataLabel.text = NSString(format: "%.0f", rangeValue) as String
            }else{
                rangeValue = rangeData[rangeData.count - 1]
                dataLabel.text = NSString(format: "%.0f+", rangeValue) as String
                sliderDot.frame = CGRectMake(oX - 1.5, -DJRangeSilderView.DJRangeDotSize, DJRangeSilderView.DJRangeSliderHeight, DJRangeSilderView.DJRangeDotSize)
            }
            dataLabel.sizeToFit()
            dataLabel.frame = CGRectMake(oX - dataLabel.frame.size.width / 2 + DJRangeSilderView.DJRangeSliderHeight, 4, dataLabel.frame.size.width, dataLabel.frame.size.height)
            
            let rangDot = UIImageView(frame: CGRectMake(oX, 0, DJRangeSilderView.DJRangeSliderHeight, DJRangeSilderView.DJRangeDotSize))
            rangDot.backgroundColor = UIColor(fromHexString: "f81f34")
            rangeMaskView.addSubview(rangDot)
            
            oX += dotDistance
            cnt += 1
        }
    }
    
    func resetSlider(){
        leftRealValue = rangeData[0]
        rightRealValue = DJRangeSilderView.DJMaxPrice
        
        leftPercentage = 0
        rightPercentage = 1
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func startPointsSlider(leftValue: CGFloat, rightValue: CGFloat){
        leftRealValue = leftValue
        rightRealValue = rightValue
        
        leftPercentage = self.getPercentage(leftRealValue)
        if rightRealValue == DJRangeSilderView.DJMaxPrice {//max higher price
            rightPercentage = 1
        }else{
            rightPercentage = self.getPercentage(rightRealValue)
        }
        
        if leftPercentage > rightPercentage {
            leftPercentage = rightPercentage
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func getPercentage(theRealValue: CGFloat) -> CGFloat{
        if rangeData.count < 2 {
            return 0
        }
        
        var index = 0
        var tmpLeft = rangeData[0]
        while tmpLeft < theRealValue && index < rangeData.count - 1 {
            index = index + 1
            tmpLeft = rangeData[index]
        }
        return CGFloat(index) / CGFloat(rangeData.count)
    }
    
    func handleTap(gesture : UITapGestureRecognizer) {
        _Log("------------")
        _Log(gesture.locationInView(self).x.description)
        _Log(gesture.locationInView(self).y.description)
        var index = (Int)((gesture.locationInView(self).x - slider.frame.origin.x) / dotDistance);
        _Log(index.description)
        let remain = (gesture.locationInView(self).x - slider.frame.origin.x) % dotDistance
        
        if remain >= dotDistance / 2 {
            index += 1
        }
        var pointerValue = 0.0 as CGFloat
        if index < rangeData.count {
            pointerValue =  rangeData[index]
        }else{
            pointerValue = DJRangeSilderView.DJMaxPrice
        }
        
        let percentage = CGFloat(index) / CGFloat(rangeData.count)
        
        if abs(percentage - leftPercentage) < abs(percentage - rightPercentage) {
            leftPercentage = percentage
            leftRealValue = pointerValue
        }else {
            rightPercentage = percentage
            rightRealValue = pointerValue
        }
        delegate?.rangeValueDidChanged(self, lowerValue: leftRealValue, higherValue: rightRealValue)

        setNeedsLayout()
    }
    
    func handlePanGesture(gesture: UIPanGestureRecognizer){
        if gesture.state != UIGestureRecognizerState.Changed && gesture.state != UIGestureRecognizerState.Began && gesture.state != UIGestureRecognizerState.Ended{
            return
        }
        
        var location = gesture.locationInView(self)
        var outside = false
        if location.x < 0 || location.x > self.frame.size.width || location.y < 0 || location.y > self.frame.size.height {
            outside = true
        }
        
        if location.x < slider.frame.origin.x {
            location.x = slider.frame.origin.x
        }
        if location.x > CGRectGetMaxX(slider.frame){
            location.x = CGRectGetMaxX(slider.frame)
        }
        var percentage = (location.x - slider.frame.origin.x) / slider.frame.size.width;
        var pointerValue: CGFloat = 0
        
        if gesture.state != UIGestureRecognizerState.Ended && !outside {
            if gesture == leftPanGesture {
                self.addSubview(leftThumb)
                if percentage > rightPercentage {
                    leftPercentage = rightPercentage - 1 / CGFloat(rangeData.count)
                    if leftPercentage < 0 {
                        leftPercentage = 0
                    }
                }else{
                    leftPercentage = percentage
                }
            }else if gesture == rightPanGesture {
                self.addSubview(rightThumb)
                if percentage < leftPercentage {
                    rightPercentage = leftPercentage + 1 / CGFloat(rangeData.count)
                    if rightPercentage > 1 {
                        rightPercentage = 1
                    }
                }else{
                    rightPercentage = percentage
                }
            }
        }else{
            var index = (Int)(floor((location.x - slider.frame.origin.x) / dotDistance))
            let remain = (location.x - slider.frame.origin.x) % dotDistance
            
            if remain >= dotDistance / 2 {
                index += 1
            }
            
            if index < rangeData.count {
                pointerValue =  rangeData[index]
            }else{
                pointerValue = DJRangeSilderView.DJMaxPrice
            }
            
            percentage = CGFloat(index) / CGFloat(rangeData.count)
            if gesture == leftPanGesture {
                if percentage >= rightPercentage {
                    index = Int(rightPercentage * CGFloat(rangeData.count))
                    index -= 1
                    if(index <= 0){
                        index = 0
                    }
                    leftPercentage = CGFloat(index) / CGFloat(rangeData.count)
                    leftRealValue = rangeData[index]
                }else{
                    leftPercentage = percentage
                    leftRealValue = pointerValue
                }
            }else if gesture == rightPanGesture {
                if percentage <= leftPercentage {
                    index = Int(leftPercentage * CGFloat(rangeData.count))
                    index += 1
                    if(index >= rangeData.count){
                        index = rangeData.count - 1
                    }
                    
                    rightRealValue = rangeData[index]
                    rightPercentage = CGFloat(index) / CGFloat(rangeData.count)
                }else{
                    rightPercentage = percentage
                    rightRealValue = pointerValue
                }
            }
            
            delegate?.rangeValueDidChanged(self, lowerValue: leftRealValue, higherValue: rightRealValue)
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    
}