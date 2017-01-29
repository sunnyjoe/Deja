//
//  CameraView.swift
//  DejaFashion
//
//  Created by jiao qing on 1/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
import AVFoundation


class CameraView: UIView {
    private let camFucView = UIView()
    
    let flipBtn = UIButton()
    let flashBtn = UIButton()
    
    var previewLayer : AVCaptureVideoPreviewLayer!
    let maskImageView = UIImageView()
    private var maskImage : UIImage?
    
    private lazy var captureDevice = {
        return AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    }()
    private let session = AVCaptureSession()
    private let stillImageOutPut = AVCaptureStillImageOutput()
    
    var capturedImage : UIImage?
    var croppedImage : UIImage?
    var cropMask : UIImage?
    var mask : UIImage? {
        set {
            maskImage = newValue
            if maskImage != nil{
                maskImageView.image = maskImage!
            }
        }
        get {
            return maskImage
        }
    }
    var useFlash = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   
        if captureDevice == nil {
            print("No camera")
            return
        }
        backgroundColor = UIColor.whiteColor()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.layer.addSublayer(previewLayer)
        addSubview(maskImageView)
        
        maskImageView.userInteractionEnabled = true
        maskImageView.contentMode = .ScaleAspectFill
        maskImageView.addTapGestureTarget(self, action: #selector(CameraView.didTapMaskView(_:)))
        
        flipBtn.setImage(UIImage(named: "CameraFlipNormal"), forState: .Normal)
        flipBtn.addTarget(self, action: #selector(CameraView.flipBtnDidClicked), forControlEvents: .TouchUpInside)
        
        flashBtn.contentMode = .Center
        flashBtn.setImage(UIImage(named: "CameraFlashOffNormal"), forState: .Normal)
        flashBtn.addTarget(self, action: #selector(CameraView.flashBtnDidClicked), forControlEvents: .TouchUpInside)
        // camFucView.addSubview(flipBtn)
        camFucView.addSubview(flashBtn)
        camFucView.userInteractionEnabled = true
        
        //flipBtn.frame = CGRectMake(19, 25, 29, 24)
        flashBtn.frame = CGRectMake(19, 25, 22, 24)
        
        addSubview(camFucView)
        
        reInitCamera()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if previewLayer == nil {
            return
        }
        previewLayer.frame = CGRectMake(0, frame.size.height - UIScreen.mainScreen().bounds.height, frame.size.width, UIScreen.mainScreen().bounds.height)
        maskImageView.frame = previewLayer.frame
        
        camFucView.frame = CGRectMake(0, 0, frame.size.width, 45)
    }
    
    func didTapMaskView(tapGS : UITapGestureRecognizer){
        if !session.running{
            return
        }
        do {
            if captureDevice.isFocusModeSupported(.AutoFocus) {
                try captureDevice.lockForConfiguration()
                let focus_x = tapGS.locationInView(maskImageView).x / maskImageView.frame.size.width
                let focus_y = tapGS.locationInView(maskImageView).y / maskImageView.frame.size.height
                // print("\(focus_x) \(focus_y)")
                captureDevice.focusPointOfInterest = CGPointMake(focus_y, focus_x)
                captureDevice.focusMode = AVCaptureFocusMode.AutoFocus
                captureDevice.unlockForConfiguration()
            }
        } catch {
            print(error)
        }
    }
    
    func switchCamera(open : Bool){
        if open && !session.running {
            session.startRunning()
            switchFlash(useFlash)
        }else if (!open) && session.running{
            session.stopRunning()
        }
    }
    
    func flipBtnDidClicked(){
        if !session.running{
            return
        }
        reInitCamera()
    }
    
    func flashBtnDidClicked(){
        useFlash = !useFlash
        switchFlash(useFlash)
    }
    
    func capturePhoto(completion : (() -> Void)?){
        var videoCoonection : AVCaptureConnection?
        
        for connection in stillImageOutPut.connections{
            let connectionAV = connection as! AVCaptureConnection
            for port in connectionAV.inputPorts{
                let portAV = port as! AVCaptureInputPort
                if portAV.mediaType == AVMediaTypeVideo {
                    videoCoonection = connectionAV
                    break
                }
            }
            if videoCoonection != nil{
                break
            }
        }
        
        if videoCoonection == nil{
            return
        }
        
        stillImageOutPut.captureStillImageAsynchronouslyFromConnection(videoCoonection){
            (imageSampleBuffer : CMSampleBuffer!, _) in
            if imageSampleBuffer == nil{
                return
            }
            
            let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
            if let oriImage = UIImage(data: imageDataJpeg){
                let jpgImage = UIImage.correctCameraImage(oriImage)
                if self.captureDevice.position == .Back{
                    self.capturedImage = jpgImage
                    self.cropImage(jpgImage)
                }else{
                    let newSize = CGSizeMake(jpgImage.size.width * jpgImage.scale, jpgImage.size.height * jpgImage.scale)
                    
                    //rotate and flip image
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
                    let context = UIGraphicsGetCurrentContext()!
                    CGContextTranslateCTM(context, 0, newSize.height)
                    CGContextScaleCTM(context, 1, -1);
                    
                    CGContextTranslateCTM(context, newSize.width, 0);
                    CGContextScaleCTM(context, -1, 1);
                    
                    CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), jpgImage.CGImage!)
                    let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    self.capturedImage = resultImage
                    self.cropImage(resultImage)
                }
            }
            if completion != nil{
                completion!()
            }
        }
    }
    
    private func afterCaptureImage(){
        switchCamera(false)
    }
 
    private func cropImage(capImage : UIImage){
        if  mask == nil || cropMask == nil{
            return
        }
        
        let capCG = capImage.CGImage!
        let maskCG = cropMask!.CGImage!
        
        let maskRect = CGRectMake(0, 0, cropMask!.size.width * cropMask!.scale, cropMask!.size.height * cropMask!.scale)
        
        UIGraphicsBeginImageContext(maskRect.size)
        let context = UIGraphicsGetCurrentContext()!
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -maskRect.size.height);
        CGContextSetBlendMode(context, CGBlendMode.SourceOut)
        CGContextDrawImage(context, maskRect, maskCG)
        CGContextDrawImage(context, maskRect, capCG)
        croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        afterCaptureImage()
    }
    
    private func reInitCamera() {
        if session.inputs.count == 0 {
            do{
                let input = try AVCaptureDeviceInput(device: captureDevice)
                session.addInput(input)
                stillImageOutPut.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                session.addOutput(stillImageOutPut)
            }catch{}
        }else{
            let currentCameraInput: AVCaptureInput = session.inputs[0] as! AVCaptureInput
            session.removeInput(currentCameraInput)
            
            let newCamera: AVCaptureDevice?
            if(captureDevice!.position == .Back){
                newCamera = cameraWithPosition(.Front)
            } else {
                newCamera = cameraWithPosition(.Back)
            }
            
            do{
                let newVideoInput = try AVCaptureDeviceInput(device: newCamera!)
                session.addInput(newVideoInput)
            }catch{}
            
            session.commitConfiguration()
            captureDevice! = newCamera!
        }
        
        flashBtn.hidden = !captureDevice.hasTorch
    }
    
    func switchFlash(on : Bool){
        if !session.running{
            return
        }
        if captureDevice == nil {
            return
        }
        if (!captureDevice.hasTorch) {
            return
        }
        
        do {
            try captureDevice.lockForConfiguration()
            if (on) {
                try captureDevice.setTorchModeOnWithLevel(1.0)
                flashBtn.setImage(UIImage(named: "CameraFlashOnNormal"), forState: .Normal)
                flashBtn.frame = CGRectMake(flashBtn.frame.origin.x, 25, 26, 24)
            } else {
                captureDevice.torchMode = AVCaptureTorchMode.Off
                flashBtn.setImage(UIImage(named: "CameraFlashOffNormal"), forState: .Normal)
                flashBtn.frame = CGRectMake(flashBtn.frame.origin.x, 25, 22, 24)
            }
            captureDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    private func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            if(device.position == position){
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

 
