
//
//  AddByCameraEditViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 5/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol AddByCameraEditViewControllerDelegate : NSObjectProtocol{
    func addByCameraEditViewControllerDidBack(addByCameraEditViewController: AddByCameraEditViewController)
    func addByCameraEditViewControllerDone(addByCameraEditViewController: AddByCameraEditViewController, templateIndex: String?, theImage : UIImage, frame : CGRect, croppedImage : UIImage, isInPattern : Bool)
}

class AddByCameraEditViewController: UIViewController {
    private let topPhotoBtn = DJButton()
    private let topPatternBtn = DJButton()
    
    private let selectedView = DJScaleMoveView()
    private let maskView = UIImageView()
    
    private let scrollView = TemplateSelectionView()
    private let bottomView = UIView()
    private let scrollHeight : CGFloat = 113
    private let bottomHeight : CGFloat = 98
    
    var selectedImage : UIImage?
    var currentTemplateId : String?
    var inPattern = false
    
    private var clipImage : UIImage?
    private let tempArray = DJSelectionModels.getTemplatesInfo()
    weak var delegate : AddByCameraEditViewControllerDelegate?
    
    init(templateId : String?, theImage : UIImage, fromPattern : Bool) {
        super.init(nibName: nil, bundle: nil)
        currentTemplateId = templateId
        selectedImage = theImage
        
        inPattern = fromPattern
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(selectedView)
        view.addSubview(maskView)
        view.addSubview(bottomView)
        view.addSubview(scrollView)
        
        selectedView.resetImage(selectedImage)
        selectedView.maskRect = CGRectMake(view.frame.size.width / 2 - 100, 100, 200, 350)
        
        var templateInfos = [String]()
        var templateIcons = [UIImage]()
        for tmp in tempArray{
            templateInfos.append(tmp.info)
            templateIcons.append(tmp.icon)
        }
        scrollView.templateIcon = templateIcons
        scrollView.templateInfo = templateInfos
        scrollView.delegate = self
        
        let backButton = UIButton(frame: CGRectMake(20, 30, 23, 19))
        backButton.setImage(UIImage(named: "WhiteBackIconNormal"), forState: .Normal)
        backButton.addTarget(self, action: #selector(AddByCameraEditViewController.backButtonDidClicked), forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
        
        bottomView.backgroundColor = UIColor.defaultBlack()
        bottomView.addSubview(topPatternBtn)
        bottomView.addSubview(topPhotoBtn)
        topPhotoBtn.addTarget(self, action: #selector(AddByCameraEditViewController.topBtnDidTapped(_:)), forControlEvents: .TouchUpInside)
        topPatternBtn.addTarget(self, action: #selector(AddByCameraEditViewController.topBtnDidTapped(_:)), forControlEvents: .TouchUpInside)
        topPhotoBtn.withTitle(DJStringUtil.localize("Photo", comment:"")).withFontHeleticaMedium(15)
        topPatternBtn.withTitle(DJStringUtil.localize("Pattern", comment:"")).withFontHeleticaMedium(15)
        topPhotoBtn.sizeToFit()
        topPatternBtn.sizeToFit()
        let totalWidth = topPhotoBtn.frame.size.width + 34 + topPatternBtn.frame.size.width
        topPhotoBtn.frame = CGRectMake(view.frame.size.width / 2 - totalWidth / 2, 6, topPhotoBtn.frame.size.width, topPhotoBtn.frame.size.height)
        topPatternBtn.frame = CGRectMake(CGRectGetMaxX(topPhotoBtn.frame) + 34, 6, topPatternBtn.frame.size.width, topPatternBtn.frame.size.height)
        
        
        let albumBtn = UIButton()
        albumBtn.addTarget(self, action: #selector(AddByCameraEditViewController.albumBtnDidTapped), forControlEvents: .TouchUpInside)
        bottomView.addSubview(albumBtn)
        getAlbumPoster(albumBtn)
        albumBtn.frame = CGRectMake(21, bottomHeight - 50 - 18, 50, 50)
        
        let doneBtn = UIButton()
        doneBtn.withTitle(DJStringUtil.localize("Done", comment:"")).withFontHeleticaMedium(15).withTitleColor(UIColor(fromHexString: "f1f1f1"))
        doneBtn.addTarget(self, action: #selector(AddByCameraEditViewController.doneBtnDidTapped), forControlEvents: .TouchUpInside)
        bottomView.addSubview(doneBtn)
        doneBtn.sizeToFit()
        doneBtn.frame = CGRectMake(view.frame.size.width - doneBtn.frame.size.width - 23, bottomHeight - doneBtn.frame.size.height - 25, doneBtn.frame.size.width, doneBtn.frame.size.height)
        
        if inPattern {
            updateHighlightedView(1)
        }else{
            updateHighlightedView(0)
            setSelectedMaskWithId(currentTemplateId!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var offSet : CGFloat = 0
        if view.frame.size.width <= 320 {
            offSet = 40
        }else if view.frame.size.width <= 375{
            offSet = 35
        }else{
            offSet = 25
        }
        maskView.frame = CGRectMake(0, -offSet, view.frame.size.width, view.frame.size.height)
        selectedView.frame = maskView.frame
        
        scrollView.frame = CGRectMake(0, view.frame.size.height - bottomHeight - scrollHeight, view.frame.size.width, scrollHeight)
        bottomView.frame = CGRectMake(0, view.frame.size.height - bottomHeight, view.frame.size.width, bottomHeight)
        
    }
    
    func backButtonDidClicked(){
        self.delegate?.addByCameraEditViewControllerDidBack(self)
    }
    
    func doneBtnDidTapped(){
        if maskView.image != nil{
            let croppedImage = selectedView.clipImageWithImage(clipImage)
            
            self.delegate?.addByCameraEditViewControllerDone(self, templateIndex: currentTemplateId, theImage: selectedView.theImage, frame: selectedView.getImageViewFrame(), croppedImage:croppedImage, isInPattern : inPattern)
        }
    }
    
    func setSelectedMaskWithId(id : String?){
        currentTemplateId = id
        
        var index = 0
        for tmp in tempArray{
            let theTmp = tmp as! TemplateInfo
            if theTmp.id == id{
                setSelectedMaskRelated(index)
                break
            }
            index += 1
        }
    }
    
    func setSelectedMaskRelated(index : Int){
        if index < 0 || index > tempArray.count - 1{
            return
        }
        let theTemp = tempArray[index] as! TemplateInfo
        maskView.image = theTemp.template
        currentTemplateId = theTemp.id
        clipImage = theTemp.mask
        scrollView.selectIndex(index)
    }
}

extension AddByCameraEditViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate, TemplateSelectionViewDelegate{
    func topBtnDidTapped(sender : UIButton){
        if sender == topPhotoBtn {
            updateHighlightedView(0)
        }else if sender == topPatternBtn{
            updateHighlightedView(1)
        }
    }
    
    func updateHighlightedView(index : Int){
        setViewTitleColor(index)
        
        if index == 0{
            inPattern = false
            scrollView.hidden = false
            setSelectedMaskWithId(currentTemplateId)
        }else{
            inPattern = true
            maskView.image = UIImage(named: "PatternTemplate")
            clipImage = UIImage(named: "PatternCrop")
            scrollView.hidden =  true
        }
    }
    
    func setViewTitleColor(selectedIndex : Int){
        var focusBtn = topPhotoBtn
        if selectedIndex == 0 {
            topPatternBtn.withTitleColor(UIColor(fromHexString: "f1f1f1"))
        }else if selectedIndex == 1{
            focusBtn = topPatternBtn
            topPhotoBtn.withTitleColor(UIColor(fromHexString: "f1f1f1"))
        }
        focusBtn.withTitleColor(UIColor(fromHexString: "f4d128"))
    }
    
    func getAlbumPoster(theBtn : UIButton) {
        let completion = { (theImage : UIImage?) -> Void in
            theBtn.setImage(theImage, forState: .Normal)
        }
        DJAblumOperation.getAlbumPoster(completion)
    }
    
    func albumBtnDidTapped(){
        if !DJConfigDataContainer.instance().checkPermissionForKey(kDJAlbumPermissionIdentifier){
            DJConfigDataContainer.instance().showEnableAccessAlertViewForKey(kDJAlbumPermissionIdentifier, withViewDelegate: nil)
        }
        DJAblumOperation.choosePicture(self)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let img = info[UIImagePickerControllerOriginalImage] {
            selectedView.resetImage(img as! UIImage)
        }
    }
    
    
    func templateSelectionViewDidSelectIndex(templateSelectionView: TemplateSelectionView, index : Int){
        setSelectedMaskRelated(index)
    }
}
