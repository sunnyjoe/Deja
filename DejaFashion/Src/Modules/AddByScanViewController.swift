//
//  AddByScanViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 7/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

enum AddByScanStatus {
    case Pause
    case Capturing
    case Scanning
    case ClothDetail
    case MultiChoice
}

class AddByScanViewController: DJBasicViewController, MONetTaskDelegate {
    static var sharedInstance = AddByScanViewController()
    
    private let cameraView = CameraView()
    private let albumBtn = UIButton()
    private var scanningVC : AddByCameraScanViewController?
    private var upNetTask = GetProductByTagNetTask()
    private let questionLabel = UILabel()
    private var currentStatus = AddByScanStatus.Pause
    
    let bottomView = UIView()
    var demoView : UIView?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        resetCameraWhenAppear()
        getAlbumPoster()
        
        if ClothesDataContainer.sharedInstance.isFirstTimeUseScan(){
            self.showHintView()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        cameraView.switchCamera(false)
    }
    
    func resetCameraWhenAppear(){
        switch currentStatus {
        case .Capturing, .ClothDetail:
            setCurrentStatus(.Capturing)
        default:
            cameraView.switchCamera(false)
        }
    }
    
    func setCurrentStatus(status : AddByScanStatus){
        switch status {
        case .Capturing:
            cameraView.switchCamera(true)
            
            // if !ClothesDataContainer.sharedInstance.scanHasEnteredClothDetail(){
            addDemoView()
        // }
        default:
            if let tmp = demoView{
                tmp.removeFromSuperview()
            }
            cameraView.switchCamera(false)
        }
        
        currentStatus = status
    }
    
    func albumBtnDidTapped(){
        DJStatisticsLogic.instance().addTraceLog(.Pricetag_Click_Album)
        DJAblumOperation.choosePicture(self)
    }
    
    func takePhotoDidPressed(){
        DJStatisticsLogic.instance().addTraceLog(.Pricetag_Click_Shot)
        let afterCapture = {
            if let theImage = self.cameraView.capturedImage {
                self.beginScanImage(theImage)
                DJAblumOperation.saveImageToAlbum(theImage)
            }else{
                self.setCurrentStatus(.Capturing)
            }
        }
        cameraView.capturePhoto(afterCapture)
    }
    
    func beginScanImage(theImage : UIImage, switchAnimate : Bool = true){
        setCurrentStatus(.Scanning)
        
        upNetTask.imageData = UIImageJPEGRepresentation(theImage, 0.4)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: upNetTask.uri())
        MONetTaskQueue.instance().addTask(upNetTask)
        
        scanningVC = AddByCameraScanViewController(theImage: theImage, maskImage: nil, imageFrame: view.bounds)
        scanningVC?.delegate = self
        navigationController?.pushViewController(scanningVC!, animated: switchAnimate)
        
    }
    
    func demoDidClicked(){
        if let demo = UIImage(named: "SampleTag"){
            beginScanImage(demo)
        }
    }
    
    func gotoClothDetailPage(cloth : Clothes){
        HistoryDataContainer.sharedInstance.addClothesToHistory(cloth)
        
        let url = ConfigDataContainer.sharedInstance.getClothDetailUrl(cloth.uniqueID!)
        let vc = ClothDetailViewController(URLString: url)
        //        vc.fromFunction = from_add_cloth_by_Scan_Tag
        viewWillDisappear(true)
        navigationController?.pushViewController(vc, animated: true)
        
        ClothesDataContainer.sharedInstance.scanHasEnteredClothDetail(true)
        demoView?.removeFromSuperview()
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == upNetTask{
            setCurrentStatus(.Pause)
            
            var showNoResult = true
            if let pdts = upNetTask.productInfo{
                if pdts.count >= 1{
                    showNoResult = false
                    if pdts.count > 1{
                        scanningVC?.navigationController?.popViewControllerAnimated(false)
                        setCurrentStatus(.MultiChoice)
                        showResultView(pdts)
                    }else{
                        setCurrentStatus(.ClothDetail)
                        gotoClothDetailPage(pdts[0])
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                            self.removeViewControllerFromStack(self.scanningVC)
                        }
                    }
                }
            }
            
            if showNoResult {
                scanningVC?.navigationController?.popViewControllerAnimated(false)
                //                DJStatisticsLogic.instance().addTraceLog(kStatisticsID_scan_result_ErrorPage)
                if let tmp = upNetTask.retType {
                    switch tmp {
                    case .NotClear:
                        showImageNotClearView()
                    case .NotSupportBrand:
                        showNotSupportBrandView()
                    default:
                        showNotFoundView()
                    }
                }
            }
            
            
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == upNetTask{
            scanningVC?.navigationController?.popViewControllerAnimated(false)
            setCurrentStatus(.Capturing)
            if debugMode{
                let tmp = DJAlertView.init(title: DJStringUtil.localize("Opps", comment:""), message: "\(task.error)", cancelButtonTitle: DJStringUtil.localize("Ok", comment:""))
                tmp.show()
            }
        }
    }
    
    func showNotSupportBrandView(){
        let nrView = ScanTagNoBrandView(frame : getRealViewBounds())
        view.addSubview(nrView)
        nrView.setCloseSelector(self, sel: #selector(AddByScanViewController.hideResultView))
        nrView.showAnimation()
    }
    
    func showImageNotClearView(){
        let nrView = ScanTagNotClearView(frame : getRealViewBounds())
        view.addSubview(nrView)
        nrView.setCloseSelector(self, sel: #selector(AddByScanViewController.hideResultView))
        nrView.showAnimation()
    }
    
    func showNotFoundView(){
        let nrView = ScanTagNoResultView(frame : getRealViewBounds())
        view.addSubview(nrView)
        nrView.setCloseSelector(self, sel: #selector(AddByScanViewController.hideResultView))
        nrView.showAnimation()
    }
    
    func getRealViewBounds() -> CGRect{
        var rect = view.bounds
        if let nav = navigationController{
            if nav.navigationBarHidden{
                rect = nav.view.bounds
            }
        }
        return rect
    }
    
    func showResultView(pdt : [Clothes]){
        //        DJStatisticsLogic.instance().addTraceLog(.Findresult_appear)
        let ccv = ClothMultiColorsView(frame: getRealViewBounds(), pdt: pdt)
        ccv.delegate = self
        
        view.addSubview(ccv)
        ccv.setCloseSelector(self, sel: #selector(AddByScanViewController.hideResultView))
        ccv.showAnimation()
    }
    
    func hideResultView(){
        setCurrentStatus(.Capturing)
        
        var results : PullUpHideShowBasicView?
        for view in self.view.subviews{
            if view.isKindOfClass(PullUpHideShowBasicView){
                results = (view as! PullUpHideShowBasicView)
                break
            }
        }
        if results != nil {
            results!.hideAnimation()
        }
    }
}

extension AddByScanViewController : ClothMultiColorsViewDelegate{
    func clothMultiColorsViewDidChooseProduct(clothMultiColorsView : ClothMultiColorsView, selectedClothes : Clothes){
        //  clothMultiColorsView.hideAnimation()
        gotoClothDetailPage(selectedClothes)
    }
}

extension AddByScanViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate, AddByCameraScanViewControllerDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(cameraView)
        
        let topBGView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 60))
        view.addSubview(topBGView)
        topBGView.backgroundColor = UIColor.defaultBlack()
        //  topBGView.addSubview(cameraView.flipBtn)
        topBGView.addSubview(cameraView.flashBtn)
        
        questionLabel.addTapGestureTarget(self, action: #selector(AddByScanViewController.questionDidTapped))
        questionLabel.withFontHeletica(24).withText("?").withTextColor(UIColor(fromHexString: "f1f1f1"))
        topBGView.addSubview(questionLabel)
        questionLabel.textAlignment = .Center
        
        constrain(questionLabel) { questionLabel in
            questionLabel.top == questionLabel.superview!.top + 13
            questionLabel.right == questionLabel.superview!.right - 5
        }
        NSLayoutConstraint(item: questionLabel, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: 45).active = true
        NSLayoutConstraint(item: questionLabel, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
                           attribute: .NotAnAttribute,  multiplier: 1,  constant: 40).active = true
        
        buildBottomView()
        
        setCurrentStatus(.Capturing)
    }
    
    func addDemoView(){
        let created = (demoView != nil) ? true : false
        
        if demoView == nil {
            demoView = UIView()
            demoView!.addTapGestureTarget(self, action: #selector(demoDidClicked))
        }
        
        view.addSubview(demoView!)
        constrain(demoView!, bottomView) { demoView, bottomView in
            demoView.bottom == bottomView.top
            demoView.left == demoView.superview!.left
            demoView.right == demoView.superview!.right
        }
        NSLayoutConstraint(item: demoView!, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: 50).active = true
        
        if created{
            return
        }
        
        demoView!.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.7)
        
        let imageV = UIImageView()
        imageV.image = UIImage(named: "SampleTagIcon")
        demoView!.addSubview(imageV)
        constrain(imageV) { imageV in
            imageV.left == imageV.superview!.left + 22.5
            imageV.centerY == imageV.superview!.centerY
        }
        NSLayoutConstraint(item: imageV, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: 35).active = true
        NSLayoutConstraint(item: imageV, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: 35).active = true
        
        let infoLabel = UILabel()
        demoView!.addSubview(infoLabel)
        infoLabel.withText(DJStringUtil.localize("Click to try our sample price tag.", comment:"")).withFontHeletica(14).withTextColor(UIColor.whiteColor())
        constrain(infoLabel, imageV) { infoLabel, imageV in
            infoLabel.left == imageV.right + 5
            infoLabel.centerY == infoLabel.superview!.centerY - 3
        }
        
        
        //        let closeBtn = UIButton()
        //        closeBtn.setImage(UIImage(named: "WhiteCloseIcon"), forState: .Normal)
        //        closeBtn.addTarget(self, action: #selector(demoDidClickClose), forControlEvents: .TouchUpInside)
        //        demoView!.addSubview(closeBtn)
        //        constrain(closeBtn) { closeBtn in
        //            closeBtn.right == closeBtn.superview!.right - 22.5
        //            closeBtn.centerY == closeBtn.superview!.centerY
        //        }
        //        NSLayoutConstraint(item: closeBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
        //                           attribute: .NotAnAttribute, multiplier: 1, constant: 19).active = true
        //        NSLayoutConstraint(item: closeBtn, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: nil,
        //                           attribute: .NotAnAttribute, multiplier: 1, constant: 23).active = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        cameraView.frame = view.bounds
    }
    
    func demoDidClickClose(){
        demoView!.removeFromSuperview()
    }
    
    func questionDidTapped(){
        DJStatisticsLogic.instance().addTraceLog(.Pricetag_Click_Help)
        showHintView()
    }
    
    func showHintView(){
        let hintView = ScanHintView(frame: CGRectMake(0, 20, view.frame.size.width, view.frame.size.height - 20))
        view.addSubview(hintView)
        hintView.scaleShowAnimation(hintView.frame, startWidth: 2, time: 0.3, alpha: true, completion: nil)
        //UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    func addByCameraScanViewControllerDidCancel(addByCameraScanViewController: AddByCameraScanViewController) {
        navigationController?.popViewControllerAnimated(true)
        setCurrentStatus(.Capturing)
        MONetTaskQueue.instance().cancelTask(upNetTask)
    }
    
    func buildBottomView(){
        view.addSubview(bottomView)
        bottomView.backgroundColor = UIColor.defaultBlack()
        
        constrain(bottomView) { bottomView in
            bottomView.top == bottomView.superview!.bottom - 92.5
            bottomView.bottom == bottomView.superview!.bottom
            bottomView.left == bottomView.superview!.left
            bottomView.right == bottomView.superview!.right
        }
        
        let sideWidth : CGFloat = 50
        albumBtn.clipsToBounds = true
        getAlbumPoster()
        albumBtn.addTarget(self, action: #selector(AddByScanViewController.albumBtnDidTapped), forControlEvents: .TouchUpInside)
        bottomView.addSubview(albumBtn)
        constrain(albumBtn) { albumBtn in
            albumBtn.left == albumBtn.superview!.left + 22.5
            albumBtn.centerY == albumBtn.superview!.centerY
        }
        NSLayoutConstraint(item: albumBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: sideWidth).active = true
        NSLayoutConstraint(item: albumBtn, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
                           attribute: .NotAnAttribute,  multiplier: 1,  constant: sideWidth).active = true
        
        let captureBtn = UIButton()
        captureBtn.setImage(UIImage(named: "BigWhiteCamera"), forState: .Normal)
        captureBtn.addTarget(self, action: #selector(AddByScanViewController.takePhotoDidPressed), forControlEvents: .TouchUpInside)
        bottomView.addSubview(captureBtn)
        constrain(captureBtn) { captureBtn in
            captureBtn.centerX == captureBtn.superview!.centerX
            captureBtn.centerY == captureBtn.superview!.centerY
        }
        NSLayoutConstraint(item: captureBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: 61).active = true
        NSLayoutConstraint(item: captureBtn, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
                           attribute: .NotAnAttribute,  multiplier: 1,  constant: 61).active = true
        
        let cancelBtn = UIButton()
        cancelBtn.withTitle(DJStringUtil.localize("Cancel", comment:"")).withFontHeleticaMedium(15).withTitleColor(UIColor(fromHexString: "f1f1f1"))
        cancelBtn.addTarget(self, action: #selector(AddByScanViewController.cancelBtnDidTapped), forControlEvents: .TouchUpInside)
        bottomView.addSubview(cancelBtn)
        constrain(cancelBtn) { cancelBtn in
            cancelBtn.right == cancelBtn.superview!.right - 20
            cancelBtn.centerY == cancelBtn.superview!.centerY
        }
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
                           attribute: .NotAnAttribute, multiplier: 1, constant: sideWidth).active = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
                           attribute: .NotAnAttribute,  multiplier: 1,  constant: sideWidth).active = true
    }
    
    func cancelBtnDidTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getAlbumPoster(){
        let completion = { (thePoster : UIImage?) -> Void in
            self.albumBtn.setImage(thePoster, forState: .Normal)
        }
        DJAblumOperation.getAlbumPoster(completion)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(false, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] {
            if let tmp = image as? UIImage{
                beginScanImage(tmp, switchAnimate: false)
            }
        }
    }
}
