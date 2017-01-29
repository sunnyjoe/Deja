//
//  DJAboutViewController.swift
//  DejaFashion
//
//  Created by Sunny XiaoQing on 28/7/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

import Foundation

//let kDJAboutFBFollowBtnTag = 1000
//let kDJAboutInstagramFollowBtnTag = 1001
//let kDJAboutTwitterFollowBtnTag = 1002
//let kDJAboutWeiboFollowBtnTag = 1003

class DJAboutViewController : DJBasicViewController {
    private var cellBuilders : [MOTableCellBuilder] = []
    var appNameLabel : UILabel = UILabel()
    var fullAppVersion : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DJStringUtil.localize("About Deja", comment: "")

        self.view.addSubview(self.contentView());
    }
    
    func contentView() -> UIView{
        let headerView = UIView(frame: self.view.bounds)
        
        let logoImage :UIImage? = UIImage(named: "AboutLogo")
        let logoImageView = UIImageView()
        if logoImage != nil {
            logoImageView.frame = CGRectMake((headerView.frame.size.width - logoImage!.size.width) / 2, 40, logoImage!.size.width,logoImage!.size.height)
        }
        logoImageView.image = logoImage
        headerView.addSubview(logoImageView)
        
        self.appNameLabel.frame = CGRectMake(0, logoImageView.frame.origin.y + logoImageView.frame.size.height + 10, headerView.frame.size.width, 18)
        self.appNameLabel.addTapGestureTarget(self, action: #selector(DJAboutViewController.headerViewDidTap))
        self.appNameLabel.textAlignment = NSTextAlignment.Center;
        self.appNameLabel.font = DJFont.contentFontOfSize(17);
        self.appNameLabel.textColor = DJCommonStyle.ColorRed
        
        let str1: NSString? = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        if str1 != nil{
            self.appNameLabel.text = "V\(str1!)"
        }
        headerView.addSubview(self.appNameLabel)
        /*
        let totalWidth = 30 + 20 + 30 as CGFloat;
        
        let fbFollowBtn = UIButton(frame:CGRectMake(self.view.frame.width / 2 - totalWidth / 2, self.view.frame.height - 220, 30, 30))
        fbFollowBtn.tag = kDJAboutFBFollowBtnTag;
        fbFollowBtn.addTarget(self, action:#selector(DJAboutViewController.followBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        fbFollowBtn.setBackgroundImage(UIImage(named: "FBFollowIcon"), forState:UIControlState.Normal)
        fbFollowBtn.setBackgroundImage(UIImage(named: "FBFollowIconPressed"), forState: UIControlState.Highlighted)
//        headerView.addSubview(fbFollowBtn)
        
        let insFollowBtn = UIButton(frame:CGRectMake(CGRectGetMaxX(fbFollowBtn.frame) + 20, self.view.frame.height - 220, 30, 30))
        insFollowBtn.tag = kDJAboutInstagramFollowBtnTag;
        insFollowBtn.addTarget(self, action:#selector(DJAboutViewController.followBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        insFollowBtn.setBackgroundImage(UIImage(named: "InstagramFollowIcon"), forState:UIControlState.Normal)
        insFollowBtn.setBackgroundImage(UIImage(named: "InstagramFollowIconPressed"), forState: UIControlState.Highlighted)
//        headerView.addSubview(insFollowBtn)
        
        let copyRightLabel = UILabel(frame: CGRectMake(0, self.view.frame.height - 150 , headerView.frame.size.width, 50))
        copyRightLabel.textAlignment = NSTextAlignment.Center
        copyRightLabel.font = DJFont.contentFontOfSize(14)
        copyRightLabel.textColor = UIColor(fromHexString:"818181")
        copyRightLabel.numberOfLines = 2
        copyRightLabel.text = DJStringUtil.localize("Copyright@2015 Deja Fashion Pte Ltd.\nAll rights reserved.", comment: "");
        copyRightLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(DJAboutViewController.debug_info)))
        copyRightLabel.userInteractionEnabled = true
        headerView.addSubview(copyRightLabel)
        
        let emailLabel = UILabel(frame: CGRectMake(0, insFollowBtn.frame.origin.y + insFollowBtn.frame.size.height + 14, self.view.frame.size.width, 16))
//        let emailAddress = NSKeyedUnarchiver.unarchiveObjectWithData(DJConfigDataContainer.instance().configFeedbackEmail.originalData) as! String
        
//        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: emailAddress)
//        attributeString.addAttribute(NSUnderlineStyleAttributeName, value:NSNumber(int: 1), range:NSMakeRange(0, attributeString.length))
        
        emailLabel.textAlignment = NSTextAlignment.Center;
        emailLabel.font = DJFont.contentFontOfSize(14)
        emailLabel.textColor = DJCommonStyle.ColorRed
//        emailLabel.attributedText = attributeString;
        emailLabel.userInteractionEnabled = true;
        emailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DJAboutViewController.emailLabelDidTap)))
        headerView.addSubview(emailLabel)

 */
        return headerView;
    }
    
    
    var tapCount = 0
    func headerViewDidTap() {
        tapCount += 1
        if tapCount >= 8 && !debugMode{
            MBProgressHUD.showHUDAddedTo(self.view, text: "DEBUG MODE ON", animated: true)
            debugMode = true
        }
        
        self.fullAppVersion = !self.fullAppVersion;
        
        var version: NSString? = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let budVerion: NSString? = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        if version == nil {
            return
        }
        if budVerion == nil {
            return
        }
        if self.fullAppVersion {
            version = "\(version!).\(budVerion!)"
        }
        
        if let uid = AccountDataContainer.sharedInstance.userID {
            version = (version! as String) + "/" +  uid
        }
        
        self.appNameLabel.text = "V\(version!)"
    }
    
    func debug_info() {
        let text = NSUserDefaults.standardUserDefaults().stringForKey("debug_info")
        if text?.characters.count > 0 {
            MBProgressHUD.showHUDAddedTo(self.view, text: NSUserDefaults.standardUserDefaults().stringForKey("debug_info"), animated: true)
        }
    }
    
    /*
    
    func emailLabelDidTap(){
        let email = NSKeyedUnarchiver.unarchiveObjectWithData(DJConfigDataContainer.instance().configFeedbackEmail.originalData) as! String
        let emailTo = "mailto:\(email)"
        let mailToURL : NSURL? = NSURL(string: emailTo)
        if mailToURL == nil {
            return
        }
        
        if UIApplication.sharedApplication().canOpenURL(mailToURL!) {
            UIApplication.sharedApplication().openURL(mailToURL!)
        }
    }

    func followBtnDidTap(followBtn: UIButton){
        var urlObj = [String:String]()
        switch followBtn.tag {
        case kDJAboutFBFollowBtnTag :
            urlObj = NSKeyedUnarchiver.unarchiveObjectWithData(DJConfigDataContainer.instance().configFacebookUrl.originalData) as! Dictionary
            
        case kDJAboutInstagramFollowBtnTag :
            urlObj = NSKeyedUnarchiver.unarchiveObjectWithData(DJConfigDataContainer.instance().configInstagramUrl.originalData) as! Dictionary
        
        case kDJAboutTwitterFollowBtnTag :
            urlObj = NSKeyedUnarchiver.unarchiveObjectWithData(DJConfigDataContainer.instance().configTwitterUrl.originalData) as! Dictionary
            
        case kDJAboutWeiboFollowBtnTag :
            urlObj = NSKeyedUnarchiver.unarchiveObjectWithData(DJConfigDataContainer.instance().configWeiboUrl.originalData) as! Dictionary
            
        default:
            break
        }
        if urlObj["native_url"] == nil {
            return
        }
        var mailToURL : NSURL? = NSURL(string: urlObj["native_url"]!)
        if mailToURL == nil {
            return
        }
        if UIApplication.sharedApplication().canOpenURL(mailToURL!) {
            UIApplication.sharedApplication().openURL(mailToURL!)
        }else{
            if urlObj["url"] == nil {
                return
            }
            mailToURL = NSURL(string: urlObj["url"]!)
            if mailToURL == nil {
                return
            }
             UIApplication.sharedApplication().openURL(mailToURL!)
        }
        
    }
 */
}
