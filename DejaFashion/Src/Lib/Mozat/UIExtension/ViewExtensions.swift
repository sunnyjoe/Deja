//
//  ViewExtensions.swift
//  DejaFashion
//
//  Created by jiao qing on 10/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

let borderConstraintGroup = ConstraintGroup()

extension UIImageView {
    func sd_setImageWithURLStr(str : String?){
        if let imageUrl = str{
            if let url = NSURL(string:  imageUrl){
                self.sd_setImageWithURL(url)
            }
        }
    }
}

extension UIView {
    func addBorder(){
        let border = UIView(frame : CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5))
        border.backgroundColor = DJCommonStyle.ColorCE
        addSubview(border)
        
        if frame.size == CGSizeZero {
            border.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0).active = true
            NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0.5).active = true
            NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0).active = true
        }
    }
    
    func addTopBorder(color : UIColor = DJCommonStyle.ColorCE){
        let border = UIView(frame : CGRectMake(0, 0, frame.size.width, 0.5))
        border.backgroundColor = color
        addSubview(border)
        
        if frame.size == CGSizeZero {
            border.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0).active = true
            NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0.5).active = true
            NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Top, relatedBy: .Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0).active = true
        }
    }
    
    func addSubviews(views : UIView...) {
        for v in views {
            self.addSubview(v)
        }
    }
    
    class func setFrameToViews(frame: CGRect, views : UIView...) {
        for v in views {
            v.frame = frame
        }
    }
    
    
    func withBackgroundColor(color : UIColor) -> UIView {
        backgroundColor = color
        return self
    }
        
    func debugFrames (views : UIView...) {
        //        for view in views {
        //            view.layer.borderWidth = 2
        //            view.layer.borderColor = UIColor.redColor().CGColor
        //        }
    }
    
    func hideViews(views : UIView...) {
        views.forEach { (view) -> () in
            view.hidden = true
        }
    }
    
    func showViews(views : UIView...) {
        views.forEach { (view) -> () in
            view.hidden = false
        }
    }
    
    func showRedDot(minFrame : CGRect, count : Int = 0) {
        hideRedDot()
        if count == 0 {
            let redDotLayer = CALayer()
            redDotLayer.frame = minFrame
            redDotLayer.cornerRadius = minFrame.width / 2
            redDotLayer.backgroundColor = DJCommonStyle.ColorRed.CGColor
            redDotLayer.name = "RedDot"
            self.layer.addSublayer(redDotLayer)
        }else {
            let countLayer = CATextLayer()
            countLayer.fontSize = minFrame.width * 4 / 5
            countLayer.contentsScale = UIScreen.mainScreen().scale
            if count > 99 {
                countLayer.frame = CGRect(origin: minFrame.origin, size: CGSize(width: minFrame.width * 2.2, height: minFrame.height))
                countLayer.string = "99+"
            }else if count > 9 {
                countLayer.frame = CGRect(origin: minFrame.origin, size: CGSize(width: minFrame.width * 1.6, height: minFrame.height))
                countLayer.string = count.description
            }else {
                countLayer.frame = minFrame
                countLayer.string = count.description
            }
            countLayer.alignmentMode = kCAAlignmentCenter
            countLayer.cornerRadius = minFrame.width / 2
            countLayer.backgroundColor = DJCommonStyle.ColorRed.CGColor
            countLayer.name = "RedDot"
            self.layer.addSublayer(countLayer)
        }
    }
    
    func hideRedDot() -> Bool{
        if let subLayers = self.layer.sublayers {
            for layer in subLayers {
                if layer.name == "RedDot" {
                    layer.removeFromSuperlayer()
                    return true
                }
            }
        }
        return false
    }
}

extension UILabel {
    func withFontHeletica(size : CGFloat) -> UILabel{
        self.font = DJFont.helveticaFontOfSize(size)
        return self
    }
    
    func withFontHeleticaMedium(size : CGFloat) -> UILabel{
        self.font = DJFont.mediumHelveticaFontOfSize(size)
        return self
    }
    
    func withFontHeleticaBold(size : CGFloat) -> UILabel{
        self.font = DJFont.boldHelveticaFontOfSize(size)
        return self
    }
    
    func withFontHeleticaLight(size : CGFloat) -> UILabel{
        self.font = DJFont.lightHelveticaFontOfSize(size)
        return self
    }
    
    func withFontHeleticaThin(size : CGFloat) -> UILabel{
        self.font = DJFont.thinHelveticaFontOfSize(size)
        return self
    }
    
    func textCentered() -> UILabel {
        self.textAlignment = NSTextAlignment.Center
        return self
    }
    
    func withTextColor(color: UIColor) -> UILabel {
        self.textColor = color
        return self
    }
    func withText(text: String?) -> UILabel {
        self.text = text
        return self
    }
}

extension UIButton {
    func withFontHeletica(size : CGFloat) -> UIButton{
        self.titleLabel!.font = DJFont.helveticaFontOfSize(size)
        return self
    }
    
    func withFontHeleticaBold(size : CGFloat) -> UIButton{
        self.titleLabel!.font = DJFont.boldHelveticaFontOfSize(size)
        return self
    }
    
    func withFontHeleticaMedium(size : CGFloat) -> UIButton{
        self.titleLabel!.font = DJFont.mediumHelveticaFontOfSize(size)
        return self
    }
    
    func withTitle(title : String) -> UIButton {
        self.setTitle(title, forState: .Normal)
        return self
    }
    
    func withFont(font : UIFont) -> UIButton {
        self.titleLabel?.font = font
        return self
    }
    
    func withTitleColor(color : UIColor) -> UIButton {
        self.setTitleColor(color, forState: .Normal)
        return self
    }
    
    func withHighlightTitleColor(color : UIColor) -> UIButton {
        self.setTitleColor(color, forState: .Highlighted)
        return self
    }
    
    func withDisabledTitleColor(color : UIColor) -> UIButton {
        self.setTitleColor(color, forState: .Disabled)
        return self
    }
    
    func defaultTitleColor() -> UIButton{
        self.setTitleColor(UIColor.defaultBlack(), forState: UIControlState.Normal)
        return self
    }
    
    func setBackgroundColor(color: UIColor, forState state: UIControlState) {
        setBackgroundImage(UIImage(color: color), forState: state)
    }
    
    func withBackgroundImage(image : UIImage?) -> UIButton {
        setBackgroundImage(image, forState: state)
        return self
    }
    
    func withImage(image : UIImage?) -> UIButton {
        setImage(image, forState: state)
        return self
    }

}

extension UIColor {
    static func defaultBlack() -> UIColor {
        return UIColor(fromHexString: "262729")
    }
    
    static func defaultRed() -> UIColor {
        return UIColor(fromHexString: "f81f34")
    }
    
    static func gray81Color() -> UIColor {
        return UIColor(fromHexString: "818181")
    }
}

extension UICollectionViewCell {
    func fillWithContentView<T : View>(initBlock : (T) -> Void, fillContentBlock : (T) -> Void ) {
        var contentView : T?
        for view in subviews {
            if let v = view as? T {
                contentView = v
            }
        }
        if contentView == nil {
            contentView = T()
            addSubview(contentView!)
            initBlock(contentView!)
        }
        fillContentBlock(contentView!)
    }
}

extension UITableViewCell {
    func fillWithContentView<T : View>(initBlock : (T) -> Void, fillContentBlock : (T) -> Void ) {
        var contentView : T?
        for view in subviews {
            if let v = view as? T {
                contentView = v
            }
        }
        if contentView == nil {
            contentView = T()
            addSubview(contentView!)
            initBlock(contentView!)
        }
        fillContentBlock(contentView!)
    }
}

extension UINavigationBar {
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = false
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
    
}

class BorderView : UIView {
    private let leftBorder = UIView()
    private let rightBorder = UIView()
    private let topBorder = UIView()
    private let bottomBorder = UIView()
    
    var borders : (left : Bool, top : Bool, right : Bool, bottom : Bool) {
        didSet {
            leftBorder.hidden = !borders.left
            rightBorder.hidden = !borders.right
            topBorder.hidden = !borders.top
            bottomBorder.hidden = !borders.bottom
        }
    }
    
    var borderColor : UIColor = Colors.DividerColor {
        didSet {
            [leftBorder, rightBorder, topBorder, bottomBorder].forEach { (border) -> () in
                border.withBackgroundColor(borderColor)
            }
        }
    }
    
    override init(frame: CGRect) {
        borders = (false, false, false, false)
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        [leftBorder, rightBorder, topBorder, bottomBorder].forEach { (border) -> () in
            border.withBackgroundColor(Colors.DividerColor)
            border.hidden = true
            addSubview(border)
        }
        constrain(leftBorder, self) { (leftBorder, parent) -> () in
            leftBorder.top == parent.top
            leftBorder.bottom == parent.bottom
            leftBorder.left == parent.left
            leftBorder.width == 0.5
        }
        
        constrain(rightBorder, self) { (rightBorder, parent) -> () in
            rightBorder.top == parent.top
            rightBorder.bottom == parent.bottom
            rightBorder.right == parent.right
            rightBorder.width == 0.5
        }
        
        constrain(topBorder, self) { (topBorder, parent) -> () in
            topBorder.top == parent.top
            topBorder.right == parent.right
            topBorder.left == parent.left
            topBorder.height == 0.5
        }
        
        constrain(bottomBorder, self) { (bottomBorder, parent) -> () in
            bottomBorder.bottom == parent.bottom
            bottomBorder.left == parent.left
            bottomBorder.right == parent.right
            bottomBorder.height == 0.5
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}