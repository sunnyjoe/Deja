//
//  ShopInfoViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 21/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class ShopInfoViewController: NavigatableViewController {
    private let scrollView = UIScrollView()
    private var mapView : GMSMapView!
    private let marker = GMSMarker()
    private let distanceView = DistanceView()
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let distanceLabel = UILabel()
    private let phoneLabel = UILabel()
    private let fullOpenStatusLabel = UILabel()
    private let simpleOpenStatusLabel = UILabel()
    private var fullOpenTime = [UILabel]()
    private let week = [DJStringUtil.localize("Monday", comment:""),
                         DJStringUtil.localize("Tuesday", comment:""),
                         DJStringUtil.localize("Wednesday", comment:""),
                         DJStringUtil.localize("Thursday", comment:""),
                         DJStringUtil.localize("Friday", comment:""),
                         DJStringUtil.localize("Saturday", comment:""),
                         DJStringUtil.localize("Sunday", comment:"")]
    private let fullOpenHoursView = UIView()
    private let simpleOpenHoursView = UIView()
    var shopInfo : ShopInfo?
    var shopId : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nearby"
    
        LocationManager.sharedInstance().startAccurateMonitor()
        
        var frame = view.bounds
        frame.size.height = 175
        mapView = GMSMapView()
        mapView.frame = frame
        mapView.delegate = self
        mapView.userInteractionEnabled = false
        view.addSubview(mapView)
        
        
        let goThereButton = DJButton()
        goThereButton.frame = CGRectMake((view.bounds.size.width - 150) / 2, view.bounds.size.height - 120, 150, 35)
//        goThereButton.debug(UIColor.redColor(), borderWidth: 1.0)
        view.addSubview(goThereButton)
        
        scrollView.scrollEnabled = true
        scrollView.frame = CGRectMake(0, CGRectGetMaxY(mapView.frame), view.bounds.size.width, CGRectGetMinY(goThereButton.frame) - CGRectGetMaxY(mapView.frame) - 10)
        scrollView.scrollEnabled = true
        view.addSubview(scrollView)
        
        
        
        let gestureView = UIView()
        gestureView.addTapGestureTarget(self, action: #selector(ShopInfoViewController.didClickMap))
        gestureView.frame = mapView.frame
        view.addSubview(gestureView)
        
        marker.icon = UIImage(named: "LocationMarker")
        marker.map = self.mapView
        
        
        
        distanceView.backgroundColor = UIColor.whiteColor()
        distanceView.frame = CGRectMake(view.bounds.size.width - 8 - 85, CGRectGetMaxY(mapView.frame) - 10 - 30, 85, 30)
        
        mapView.addSubview(distanceView)
        
        
        nameLabel.withFontHeleticaMedium(15).withTextColor(UIColor.defaultBlack()).textCentered()
        addressLabel.withFontHeletica(14).withTextColor(UIColor.gray81Color()).textCentered()
        addressLabel.sizeToFit()
        addressLabel.numberOfLines = 0
        distanceLabel.withFontHeletica(14).withTextColor(UIColor.gray81Color()).textCentered()
        phoneLabel.withFontHeletica(14).withTextColor(UIColor.init(fromHexString: "71b0ea")).textCentered()
        phoneLabel.addTapGestureTarget(self, action: #selector(ShopInfoViewController.didClickPhoneNumber))
        phoneLabel.sizeToFit()
        
        let phoneIcon = UIImageView()
        phoneIcon.image = UIImage(named: "Call")
        phoneIcon.addTapGestureTarget(self, action: #selector(ShopInfoViewController.didClickPhoneNumber))
        
        goThereButton.addTarget(self, action: #selector(ShopInfoViewController.didClickGoThere), forControlEvents: .TouchUpInside)
        goThereButton.whiteTitleBlackStyle()
        
        let goThereIcon = UIImageView()
        goThereIcon.image = UIImage(named: "DirectionWhite")
        goThereIcon.contentMode = UIViewContentMode.Center
        let goThereLabel = UILabel().withText(DJStringUtil.localize("Get me there", comment:"")).withTextColor(UIColor.whiteColor()).withFontHeleticaBold(14)
        
        goThereButton.addSubviews(goThereIcon, goThereLabel)
        
        
        
        constrain(goThereIcon, goThereLabel) { (goThereIcon, goThereLabel) in
            goThereIcon.top == goThereIcon.superview!.top
            goThereIcon.left == goThereIcon.superview!.left + 18
            goThereIcon.width == 15
            goThereIcon.height == goThereIcon.superview!.height
            
            goThereLabel.top == goThereIcon.top
            goThereLabel.left == goThereIcon.right + 7
//            goThereLabel.right == goThereLabel.superview!.right - 20
            goThereLabel.height == goThereLabel.superview!.height
        }
        
        
        scrollView.addSubviews(nameLabel, addressLabel, distanceLabel, phoneIcon, phoneLabel)
        constrain(nameLabel, addressLabel, distanceLabel, phoneLabel, phoneIcon) { (nameLabel, addressLabel, distanceLabel, phoneLabel, phoneIcon) in
            nameLabel.top == nameLabel.superview!.top + 5
            nameLabel.left == nameLabel.superview!.left
            nameLabel.width == nameLabel.superview!.width
            nameLabel.height == 30
            
            addressLabel.top == nameLabel.bottom + 5
            addressLabel.left == addressLabel.superview!.left + 60
            addressLabel.width == addressLabel.superview!.width - 120
            
            distanceLabel.top == addressLabel.bottom + 10
            distanceLabel.centerX == distanceLabel.superview!.centerX
            
            phoneLabel.top == distanceLabel.bottom + 10
            phoneLabel.centerX == phoneLabel.superview!.centerX
            
            phoneIcon.centerY == phoneLabel.centerY
            phoneIcon.right == phoneLabel.left - 5
            
        }
        
        fullOpenHoursView.alpha = 0
        scrollView.addSubview(fullOpenHoursView)
        fullOpenStatusLabel.withFontHeletica(14).withTextColor(UIColor.defaultBlack())
        fullOpenStatusLabel.addTapGestureTarget(self, action: #selector(ShopInfoViewController.didClickFullOpenHoursStatus))
        fullOpenHoursView.addSubview(fullOpenStatusLabel)
        
        let fullOpenStatusArrow = UIImageView()
        fullOpenStatusArrow.image = UIImage(named: "FilterArrowUp")
        fullOpenHoursView.addSubview(fullOpenStatusArrow)
        
        constrain(fullOpenStatusLabel, fullOpenStatusArrow) { (fullOpenStatusLabel, fullOpenStatusArrow) in
            fullOpenStatusLabel.top == fullOpenStatusLabel.superview!.top
            fullOpenStatusLabel.left == fullOpenStatusLabel.superview!.left
            fullOpenStatusLabel.right == fullOpenStatusLabel.superview!.right
            fullOpenStatusLabel.height == 25
            
            fullOpenStatusArrow.top == fullOpenStatusLabel.top + 5
            fullOpenStatusArrow.right == fullOpenStatusArrow.superview!.right
            fullOpenStatusArrow.height == 15
        }
        
        for index in 0 ..< 7
        {
            let day = UILabel().withFontHeletica(14).withTextColor(UIColor.gray81Color()).withText(week[index])
            day.textAlignment = NSTextAlignment.Left
            day.frame = CGRectMake(0, CGFloat(index) * 18 + 25, (view.bounds.size.width - 120) / 2 - 20 , 18)
            fullOpenHoursView.addSubview(day)
            
            let label = UILabel().withFontHeletica(14).withTextColor(UIColor.gray81Color())
            fullOpenTime.append(label)
            //            .withText( self.shopInfo!.openHours![index])
            
            fullOpenTime[index].frame = CGRectMake((view.bounds.size.width - 120) / 2 - 20, day.frame.origin.y,  (view.bounds.size.width - 120) / 2 + 20, day.frame.size.height)
            fullOpenTime[index].textAlignment = NSTextAlignment.Right
            fullOpenHoursView.addSubview(fullOpenTime[index] )
        }
        
        
        
        

        scrollView.addSubview(simpleOpenHoursView)
        simpleOpenStatusLabel.withFontHeletica(14).withTextColor(UIColor.defaultBlack())
        simpleOpenStatusLabel.addTapGestureTarget(self, action: #selector(ShopInfoViewController.didClickSimpleOpenHoursStatus))
        simpleOpenHoursView.addSubview(simpleOpenStatusLabel)
        
        
        let simpleOpenStatusArrow = UIImageView()
        simpleOpenStatusArrow.image = UIImage(named: "FilterArrowDown")
        simpleOpenHoursView.addSubview(simpleOpenStatusArrow)
        
        constrain(simpleOpenStatusLabel, simpleOpenStatusArrow) { (simpleOpenStatusLabel, simpleOpenStatusArrow) in
            simpleOpenStatusLabel.top == simpleOpenStatusLabel.superview!.top
            simpleOpenStatusLabel.left == simpleOpenStatusLabel.superview!.left
            simpleOpenStatusLabel.right == simpleOpenStatusLabel.superview!.right
            simpleOpenStatusLabel.height == 25
            
            simpleOpenStatusArrow.top == simpleOpenStatusLabel.top + 5
            simpleOpenStatusArrow.right == simpleOpenStatusArrow.superview!.right
            simpleOpenStatusArrow.height == 15
        }
        
        
        constrain(phoneLabel, fullOpenHoursView, simpleOpenHoursView) { (phoneLabel, fullOpenHoursView, simpleOpenHoursView) in
            fullOpenHoursView.top == phoneLabel.bottom + 10
            fullOpenHoursView.left == fullOpenHoursView.superview!.left + 60
            fullOpenHoursView.width == fullOpenHoursView.superview!.width - 120
            fullOpenHoursView.height == 150
            
            simpleOpenHoursView.top == fullOpenHoursView.top
            simpleOpenHoursView.left == fullOpenHoursView.left
            simpleOpenHoursView.width == fullOpenHoursView.width
            simpleOpenHoursView.height == fullOpenHoursView.height
        }
        if  let value = shopInfo
        {
            refreshUI(value)
        }
        else
        {
            if shopId != nil
            {
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                let task = ShopinfoByIdNetTask()
                task.shopId = shopId
                MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
                MONetTaskQueue.instance().addTask(task)
            }
        }
        
    }
    
    
    deinit{
        LocationManager.sharedInstance().stopAccurateMonitor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showHomeButton(true)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func refreshUI(shop: ShopInfo)
    {
        let location = CLLocationCoordinate2DMake(shop.coordinate.latitude, shop.coordinate.longitude)
        let camera = GMSCameraPosition.cameraWithLatitude(shop.coordinate.latitude, longitude: shop.coordinate.longitude, zoom: MAP_ZOOM)
        mapView.camera = camera
        marker.position = location
        
        let distance = String(format: "%.1fKM", shop.distance)
        distanceView.setDistance(distance)
        nameLabel.withText(shop.name)
        addressLabel.withText(shop.address!)
        distanceLabel.withText(distance)
        phoneLabel.withText(shop.contactNumber!)
        let fullOpenHourText = shop.checkIfOpen() == true ? DJStringUtil.localize("Open Now" , comment:""): DJStringUtil.localize("Closed", comment:"")
        fullOpenStatusLabel.withText(fullOpenHourText)
        
        if  let text = shop.todayOpenHour?.openToClose()
        {
            let simpleOpenHourText = shop.checkIfOpen() == true ? "Open Now \(text)" : "Closed"
            simpleOpenStatusLabel.withText(simpleOpenHourText)
        }
        
        if let openHour = shop.openHours
        {
            
            for index in 0 ..<  openHour.count
            {
                let text = "\( openHour[index].open())-\( openHour[index].close())"
                fullOpenTime[index].text = text
            }
        }
    }
    
    func didClickMap()
    {
        if let value = self.shopInfo
        {
            let vc = ShopMapViewController()
            vc.locationInfo = value
            navigationController?.pushViewController(vc, animated: true)
            DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Shop_Click_Map)
        }
    }
    
    func didClickFullOpenHoursStatus()
    {
        UIView.animateWithDuration(0.3) {
            self.simpleOpenHoursView.alpha = 1
            self.fullOpenHoursView.alpha = 0
        }
        scrollView.contentSize = scrollView.bounds.size
    }
    func didClickSimpleOpenHoursStatus()
    {
        UIView.animateWithDuration(0.3) {
            self.simpleOpenHoursView.alpha = 0
            self.fullOpenHoursView.alpha = 1
        }
        
        scrollView.contentSize = CGSizeMake(view.bounds.size.width, 320)
        DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Shop_Click_OH)
    }
    func didClickPhoneNumber()
    {
        
        if let value = self.shopInfo
        {
            if let url = NSURL.init(string: "tel://\(value.contactNumber!)")
            {
                UIApplication.sharedApplication().openURL(url)
            }
            DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Shop_Click_Makephonecall)
        }
    }
    
    
    func didClickGoThere()
    {
        if let value = self.shopInfo
        {
            showNavigationAlctionSheet(value.coordinate)
            DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Shop_Click_Navi)
        }
    }
    
}


extension ShopInfoViewController : MONetTaskDelegate
{
    func netTaskDidEnd(task: MONetTask!) {
        MBProgressHUD.hideHUDForView(view, animated: true)
        if task.isKindOfClass(ShopinfoByIdNetTask) {
            let upTask = task as! ShopinfoByIdNetTask
            if let value = upTask.shop
            {
                self.shopInfo = value
                refreshUI(value)
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        MBProgressHUD.hideHUDForView(view, animated: true)
        
    }
    
}


extension ShopInfoViewController : GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        
        let vc = ShopMapViewController()
        vc.locationInfo = self.shopInfo
        navigationController?.pushViewController(vc, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Shop_Click_Map)
    }
    
}
