

//
//  BodyReshapeViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 8/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

let funcBtnWidth : CGFloat = 143
let SelectorWidth : CGFloat = 143

class BodyReshapeViewController: DJBasicViewController {
    let shoulderSelector = MultiSelectorView()
    let waistSelector = MultiSelectorView()
    let cupSizeSelector = MultiSelectorView()
    let hipSelector = MultiSelectorView()
    let armSelector = MultiSelectorView()
    let legSelector = MultiSelectorView()
    let modelBGView = UIImageView()
    
    lazy private var reshapeView: DJBasicBodyView = {
        var frame = CGRectZero
        if self.view.frame.size.width == 320{
            let seemFrameWidth = self.view.frame.size.width - 23 * 2 - 80
            frame.size.width = seemFrameWidth * 1.3
            frame.origin.x = 1 - 20
            frame.origin.y = 7
        }else if self.view.frame.size.width == 375{
            let seemFrameWidth = self.view.frame.size.width - 23 * 2 - 80
            frame.size.width = seemFrameWidth * 1.21
            
            frame.origin.x = 23 - seemFrameWidth * 0.1 - 20
            frame.origin.y = 7.5
        }
        else if self.view.frame.size.width == 414{
            let seemFrameWidth = self.view.frame.size.width - 23 * 2 - 80
            frame.size.width = seemFrameWidth * 1.175
            frame.origin.x = -4 - 20
            frame.origin.y = 3
        }
        frame.size.height = kDJModelViewHeight3x * frame.size.width / kDJModelViewWidth3x
        return DJBasicBodyView(frame: frame)
    }()
    
    lazy var myModelInfo = FittingRoomDataContainer.sharedInstance.getMyModelInfo()
    
    var lastBodyShapeInfo : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = DJStringUtil.localize("Body Adjustment", comment:"")
        view.backgroundColor = UIColor.whiteColor()
        
        lastBodyShapeInfo = FittingRoomDataContainer.sharedInstance.getMyModelInfo().fullBodyShape()

        modelBGView.image = UIImage(named: "ModelBG")
        view.addSubview(modelBGView)
        
        view.addSubview(reshapeView)
        
        reshapeView.makeupId = myModelInfo.makeupId
        reshapeView.skinColor = myModelInfo.skinColor
        reshapeView.hairColor = myModelInfo.hairColor
        reshapeView.hairStyleId = myModelInfo.hairStyle
        reshapeView.bodyShape = myModelInfo.halfBodyShap()
        reshapeView.cupSize = myModelInfo.cupSize
        reshapeView.armShape = myModelInfo.armShape()
        reshapeView.legShape = myModelInfo.legShape()
        reshapeView.refreshModelOnly()
        
        var oY : CGFloat = 0
        let funcHeight = (UIScreen.mainScreen().bounds.size.height - 64) / 6
        
        shoulderSelector.rangeValues = ["S", "M", "L"]
        shoulderSelector.setInfoValues = ["34-38cm", "39-42cm", "43-46cm"]
        shoulderSelector.setTitle(DJStringUtil.localize("Shoulder", comment:""))
        shoulderSelector.delegate = self
        shoulderSelector.setSelectorWithInitValue(myModelInfo.shoulder)
        view.addSubview(containerView(oY, height: funcHeight, Selector: shoulderSelector))
        
        
        oY += funcHeight
        cupSizeSelector.rangeValues = ["A", "B", "C"]
        cupSizeSelector.setInfoValues = ["A", "B", "C"]
        cupSizeSelector.setTitle(DJStringUtil.localize("Cup Size", comment:""))
        cupSizeSelector.infoLabel.hidden = true
        cupSizeSelector.delegate = self
        var initCupSize = "C"
        if myModelInfo.cupSize == "s"{
            initCupSize = "A"
        } else if myModelInfo.cupSize == "m"{
            initCupSize = "B"
        } else{
            initCupSize = "C"
        }
        cupSizeSelector.setSelectorWithInitValue(initCupSize)
        view.addSubview(containerView(oY, height: funcHeight, Selector: cupSizeSelector))
        
        oY += funcHeight
        waistSelector.rangeValues = ["S", "M", "L"]
        waistSelector.setInfoValues = ["58-70cm", "71-74cm", "75-89cm"]
        waistSelector.setTitle(DJStringUtil.localize("Waist", comment:""))
        waistSelector.delegate = self
        waistSelector.setSelectorWithInitValue(myModelInfo.waist)
        view.addSubview(containerView(oY, height: funcHeight, Selector: waistSelector))
        
        oY += funcHeight
        hipSelector.rangeValues = ["S", "M", "L"]
        hipSelector.setInfoValues = ["77-87cm", "88-93cm", "94-100cm"]
        hipSelector.setTitle(DJStringUtil.localize("Hip", comment:""))
        hipSelector.delegate = self
        hipSelector.setSelectorWithInitValue(myModelInfo.hip)
        view.addSubview(containerView(oY, height: funcHeight, Selector: hipSelector))
        
        oY += funcHeight
        armSelector.rangeValues = [DJStringUtil.localize("Slim", comment:""), DJStringUtil.localize("Strong", comment:"")]
        armSelector.setInfoValues = [DJStringUtil.localize("Slim", comment:""), DJStringUtil.localize("Strong", comment:"")]
        armSelector.setTitle(DJStringUtil.localize("Arm", comment:""))
        armSelector.infoLabel.hidden = true
        armSelector.delegate = self
        var initArm = DJStringUtil.localize("Slim", comment:"")
        if myModelInfo.arm == "l"{
            initArm = DJStringUtil.localize("Strong", comment:"")
        }
        armSelector.setSelectorWithInitValue(initArm)
        view.addSubview(containerView(oY, height: funcHeight, Selector: armSelector))
        
        oY += funcHeight
        legSelector.rangeValues = [DJStringUtil.localize("Slim", comment:""), DJStringUtil.localize("Strong", comment:"")]
        legSelector.setInfoValues = [DJStringUtil.localize("Slim", comment:""), DJStringUtil.localize("Strong", comment:"")]
        legSelector.setTitle(DJStringUtil.localize("Leg", comment:""))
        legSelector.delegate = self
        legSelector.infoLabel.hidden = true
        var initLeg = DJStringUtil.localize("Slim", comment:"")
        if myModelInfo.leg == "l"{
            initLeg = DJStringUtil.localize("Strong", comment:"")
        }
        legSelector.setSelectorWithInitValue(initLeg)
        view.addSubview(containerView(oY, height: funcHeight, Selector: legSelector))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        modelBGView.frame = CGRectMake(-20, 0, view.frame.size.width, view.frame.size.height)
    }
    
    func containerView(oY : CGFloat, height : CGFloat, Selector : MultiSelectorView) -> UIView{
        let sView = UIView(frame: CGRectMake(view.frame.size.width - funcBtnWidth, oY, funcBtnWidth, height))
        sView.addSubview(Selector)
        sView.backgroundColor = UIColor.whiteColor()
        
        Selector.frame = CGRectMake(-10, 0, funcBtnWidth + 20, height)
        
        let lineView = UIView(frame: CGRectMake(0, sView.frame.size.height - 0.5, sView.frame.size.width, 0.5))
        lineView.backgroundColor = UIColor(fromHexString: "cecece")
        sView.addSubview(lineView)
        
        return sView
    }
}

extension BodyReshapeViewController : MultiSelectorViewDelegate {
    func multiSelectorViewValueDidChanged(multiSelectorView: MultiSelectorView, value: String) {
        myModelInfo.shoulder = shoulderSelector.realValue.lowercaseString
        
        if cupSizeSelector.realValue.lowercaseString == "a"{
            myModelInfo.cupSize = "s"
        }else if cupSizeSelector.realValue.lowercaseString == "b"{
            myModelInfo.cupSize = "m"
        }else{
            myModelInfo.cupSize = "l"
        }
        
        myModelInfo.waist = waistSelector.realValue.lowercaseString
        myModelInfo.hip = hipSelector.realValue.lowercaseString
        
        if armSelector.realValue == DJStringUtil.localize("Slim", comment:""){
            myModelInfo.arm = "s"
        }else{
            myModelInfo.arm = "l"
        }
        
        if legSelector.realValue == DJStringUtil.localize("Slim", comment:""){
            myModelInfo.leg = "s"
        }else{
            myModelInfo.leg = "l"
        }
        
        FittingRoomDataContainer.sharedInstance.updateMyModelInfo(myModelInfo)
        
        reshapeView.bodyShape = myModelInfo.halfBodyShap()
        reshapeView.cupSize = myModelInfo.cupSize
        reshapeView.armShape = myModelInfo.armShape()
        reshapeView.legShape = myModelInfo.legShape()
        reshapeView.refreshModelOnly()
        
        NSNotificationCenter.defaultCenter().postNotificationName(DJNotifyDejaModelShapeChanged, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if myModelInfo.fullBodyShape() != lastBodyShapeInfo {
            let task = UploadBodyInfoNetTask()
            MONetTaskQueue.instance().addTask(task)
        }
    }

}
