//
//  AddByCameraScanViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 5/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


protocol AddByCameraScanViewControllerDelegate : NSObjectProtocol{
    func addByCameraScanViewControllerDidCancel(addByCameraScanViewController: AddByCameraScanViewController)
}

class AddByCameraScanViewController: UIViewController {
    private let imageView = UIImageView()
    private let maskImageView = UIImageView()
    private let scanImageView = UIImageView()
    weak var delegate : AddByCameraScanViewControllerDelegate?
    
    private var theImageFrame = CGRectZero
    private var selectedImage : UIImage?
    private var maskImage : UIImage?
    
    init(theImage : UIImage, maskImage : UIImage?, imageFrame : CGRect) {
        super.init(nibName: nil, bundle: nil)
        
        selectedImage = theImage
        self.maskImage = maskImage
        theImageFrame = imageFrame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        
        imageView.contentMode = .ScaleAspectFill
        view.addSubview(imageView)
        imageView.image = selectedImage
        imageView.frame = theImageFrame
            
        maskImageView.image = maskImage
        maskImageView.contentMode = .ScaleAspectFit
        view.addSubview(maskImageView)
        constrain(maskImageView) { maskImageView in
            maskImageView.top == maskImageView.superview!.top
            maskImageView.bottom == maskImageView.superview!.bottom
            maskImageView.left == maskImageView.superview!.left
            maskImageView.right == maskImageView.superview!.right
        }
        
        let bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.9)
        constrain(bottomView) { bottomView in
            bottomView.top == bottomView.superview!.bottom - 46
            bottomView.bottom == bottomView.superview!.bottom
            bottomView.left == bottomView.superview!.left
            bottomView.right == bottomView.superview!.right
        }
        
        let cancelBtn = UIButton()
        cancelBtn.clipsToBounds = true
//        cancelBtn.layer.borderColor = UIColor.whiteColor().CGColor
//        cancelBtn.layer.borderWidth = 1.5
//        cancelBtn.layer.cornerRadius = 17
        cancelBtn.setImage(UIImage(named: "WhiteCloseIcon"), forState: .Normal)
        cancelBtn.addTarget(self, action: #selector(AddByCameraScanViewController.cancelBtnDidTapped), forControlEvents: .TouchUpInside)
        bottomView.addSubview(cancelBtn)
        constrain(cancelBtn) { cancelBtn in
            cancelBtn.centerX == cancelBtn.superview!.centerX
            cancelBtn.centerY == cancelBtn.superview!.centerY
        }
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 36).active = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Width, relatedBy: .Equal,  toItem: nil,
            attribute: .NotAnAttribute,  multiplier: 1,  constant: 36).active = true
        
        scanImageView.image = UIImage(named: "PhotoScan")
        scanImageView.contentMode = .ScaleAspectFill
        view.addSubview(scanImageView)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(scanImageView)
        let viewHeight = view.frame.size.height - 46
        scanImageView.frame = CGRectMake(0, -viewHeight, view.frame.size.width, viewHeight)
        UIView.animateWithDuration(1.2, delay: 0, options:[.Repeat], animations: {
            self.scanImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, viewHeight)
            }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelBtnDidTapped(){
        scanImageView.removeFromSuperview()
        scanImageView.layer.removeAllAnimations()
        delegate?.addByCameraScanViewControllerDidCancel(self)
    }
}
