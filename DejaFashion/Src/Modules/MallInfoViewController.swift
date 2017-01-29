//
//  MallInfoViewController.swift
//  DejaFashion
//
//  Created by Sun lin on 28/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

import UIKit
import GoogleMaps

class MallInfoViewController: DJBasicViewController {
    var mapView : GMSMapView!
    let marker = GMSMarker()
    var mallInfo : MallInfo?
    let listTableView = ShopListTableView()
    let shoplistInMallNetTask = ShoplistInMallNetTask()
    var shopInLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = self.mallInfo?.name

        LocationManager.sharedInstance().startAccurateMonitor()
        
        let location = CLLocationCoordinate2DMake((self.mallInfo?.coordinate.latitude)!, (self.mallInfo?.coordinate.longitude)!)
        let camera = GMSCameraPosition.cameraWithLatitude((self.mallInfo?.coordinate.latitude)!, longitude: (self.mallInfo?.coordinate.longitude)!, zoom: MAP_ZOOM)
        var frame = view.bounds
        frame.size.height = 175
        mapView = GMSMapView.mapWithFrame(frame, camera: camera)
//        mapView.myLocationEnabled = true
        view.addSubview(mapView)
        
        let gestureView = UIView()
        gestureView.addTapGestureTarget(self, action: #selector(ShopInfoViewController.didClickMap))
        gestureView.frame = mapView.frame
        view.addSubview(gestureView)
        
        let distanceView = DistanceView()
        distanceView.backgroundColor = UIColor.whiteColor()
        distanceView.frame = CGRectMake(view.bounds.size.width - 8 - 85, CGRectGetMaxY(mapView.frame) - 10 - 30, 85, 30)
        let distance = String(format: "%.1fKM", (self.mallInfo?.distance)!)
        distanceView.setDistance(distance)
        view.addSubview(distanceView)
        
        let marker = GMSMarker()
        marker.icon = UIImage(named: "LocationMarker")
        marker.map = self.mapView
        marker.position = location
        
        shopInLabel = shopInLabel.withFontHeleticaMedium(15).withTextColor(UIColor.gray81Color()).withText("\(DJStringUtil.localize("Shops in", comment: "")) \(self.mallInfo!.name)")
        view.addSubview(shopInLabel)
        
        listTableView.shopListDelegate = self
        view.addSubview(listTableView)
        
        shoplistInMallNetTask.mall = self.mallInfo
        MONetTaskQueue.instance().addTaskDelegate(self, uri: shoplistInMallNetTask.uri())
        MONetTaskQueue.instance().addTask(shoplistInMallNetTask)
        
    }
    
    deinit{
        LocationManager.sharedInstance().stopAccurateMonitor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        showHomeButton(true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var oY = CGRectGetMaxY(mapView.frame)
        shopInLabel.frame = CGRectMake(22, oY, view.frame.size.width, 30)
//        shopInLabel.layer.borderColor = UIColor.redColor().CGColor
//        shopInLabel.layer.borderWidth = 1.0
        oY = CGRectGetMaxY(shopInLabel.frame)
        listTableView.frame = CGRectMake(0, oY, view.frame.size.width, view.frame.size.height - oY)
//        listTableView.layer.borderColor = UIColor.redColor().CGColor
//        listTableView.layer.borderWidth = 1.0
    }
    
    func didClickMap()
    {
        let vc = ShopMapViewController()
        vc.locationInfo = self.mallInfo
        DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Mall_Click_Map)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MallInfoViewController : ShopListTableViewDelegate
{
    func shopListTableView(tableview : ShopListTableView, didSelectShop shop: ShopInfo)
    {
        let vc = ShopInfoViewController()
        vc.shopInfo = shop
        navigationController?.pushViewController(vc, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Mall_Click_Shop)
    }
    
    func shopListTableViewStartScroll(tableview : ShopListTableView)
    {
        
    }
}



extension MallInfoViewController : MONetTaskDelegate
{
    func netTaskDidEnd(task: MONetTask!) {
        if task == shoplistInMallNetTask{
            MBProgressHUD.hideHUDForView(view, animated: true)
            
            let listTask = task as! ShoplistInMallNetTask
            let shopList = listTask.shops
            
            listTableView.data = shopList
            listTableView.reloadData()
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == shoplistInMallNetTask {
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
}

extension MallInfoViewController : GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        
    }
    
}

