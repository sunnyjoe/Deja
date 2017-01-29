 //
 //  AddClothByCameraViewController.swift
 //  DejaFashion
 //
 //  Created by jiao qing on 1/2/16.
 //  Copyright © 2016 Mozat. All rights reserved.
 //
 
 import UIKit
 import CoreMotion
 
 enum AddByCameraStatus {
    case Pause
    case Capturing
    case Editing
    case Scanning
    case Done
    case ShowResult
 }
 
 class AddClothByCameraViewController: DJBasicViewController, MONetTaskDelegate{
    let caputureDelay = 2 //second
    private let scanImageView = UIImageView()
    
    private let byPatternView = AddByPatternView()
    private let byPhotoView = AddByPhotoView()
    private var currentView : CameraView!
    private var containerView = UIView()
    private let topPhotoBtn = DJButton()
    private let topPatternBtn = DJButton()
    
    let albumBtn = UIButton()
 
    private var byPhotoInitNetTask = AddByPhotoInitNetTask()
    private var byPatternNetTask = AddByPatternNetTask()
    
    private var swipGesRight : UISwipeGestureRecognizer!
    private var swipGesLeft: UISwipeGestureRecognizer!
    private var hintView : CameraHintView?
    private var currentStatus = AddByCameraStatus.Pause
    private let questionLabel = UILabel()
  
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        getAlbumPoster(albumBtn)
        
        if currentStatus == .ShowResult{
            setCurrentStatus(.Capturing)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    func setCurrentStatus(status : AddByCameraStatus){
        switch status {
        case .Capturing:
            currentView.switchCamera(true)
        default :
            currentView.switchCamera(false)
        }
        
        currentStatus = status
    }
    
    func cancelBtnDidTapped(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func takePhotoDidPressed(){
        DJStatisticsLogic.instance().addTraceLog(.Photo_Click_Shot)
        
        if currentStatus != .Capturing{
            return
        }
        
        var afterCapture = {}
        if currentView == byPhotoView {
            afterCapture = {
                if let tmp = self.currentView.capturedImage{
                    self.setCurrentStatus(.Scanning)
                    self.gotoScanningWith(tmp, selectedImageFrame: self.view.bounds)
                    self.sendByPhotoInitNetTask()
                    DJAblumOperation.saveImageToAlbum(tmp)
                }
            }
        }else if currentView == byPatternView{
            afterCapture = {
                if let tmp = self.currentView.capturedImage{
                    self.setCurrentStatus(.Scanning)
                    self.gotoScanningWith(tmp, selectedImageFrame: self.view.bounds)
                    self.sendByPatternInitNetTask()
                }
            }
        }
        currentView.capturePhoto(afterCapture)
    }
    
    func gotoScanningWith(selectedImage : UIImage, selectedImageFrame : CGRect){
        let scanVC = AddByCameraScanViewController(theImage: selectedImage, maskImage: currentView.mask!, imageFrame: selectedImageFrame)
        scanVC.delegate = self
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    func sendByPhotoInitNetTask(){
        MONetTaskQueue.instance().cancelTask(self.byPhotoInitNetTask)
        self.byPhotoInitNetTask.templateId = self.byPhotoView.getTemplateId()
        if let theImage = self.byPhotoView.croppedImage {
            self.byPhotoInitNetTask.imageData = UIImagePNGRepresentation(theImage)
        }else{
            return
        }
        MONetTaskQueue.instance().addTaskDelegate(self, uri: self.byPhotoInitNetTask.uri())
        MONetTaskQueue.instance().addTask(self.byPhotoInitNetTask)
    }
    
    func sendByPatternInitNetTask(){
        MONetTaskQueue.instance().cancelTask(self.byPatternNetTask)
        self.byPatternNetTask = AddByPatternNetTask()
        
        if let theImage = self.byPatternView.croppedImage {
            self.byPatternNetTask.imageData = UIImagePNGRepresentation(theImage)
        }
        MONetTaskQueue.instance().addTaskDelegate(self, uri: self.byPatternNetTask.uri())
        MONetTaskQueue.instance().addTask(self.byPatternNetTask)
    }
 
    func netTaskDidEnd(task: MONetTask!) {
        if task == byPhotoInitNetTask || task == byPatternNetTask{
            setCurrentStatus(.Done)
            navigationController?.popViewControllerAnimated(false)
        }
        
        if task == byPhotoInitNetTask{
            DJStatisticsLogic.instance().addTraceLog(.Findresult_appear)
            let enterC = ClothResultCondition()
            enterC.filterCondition.photoMark = byPhotoInitNetTask.mark
            if let tmp = ConfigDataContainer.sharedInstance.getCatogryByTemplateId(byPhotoInitNetTask.templateId!) {
                enterC.filterCondition.categoryId = tmp.categoryId
            }
            let resultVC = FindClothResultViewController(enterInfo : enterC)
            navigationController?.pushViewController(resultVC, animated: true)

            setCurrentStatus(.ShowResult)
        }else if task == byPatternNetTask{
            if byPatternNetTask.categoryIds.count > 0 {
                let enterC = ClothResultCondition()
                enterC.filterCondition.photoMark = byPhotoInitNetTask.mark
                
                let resultVC = FindClothResultViewController(enterInfo : enterC)
                navigationController?.pushViewController(resultVC, animated: true)

                DJStatisticsLogic.instance().addTraceLog(.Findresult_appear)
                setCurrentStatus(.ShowResult)
            }else {
                MBProgressHUD.showHUDAddedTo(view, text: DJStringUtil.localize("Pattern not found", comment:""), animated: true)
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
            MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Oops! Network is down.", comment: ""), animated: true)
        }
        
        if task == byPhotoInitNetTask || task == byPatternNetTask{
            setCurrentStatus(.Capturing)
            navigationController?.popViewControllerAnimated(false)
        }
    }
 }
 
 extension AddClothByCameraViewController: AddByPhotoViewDelegate{
    func addByPhotoViewDidSelectTemplateIndex(addByPhotoView: AddByPhotoView, index: Int) {
        DJStatisticsLogic.instance().addTraceLog(.Photo_Click_Template)
        addByPhotoView.setSelectedMaskRelated(index)
    }
}
 
extension AddClothByCameraViewController: UIGestureRecognizerDelegate{
    func hintBtnDidClicked(){
        if hintView == nil{
            hintView = CameraHintView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        }
        view.addSubview(hintView!)
        hintView!.scaleShowAnimation(hintView!.frame, startWidth: 2, time: 0.3, alpha: true, completion: nil)
        
        DJStatisticsLogic.instance().addTraceLog(.Photo_Click_Help)
    }
    
    func swipeGesture(ges : UISwipeGestureRecognizer){
        if ges.direction == .Left && currentView == byPhotoView{
            updateHighlightedView(1)
        }else if ges.direction == .Right && currentView == byPatternView{
            updateHighlightedView(0)
        }
    }
    
    func topBtnDidTapped(sender : UIButton){
        if sender == topPhotoBtn {
            updateHighlightedView(0)
        }else if sender == topPatternBtn{
            updateHighlightedView(1)
            DJStatisticsLogic.instance().addTraceLog(.Photo_Click_Pattern)
        }
    }
    
    func updateHighlightedView(index : Int){
        setViewTitleColor(index)
        
        self.currentView.removeFromSuperview()
        let preStatus = currentStatus
        setCurrentStatus(.Pause)
        if index == 0 {
            questionLabel.hidden = false
            self.currentView = self.byPhotoView
        }else if index == 1{
            questionLabel.hidden = true
            self.currentView = self.byPatternView
        }
        self.containerView.addSubview(self.currentView)
        
        setCurrentStatus(preStatus)
        self.currentView.maskImageView.addGestureRecognizer(self.swipGesLeft)
        self.currentView.maskImageView.addGestureRecognizer(self.swipGesRight)
    }
    
    func initHighlightedView(index : Int){
        setViewTitleColor(index)
        
        containerView.addSubview(currentView)
        self.currentView.maskImageView.addGestureRecognizer(self.swipGesLeft)
        self.currentView.maskImageView.addGestureRecognizer(self.swipGesRight)
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
 }
 
 extension AddClothByCameraViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate, AddByCameraEditViewControllerDelegate, AddByCameraScanViewControllerDelegate{
    func showScanning(show : Bool){
        scanImageView.removeFromSuperview()
        scanImageView.layer.removeAllAnimations()
        scanImageView.userInteractionEnabled = true
        scanImageView.clipsToBounds = true
        scanImageView.contentMode = .ScaleAspectFill
        scanImageView.frame = view.bounds
        scanImageView.image = UIImage(named: "PhotoScan")
        
        let rect = CGRectMake(0, -scanImageView.frame.size.height, scanImageView.frame.size.width, scanImageView.frame.size.height - 98)
        scanImageView.frame = rect
        if show{
            view.addSubview(scanImageView)
            UIView.animateWithDuration(1.2, delay: 0, options:[.Repeat], animations: {
                self.scanImageView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height)
                }, completion: nil)
        }
    }
    
    func getAlbumPoster(theBtn : UIButton) {
        let completion = { (theImage : UIImage?) -> Void in
            theBtn.setImage(theImage, forState: .Normal)
        }
        DJAblumOperation.getAlbumPoster(completion)
    }
    
    func albumBtnDidTapped(){
        DJStatisticsLogic.instance().addTraceLog(.Photo_Click_Album)
        
        if !DJConfigDataContainer.instance().checkPermissionForKey(kDJAlbumPermissionIdentifier){
            DJConfigDataContainer.instance().showEnableAccessAlertViewForKey(kDJAlbumPermissionIdentifier, withViewDelegate: nil)
        }
        DJAblumOperation.choosePicture(self)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let img = info[UIImagePickerControllerOriginalImage] {
            
            var vc : AddByCameraEditViewController?
            if currentView == byPhotoView{
                vc = AddByCameraEditViewController(templateId: byPhotoView.templateId, theImage: img as! UIImage, fromPattern: false)
            }else{
                vc = AddByCameraEditViewController(templateId: nil, theImage: img as! UIImage, fromPattern: true)
            }
            vc!.delegate = self
            navigationController?.pushViewController(vc!, animated: true)
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                self.setCurrentStatus(.Editing)
            }
        }
    }
    
    func addByCameraEditViewControllerDidBack(addByCameraEditViewController: AddByCameraEditViewController) {
        setCurrentStatus(.Capturing)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func addByCameraEditViewControllerDone(addByCameraEditViewController: AddByCameraEditViewController, templateIndex: String?, theImage: UIImage, frame: CGRect, croppedImage: UIImage, isInPattern: Bool) {
        
        setCurrentStatus(.Scanning)
        if !isInPattern{
            if currentView != byPhotoView{
                updateHighlightedView(0)
            }
            byPhotoView.setSelectedMaskWithId(templateIndex)
            byPhotoView.croppedImage = croppedImage
            sendByPhotoInitNetTask()
        }else{
            if currentView != byPatternView{
                updateHighlightedView(1)
            }
            byPatternView.croppedImage = croppedImage
            sendByPatternInitNetTask()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            self.removeViewControllerFromStack(addByCameraEditViewController)
        }
        
        gotoScanningWith(theImage, selectedImageFrame: frame)
    }
    
    func addByCameraScanViewControllerDidCancel(addByCameraScanViewController: AddByCameraScanViewController) {
        addByCameraScanViewController.navigationController?.popViewControllerAnimated(true)
        MONetTaskQueue.instance().cancelTask(self.byPhotoInitNetTask)
        MONetTaskQueue.instance().cancelTask(self.byPatternNetTask)
        setCurrentStatus(.Capturing)
    }
 }
 
 extension AddClothByCameraViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(containerView)
        containerView.frame = self.view.bounds
        
        questionLabel.addTapGestureTarget(self, action: #selector(hintBtnDidClicked))
        questionLabel.withFontHeletica(24).withText("?").withTextColor(UIColor(fromHexString: "f1f1f1"))
        view.addSubview(questionLabel)
        questionLabel.textAlignment = .Center
        constrain(questionLabel) { questionLabel in
            questionLabel.top == questionLabel.superview!.top + 20
            questionLabel.right == questionLabel.superview!.right - 15
        }
        
        swipGesRight = UISwipeGestureRecognizer(target: self, action: #selector(AddClothByCameraViewController.swipeGesture(_:)))
        swipGesRight.delegate = self
        swipGesRight.direction = .Right
        
        swipGesLeft = UISwipeGestureRecognizer(target: self, action: #selector(AddClothByCameraViewController.swipeGesture(_:)))
        swipGesLeft.delegate = self
        swipGesLeft.direction = .Left
        
        let bottomView = buildBottomView()
        blurView.frame = CGRectMake(0, 0, view.frame.size.width, bottomView.frame.origin.y)
        
        byPhotoView.delegate = self
        currentView = byPhotoView
        initHighlightedView(0)
        
        if !DJConfigDataContainer.instance().checkPermissionForKey(kDJCameraPermissionIdentifier){
            DJConfigDataContainer.instance().showAccessAlertViewForKey(kDJCameraPermissionIdentifier)
        }
        
        if !ClothesDataContainer.sharedInstance.checkKeyTagged("AddClothesHintView") {
            ClothesDataContainer.sharedInstance.tagKey("AddClothesHintView")
            let hintView = CameraHintView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
            view.addSubview(hintView)
        }
        setCurrentStatus(.Capturing)
    }
    
    func buildBottomView() -> UIView{
        let bottomView = UIView(frame: CGRectMake(0, view.frame.size.height - 113, view.frame.size.width, 113))
        view.addSubview(bottomView)
        bottomView.backgroundColor = UIColor.defaultBlack()
        
        bottomView.addSubview(topPatternBtn)
        bottomView.addSubview(topPhotoBtn)
        topPhotoBtn.addTarget(self, action: #selector(AddClothByCameraViewController.topBtnDidTapped(_:)), forControlEvents: .TouchUpInside)
        topPatternBtn.addTarget(self, action: #selector(AddClothByCameraViewController.topBtnDidTapped(_:)), forControlEvents: .TouchUpInside)
        topPhotoBtn.withTitle(DJStringUtil.localize("Photo", comment:"")).withFontHeleticaMedium(15)
        topPatternBtn.withTitle(DJStringUtil.localize("Pattern", comment:"")).withFontHeleticaMedium(15)
        topPhotoBtn.sizeToFit()
        topPatternBtn.sizeToFit()
        let totalWidth = topPhotoBtn.frame.size.width + 34 + topPatternBtn.frame.size.width
        topPhotoBtn.frame = CGRectMake(view.frame.size.width / 2 - totalWidth / 2, 6, topPhotoBtn.frame.size.width, topPhotoBtn.frame.size.height)
        topPatternBtn.frame = CGRectMake(CGRectGetMaxX(topPhotoBtn.frame) + 34, 6, topPatternBtn.frame.size.width, topPatternBtn.frame.size.height)
        
        
        albumBtn.addTarget(self, action: #selector(AddClothByCameraViewController.albumBtnDidTapped), forControlEvents: .TouchUpInside)
        bottomView.addSubview(albumBtn)
        getAlbumPoster(albumBtn)
        albumBtn.frame = CGRectMake(21, bottomView.frame.size.height - 50 - 18, 50, 50)
        
        let captureBtn = UIButton(frame: CGRectMake(view.frame.size.width / 2 - 30.5, 40, 61, 61))
        captureBtn.setImage(UIImage(named: "BigWhiteCamera"), forState: .Normal)
        captureBtn.addTarget(self, action: #selector(AddClothByCameraViewController.takePhotoDidPressed), forControlEvents: .TouchUpInside)
        bottomView.addSubview(captureBtn)
        
        
        let cancelBtn = UIButton()
        cancelBtn.withTitle(DJStringUtil.localize("Cancel", comment:"")).withFontHeleticaMedium(15).withTitleColor(UIColor(fromHexString: "f1f1f1"))
        cancelBtn.addTarget(self, action: #selector(AddClothByCameraViewController.cancelBtnDidTapped), forControlEvents: .TouchUpInside)
        bottomView.addSubview(cancelBtn)
        cancelBtn.sizeToFit()
        cancelBtn.frame = CGRectMake(bottomView.frame.size.width - cancelBtn.frame.size.width - 23, bottomView.frame.size.height - cancelBtn.frame.size.height - 25, cancelBtn.frame.size.width, cancelBtn.frame.size.height)
        
        return bottomView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        byPhotoView.frame = view.bounds
        byPatternView.frame = view.bounds
    }
    
 }
 
 
