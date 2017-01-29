//
//  StylingMissionCreatingViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 23/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
import Social

@objc protocol StylingMissionCreatingDelegate {
    func stylingMissionDidCreated()
}

class StylingMissionCreatingViewController: DJBasicViewController, MONetTaskDelegate {
    
    let textViewPlaceHolder = DJStringUtil.localize("I am looking for an outfit. Can somebody help?", comment: "")
    
    var clothesId : String?
    var occasionId : String?
    
    let textView = UITextView()
    let button = DJButton().whiteTitleBlackStyle()
    
    weak var delegate : StylingMissionCreatingDelegate?
    
    let occasionLabel = UILabel().withFontHeletica(16).withTextColor(DJCommonStyle.BackgroundColor)
    
    var filterView : OccasionFilterView?
    
    let clothesImageView = UIImageView()
    
    let facebookShareCheckBox = UIButton(frame: CGRectMake(0, 3, 15, 15))
    
    override func viewDidLoad() {
        title = DJStringUtil.localize("New Task", comment: "")
        super.viewDidLoad()
        
        let occasionView = UIView(frame: CGRectMake(23, 20, view.frame.width - 46, 18))
        
        let occasionTitle = UILabel(frame: CGRectMake(0, 0, view.frame.width - 46, 18)).withFontHeleticaMedium(16).withTextColor(DJCommonStyle.BackgroundColor)
        occasionTitle.text = DJStringUtil.localize("Occasion", comment: "")
        
        if let occasionId = self.occasionId {
            let occasions = ConfigDataContainer.sharedInstance.getConfigStyleCategory()
            for o in occasions {
                for filter in o.values {
                    if filter.id == occasionId {
                        occasionLabel.text = filter.name
                    }
                }
            }
        }else {
            occasionLabel.text = DJStringUtil.localize("Any", comment: "")
        }
        occasionLabel.frame = CGRectMake(0, 0, view.frame.width - 62, 18)
        occasionLabel.textAlignment = .Right
        occasionView.addTapGestureTarget(self, action: #selector(StylingMissionCreatingViewController.showOccasionFilter(_:)))
        
        let arrowIcon = UIButton()
        arrowIcon.userInteractionEnabled = false
        arrowIcon.setImage(UIImage(named: "ProfileArrow"), forState: .Normal)
        
        occasionView.addSubviews(occasionTitle, occasionLabel, arrowIcon)

        constrain(arrowIcon) { arrowIcon in
            arrowIcon.right == arrowIcon.superview!.right
            arrowIcon.centerY == arrowIcon.superview!.centerY
        }
        
        textView.frame = CGRectMake(23, 10, view.frame.width - 46, view.frame.height - 38 - 251)
        occasionView.frame = CGRectMake(23, textView.frame.maxY + 18, view.frame.width - 46, 18)
        textView.text = textViewPlaceHolder
        textView.textColor = DJCommonStyle.BackgroundColor
        textView.selectAll(self)
        textView.keyboardAppearance = .Light
        textView.font = DJFont.fontOfSize(16)
        addInputAccessoryViewToTextView(textView)
        button.withTitle("Post")
        button.addTarget(self, action: #selector(StylingMissionCreatingViewController.tapToCreateMission), forControlEvents: .TouchUpInside)
        button.frame = CGRectMake(23, view.frame.height - 188, view.frame.width - 46, 35)
        
        let label = DJLabel()
        label.insets = UIEdgeInsetsMake(0, 20, 0, 0)
        label.text = DJStringUtil.localize("Share this on Facebook", comment: "")
        label.sizeToFit()
        label.frame = CGRectMake(view.frame.width / 2 - label.frame.width / 2, button.frame.maxY + 10, label.frame.width, 20)
        label.withFontHeletica(14).withTextColor(UIColor.gray81Color())
        view.addSubviews(label)
        
        facebookShareCheckBox.setBackgroundImage(UIImage(named: "ClothesSelectedIconBlack"), forState: .Selected)
        facebookShareCheckBox.setBackgroundImage(UIImage(named: "ClothesNotSelectedIcon"), forState: .Normal)
        facebookShareCheckBox.userInteractionEnabled = false
        label.addSubview(facebookShareCheckBox)
        
        label.addTapGestureTarget(self, action: #selector(StylingMissionCreatingViewController.selectFacebookShare))
        
        let divider = UIView(frame: CGRectMake(0, textView.frame.height - 1, view.frame.width - 46, 1))
        divider.withBackgroundColor(DJCommonStyle.DividerColor)
        textView.addSubview(divider)

        view.addSubviews(occasionView, textView, button)
        if let _ = clothesId {
            clothesImageView.frame = CGRectMake(0, 0, 35, 45)
            clothesImageView.contentMode = .ScaleAspectFit
            let clothesView = UIView(frame: CGRectMake(23, view.frame.height - 220, view.frame.width - 46, 45))
            let clothesTip = UILabel(frame: CGRectMake(45, 0, view.frame.width - 46, 45))
            clothesTip.withTextColor(UIColor.gray81Color())
            clothesTip.withFontHeletica(14)
            clothesTip.text = DJStringUtil.localize("Outfit must include this item.", comment: "")
            clothesView.addSubviews(clothesImageView, clothesTip)
            view.addSubviews(clothesView)
            fetchClothesInfo()
        }
        
        view.addTapGestureTarget(self, action: #selector(StylingMissionCreatingViewController.closeKeyboard))
    }
    
    func addInputAccessoryViewToTextView(textField : UITextView) {
        let space1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let space2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let barButton = UIBarButtonItem(barButtonSystemItem: .Done, target:textField, action: #selector(UIResponder.resignFirstResponder))
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, view.frame.width, 44))
        toolbar.items = [space1, space2, barButton]
        textField.keyboardAppearance = .Dark
        textField.inputAccessoryView = toolbar;
    }
    
    func selectFacebookShare() {
        facebookShareCheckBox.selected = !facebookShareCheckBox.selected
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    func showOccasionFilter(reg : UITapGestureRecognizer) {
        let styleCondi = ConfigDataContainer.sharedInstance.getConfigStyleCategory()
        if filterView == nil {
            if styleCondi.count > 0{
                filterView = OccasionFilterView(frame: view.bounds)
                filterView!.delegate = self
                filterView!.hidden = true
            }
        }
        
        if filterView!.hidden {
            view.endEditing(true)
            filterView?.showAnimation()
        }else{
            filterView?.hideAnimation()
        }
        
        if let id = occasionId {
            let filter = Filter()
            filter.id = id
            filterView?.resetSelectedFilters([filter])
        }
        
        view.addSubview(filterView!)
    }
    
    func fetchClothesInfo() {
        let task = GetClothesInfoNetTask()
        task.clothedIds = [clothesId!]
        MONetTaskQueue.instance().addTask(task)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
    }
    
    func tapToCreateMission() {
        if textView.text.characters.count == 0 {
            MBProgressHUD.showHUDAddedTo(self.view, text: "Description should not be empty!", duration: 2)
            return
        }
        
        let task = StylingMissionCreatingNetTask()
        if let text = textView.text {
            task.desc = text
        }
        task.occasionId = occasionId
        task.clothesId = clothesId
        MONetTaskQueue.instance().addTask(task)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if let t = task as? GetClothesInfoNetTask {
            if let detail = t.clothesList?.first {
                _Log(detail.thumbUrl!)
                if let s = detail.thumbUrl {
                    if let url = NSURL(string : s + "/\(ImageQuality.LOW).jpg") {
                        clothesImageView.sd_setImageWithURL(url)
                    }
                }
            }
        }
        
        if let _ = task as? StylingMissionCreatingNetTask {
            MBProgressHUD.showHUDAddedTo(view, text: "Create successfully.", animated: true)
            
            if let delegate = self.delegate {
                delegate.stylingMissionDidCreated()
            }
            
            let successBlock = {
                let vc = MissionCreatedViewController()
                if let occasionName = ConfigDataContainer.sharedInstance.getOccasionFilterNameById(self.occasionId) {
                    vc.desc = DJStringUtil.localize("Style advice needed for \(occasionName)! Help me out? ", comment: "")
                }else {
                    vc.desc = DJStringUtil.localize("Style advice needed! Help me out? ", comment: "")
                }
                self.navigationController?.pushViewController(vc, animated: true)
                self.closeCurrentViewController()
            }
            
            if facebookShareCheckBox.selected {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(0.3) * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), successBlock)
                shareViaFacebook()
            }else {
                successBlock()
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        
    }
    
    func shareViaFacebook() {
        let entry = DJFBShareEntry()
        entry.parameter.facebookText = DJStringUtil.localize("Take a look into my wardrobe and help me put together an outfit!", comment: "")
        entry.parameter.link = ConfigDataContainer.sharedInstance.getSharedMissionUrl(AccountDataContainer.sharedInstance.userID!)
        if let occasionName = ConfigDataContainer.sharedInstance.getOccasionFilterNameById(occasionId) {
            entry.parameter.facebookTitle = DJStringUtil.localize("Style advice needed for \(occasionName)! Help me out? ", comment: "")
        }else {
            entry.parameter.facebookTitle = DJStringUtil.localize("Style advice needed! Help me out? ", comment: "")
        }
        entry.parameter.imageUrl = DJUrl.shareImageUrl();
        entry.share()
    }
}

//extension StylingMissionCreatingViewController : UITextViewDelegate {
//    func textViewDidBeginEditing(textView: UITextView) {
//        if textView.text == textViewPlaceHolder {
//            textView.text = ""
//            textView.textColor = DJCommonStyle.BackgroundColor
//        }
//        textView.becomeFirstResponder()
//    }
//    
//    func textViewDidEndEditing(textView: UITextView) {
//        if textView.text == "" {
//            textView.text = textViewPlaceHolder
//            textView.textColor = UIColor.gray81Color()
//        }
//        textView.resignFirstResponder()
//    }
//    
//}

extension StylingMissionCreatingViewController : OccasionFilterViewDelegate {
    
    func refineViewDone(refineView: OccasionFilterView) {
        refineView.hideAnimation()
        occasionId = refineView.selectedFilters.first?.id
        if let name = refineView.selectedFilters.first?.name {
            occasionLabel.text = name
        }else {
            occasionLabel.text = DJStringUtil.localize("Any", comment: "")
        }
    }
}
