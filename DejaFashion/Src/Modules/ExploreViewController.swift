//
//  ExploreViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 24/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ExploreViewController: DJBasicViewController {
    
    let bannerView = ScrollableBannerView(frame : CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 257 * kIphoneSizeScale))
    let activity = UIActivityIndicatorView()
    var banners = ConfigDataContainer.sharedInstance.getFindClothBanners()
    override init!() {
        super.init()
        hidesBottomBarWhenPushed = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(bannerDidChanged), name:DJConfigFindClothBannerChanged, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = DJStringUtil.localize("Explore", comment: "")
        view.backgroundColor = UIColor.blackColor()
        
        
        
        bannerView.backgroundColor = UIColor.defaultBlack()
        view.addSubview(bannerView)
        bannerView.addSubview(activity)
        if banners.count == 0 {
            activity.activityIndicatorViewStyle = .White
            activity.center = bannerView.center
            activity.startAnimating()
        }
        updateBannerView()
        
        
//        let inviteButton = buildFuncButton("InviteFriends")
        let dealsButton = buildFuncButton("DealsIcon")
//        let fittingRoomButton = buildFuncButton("FittingRoomIcon")
        let eventsButton = buildFuncButton("EventsIcon")
        let inspirationButton = buildFuncButton("InspirationsIcon")
        let nearByButton = buildFuncButton("NearbyIcon")
        
//        inviteButton.addTarget(self, action: #selector(ExploreViewController.gotoInvite), forControlEvents: .TouchUpInside)
        dealsButton.addTarget(self, action: #selector(ExploreViewController.gotoDeals), forControlEvents: .TouchUpInside)
//        fittingRoomButton.addTarget(self, action: #selector(gotoFittingRoom), forControlEvents: .TouchUpInside)
        eventsButton.addTarget(self, action: #selector(gotoEvents), forControlEvents: .TouchUpInside)
        nearByButton.addTarget(self, action: #selector(gotoNearBy), forControlEvents: .TouchUpInside)
        inspirationButton.addTarget(self, action: #selector(gotoInspiration), forControlEvents: .TouchUpInside)
        
        view.addSubviews(bannerView,inspirationButton, nearByButton, dealsButton, eventsButton)
        
//        constrain(inviteButton, dealsButton) { (inviteButton, dealsButton) in
//            inviteButton.top == dealsButton.superview!.top
//            inviteButton.left == dealsButton.superview!.left
//            inviteButton.width == dealsButton.width
//            inviteButton.height == dealsButton.height
//            
//            dealsButton.top == dealsButton.superview!.top
//            dealsButton.left == inviteButton.right + 5
//            dealsButton.right == dealsButton.superview!.right
//        }
        
        constrain(bannerView, inspirationButton, nearByButton, dealsButton, eventsButton) { (bannerView, inspirationButton, nearByButton, dealsButton, eventsButton) in
//            dealsButton.height == inspirationButton.height
            
            bannerView.top == bannerView.superview!.top
            bannerView.left == bannerView.superview!.left
            bannerView.width == bannerView.superview!.width
            bannerView.height == 257 * kIphoneSizeScale
            
            
            inspirationButton.top == bannerView.bottom + 5
            inspirationButton.left == inspirationButton.superview!.left
            inspirationButton.width == nearByButton.width
            inspirationButton.height == dealsButton.height
            
            nearByButton.top == bannerView.bottom + 5
            nearByButton.left == inspirationButton.right + 5
            nearByButton.right == nearByButton.superview!.right
            nearByButton.height == inspirationButton.height
            
            dealsButton.top == inspirationButton.bottom + 5
            dealsButton.left == dealsButton.superview!.left
            dealsButton.width == eventsButton.width
            dealsButton.bottom == dealsButton.superview!.bottom - 5
            
            eventsButton.top == nearByButton.bottom + 5
            eventsButton.left == dealsButton.right + 5
            eventsButton.right == eventsButton.superview!.right
            eventsButton.bottom == eventsButton.superview!.bottom - 5
        }
        
//        buildContent(inviteButton, info : DJStringUtil.localize("Invite Your Friends", comment: ""), descInfo : DJStringUtil.localize("Earn Credits and Redeem", comment: ""))
        buildContent(dealsButton, info : DJStringUtil.localize("Deals", comment: ""), descInfo : DJStringUtil.localize("Check out the latest sales items on your favorite brands", comment: ""))
//        buildContent(dealsButton, info : DJStringUtil.localize("20% OFF", comment: ""), descInfo : DJStringUtil.localize("Enjoy Discount from Mash-up 20% Off Storewide", comment: ""))
//        buildContent(fittingRoomButton, info : DJStringUtil.localize("Fitting Room", comment: ""), descInfo : DJStringUtil.localize("Mix and match to suit your style", comment: ""))
        buildContent(eventsButton, info : DJStringUtil.localize("Events", comment: ""), descInfo : DJStringUtil.localize("Events of our app", comment: ""))
        buildContent(inspirationButton, info : DJStringUtil.localize("Inspirations", comment: ""), descInfo : DJStringUtil.localize("Be inspired by our curated selection of stylish outfits", comment: ""))
        buildContent(nearByButton, info : DJStringUtil.localize("Nearby", comment: ""), descInfo : DJStringUtil.localize("Stores around you", comment: ""))
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        updateBannerView()
        
    }
    
        
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        bannerView.stopTimer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateBannerView()
    }
    
    func buildContent(containerView : UIView, info : String, descInfo : String){
        let mainLabel = UILabel().withText(info).withFontHeletica(17).withTextColor(UIColor.whiteColor())
        mainLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        let descLabel = UILabel().withText(descInfo).withFontHeletica(12).withTextColor(UIColor.whiteColor())
        descLabel.numberOfLines = 0
        containerView.addSubviews(mainLabel,descLabel)
        
        constrain(mainLabel, descLabel) { (mainLabel, descLabel) in
            mainLabel.bottom == mainLabel.superview!.bottom - 43
            mainLabel.left == mainLabel.superview!.left + 10
            
            descLabel.top == mainLabel.bottom + 8
            descLabel.left == mainLabel.left
            descLabel.right == descLabel.superview!.right - 10
        }
    }
    
    func buildFuncButton(imageName : String) -> UIButton{
        let one = UIButton().withFontHeletica(20).withTitleColor(UIColor.whiteColor()).withBackgroundImage(UIImage(named: imageName))
        return one
    }

    func gotoEvents() {
        let fr = EventBannersViewController()
        navigationController?.pushViewController(fr, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Explore_Click_Events)
    }
    
    func gotoFittingRoom() {
        
        let fr = FittingRoomViewController()
        fr.setEnterCondition(nil, filters: nil)
        navigationController?.pushViewController(fr, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Explore_Click_FittingRoom)
    }
    
    func gotoInvite()
    {
        navigationController?.pushViewController(InviteViewController(URLString: ConfigDataContainer.sharedInstance.getInviteFriendsUrl()), animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Explore_Click_Invite)
    }
    
    func gotoDeals() {
        DJStatisticsLogic.instance().addTraceLog(.Explore_Click_Deals)
        
  //      navigationController?.pushViewController(DealsViewController(beginCategoryId : "0"), animated: true)
//        navigationController?.pushViewController(InviteViewController(URLString: ConfigDataContainer.sharedInstance.getMashupUrl()), animated: true)
//        DJStatisticsLogic.instance().addTraceLog(.Explore_Click_Mashup)
        
        let enterC = ClothResultCondition()
        enterC.filterCondition.onSale = true

        let resultVC = FindClothResultViewController(enterInfo : enterC)
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func gotoNearBy() {
        navigationController?.pushViewController(NearbyListViewController(), animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Explore_Click_Nearby)
    }
    
    func gotoFriends() {
        if AccountDataContainer.sharedInstance.isAnonymous() {
            let v = LoginViewController()
            v.gotoFriendListIfSuccess = true
            navigationController?.pushViewController(v, animated: true)
        }else {
            navigationController?.pushViewController(FriendListViewController(), animated: true)
        }
    }
    
    func gotoWishlist() {
        navigationController?.pushViewController(StyleBookViewController(URLString: ConfigDataContainer.sharedInstance.getStyleBookUrl()), animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Explore_Click_Favorites)
    }
    
    func gotoInspiration()
    {
        navigationController?.pushViewController(InspirationViewController(URLString: ConfigDataContainer.sharedInstance.getInspirationUrl()), animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Explore_Click_Inspiration)
    }
    
    
    func bannerDidChanged(){
        banners = ConfigDataContainer.sharedInstance.getFindClothBanners()
        activity.stopAnimating()
        updateBannerView()
    }
    
    
    
    func updateBannerView(){
        var nViews = [UIView]()
        
        for oneBanner in banners {
            let conView = FindClothBannerView(frame : CGRectMake(0, 0, view.frame.size.width, bannerView.frame.size.height))
            nViews.append(conView)
            conView.brandBackgroundImage(oneBanner.imageUrl)
            conView.setInfos(oneBanner.firstInfo, second: oneBanner.secondInfo, third: oneBanner.thridInfo)
            
            let tapControl = UIControl(frame : conView.bounds)
            conView.addSubview(tapControl)
            tapControl.property = oneBanner
            tapControl.addTarget(self, action: #selector(bannerDidTapped(_:)), forControlEvents: .TouchUpInside)
        }
        
        bannerView.setScrollViewFull(nViews)
        bannerView.startTimer()
    }
    
    func bannerDidTapped(sender : UIControl){
        if let v = sender.property{
            let banner = v as! FindClothBanner
            if let urlStr = banner.jumpUrl{
                if let url = NSURL(string : urlStr){
                    DJAppCall.handleOpenURL(url, sourceApplication: "deja")
                }
            }
            
            if let bid = banner.bannerId
            {
                
                let dict = DJConfigDataContainer.instance().hasDisplayPromoAlert as NSDictionary
                let mutableDict = NSMutableDictionary(dictionary: dict)
                mutableDict.setObject(1, forKey: bid)
                DJConfigDataContainer.instance().hasDisplayPromoAlert = mutableDict
                
                DJStatisticsLogic.instance().addTraceLog("Banner_Click_\(bid)")
            }
        }
    }
}
