//
//  TipsView.swift
//  DejaFashion
//
//  Created by jiao qing on 28/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

@objc  protocol TipsViewDelegate : NSObjectProtocol{
    func tipsViewDidClickRecommand(tipsView : TipsView)
}

class TipsView: UIView {
    private let arrow = UIImageView()
    private let label = UILabel()
    private let rcLabel = UILabel()
    private let bg = UIView()
    weak var delegate : TipsViewDelegate?
    var miniHeight : CGFloat = 0
    var viewWidth : CGFloat = 0
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        miniHeight = frame.size.height
        viewWidth = frame.size.width
        
        bg.backgroundColor = DJCommonStyle.backgroundColorWithAlpha(0.95)
        bg.addSubview(label)
        
        label.textAlignment =  .Left
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        label.withFontHeletica(15).withTextColor(UIColor.whiteColor())
        
        rcLabel.textAlignment =  .Left
        rcLabel.lineBreakMode = .ByWordWrapping
        rcLabel.numberOfLines = 0
        rcLabel.hidden = true
        rcLabel.userInteractionEnabled = true
        rcLabel.addTapGestureTarget(self, action: #selector(TipsView.tryRecDidClicked))
        rcLabel.withFontHeletica(15).withTextColor(UIColor(fromHexString: "71b0ea"))
        bg.addSubview(rcLabel)
        
        arrow.image = UIImage(named: "TutorialArrowLeft")
        self.addSubview(bg)
        self.addSubview(arrow)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
         bg.frame = CGRectMake(10, 0, viewWidth - 10, frame.size.height)
        if rcLabel.hidden {
            label.frame = CGRectMake(8, 0, bg.frame.size.width - 16, bg.frame.size.height)
        }else{
            label.frame = CGRectMake(8, 5.5, bg.frame.size.width - 16, label.frame.size.height)
            rcLabel.frame = CGRectMake(label.frame.origin.x, CGRectGetMaxY(label.frame) + 3, bg.frame.size.width - 16, rcLabel.frame.size.height)
        }
        
        arrow.frame = CGRectMake(0, bg.frame.size.height - 24.5, 10, 10)
    }
    
    func updateText(content : String, refresh : Bool) -> CGSize{
        label.text = content
        label.sizeToFit()
        rcLabel.hidden = !refresh
        if refresh {
            rcLabel.frame = CGRectMake(0, 0, bg.frame.size.width - 16, 10)
            rcLabel.text = "Get other inspirations >"
            rcLabel.sizeToFit()
        }else{
            rcLabel.frame = CGRectZero
        }
        return CGSizeMake(viewWidth, max(label.frame.size.height + rcLabel.frame.size.height + 18, miniHeight))
    }
    
    func setTextContent(content : String){
        label.text = content
    }
    
    func tryRecDidClicked(){
        self.delegate?.tipsViewDidClickRecommand(self)
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if self.hidden {
            return nil
        }
        
        let result = super.hitTest(point, withEvent: event)
        if result == nil {
            self.hidden = true
        }
        
        return result
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
