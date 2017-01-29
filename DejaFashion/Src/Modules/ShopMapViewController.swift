//
//  ShopMapViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 16/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
import GoogleMaps

let MAP_ZOOM : Float = 17

class ShopMapViewController: NavigatableViewController {
    var mapView : GMSMapView!
    let marker = GMSMarker()
    var locationInfo : LocationInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = self.locationInfo?.name
        
        let location = CLLocationCoordinate2DMake((self.locationInfo?.coordinate.latitude)!, (self.locationInfo?.coordinate.longitude)!)
    
        LocationManager.sharedInstance().startAccurateMonitor()
        
        let camera = GMSCameraPosition.cameraWithLatitude((self.locationInfo?.coordinate.latitude)!, longitude: (self.locationInfo?.coordinate.longitude)!, zoom: MAP_ZOOM)
        mapView = GMSMapView.mapWithFrame(view.bounds, camera: camera)
        mapView.myLocationEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
        
        let locationTipsView = UIView()
//        locationTipsView.frame = CGRectMake(0, 0, 305, 195)
        let marker = GMSMarker()
        marker.iconView = locationTipsView
        marker.map = self.mapView
        marker.position = location
        
        
        
        
        let bordView = UIImageView()
        bordView.image = UIImage(named: "TipsBoard")
            //UIView().withBackgroundColor(UIColor.whiteColor())
//        bordView.layer.shadowRadius = 1
//        bordView.layer.shadowOffset = CGSizeMake(4, 4)
//        bordView.layer.shadowColor = UIColor.blackColor().CGColor
//        bordView.layer.shadowOpacity = 0.8
//        bordView.layer.shadowRadius = 4
//        bordView.layer.shadowPath = UIBezierPath(roundedRect: bordView.bounds, cornerRadius: 0).CGPath
//        bordView.layer.masksToBounds = false
        
        
        let arrowView = UIImageView()
        arrowView.image = UIImage(named: "Arrow")
        locationTipsView.addSubviews(bordView, arrowView)
        
        
        
        let nameLabel = UILabel().withFontHeleticaMedium(15).withTextColor(UIColor.blackColor()).withText(self.locationInfo!.name)
        let addressLabel = UILabel().withFontHeletica(14).withTextColor(UIColor.defaultBlack()).withText(self.locationInfo!.address!)
        addressLabel.sizeToFit()
        addressLabel.numberOfLines = 0
        
        let distance = String(format: "%.1fKM", locationInfo!.distance)
        let distanceLabel = UILabel().withFontHeletica(14).withTextColor(UIColor.defaultBlack()).withText(distance)
        
        let addressIcon = UIImageView()
        addressIcon.image = UIImage(named: "MapMakerIcon")
        
        let directionIcon = UIImageView()
        directionIcon.image = UIImage(named: "Direction")
 
        bordView.addSubviews(nameLabel, addressIcon, addressLabel, distanceLabel, directionIcon)
 
        constrain(locationTipsView, bordView, arrowView, distanceLabel) { (locationTipsView, bordView, arrowView, distanceLabel) in
            locationTipsView.width == 305
            locationTipsView.height == bordView.height
            
            
            bordView.top == locationTipsView.top
            bordView.left == bordView.superview!.left
            bordView.right == bordView.superview!.right
            bordView.bottom == distanceLabel.bottom + 50
            
            
            
            arrowView.top == bordView.bottom - 31
            arrowView.centerX == arrowView.superview!.centerX
        }
        
        constrain(nameLabel, addressIcon, addressLabel, distanceLabel, directionIcon) { (nameLabel, addressIcon, addressLabel, distanceLabel, directionIcon) in
            nameLabel.top == nameLabel.superview!.top + 40
            nameLabel.left == nameLabel.superview!.left + 40
            nameLabel.right == nameLabel.superview!.right - 50
            nameLabel.height == 17
            
            addressIcon.top == nameLabel.bottom + 18
            addressIcon.left == nameLabel.left
            addressIcon.width == 12
            
            addressLabel.top == nameLabel.bottom + 15
            addressLabel.left == addressIcon.right + 10
            addressLabel.right == nameLabel.right
            
            distanceLabel.top == addressLabel.bottom + 5
            distanceLabel.left == addressLabel.left
            distanceLabel.right == nameLabel.right
            
            directionIcon.top == nameLabel.top
            directionIcon.right == directionIcon.superview!.right - 35
            
        }
 
//        var height = nameLabel.bounds.size.height
//         height = nameLabel.bounds.size.height

//        CGFloat width = ...;
//        UIFont *font = ...;
//        NSAttributedString *attributedText =
//        [[NSAttributedString alloc] initWithString:text
//        attributes:@{NSFontAttributeName: font}];
//        CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
//        options:NSStringDrawingUsesLineFragmentOrigin
//        context:nil];
//        CGSize size = rect.size;
    }
    
    deinit{
        LocationManager.sharedInstance().stopAccurateMonitor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showHomeButton(true)
    }
    
    func didClickLocationTips()
    {
        showNavigationAlctionSheet(self.locationInfo?.coordinate)
        if let _ = self.locationInfo as? ShopInfo
        {
            
            DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Shop_Map_Click_Navi)
        }
        if let _ = self.locationInfo as? MallInfo
        {
            DJStatisticsLogic.instance().addTraceLog(.Nearby_List_Mall_Map_Click_Navi)
            
        }
    }
}

extension ShopMapViewController : GMSMapViewDelegate {
    func drawRoute(polyLine : NSDictionary){
        let route = polyLine["points"] as! String
        let path = GMSPath(fromEncodedPath : route)
        let routePolyline = GMSPolyline(path : path)
        routePolyline.strokeColor = UIColor(fromHexString: "0CA7D3")
        routePolyline.strokeWidth = 5
        routePolyline.map = mapView
    }
    
 
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//        self.marker.position = coordinate
//        
//        let place = Place()
//        place.coordinate.longitude = coordinate.longitude
//        place.coordinate.latitude = coordinate.latitude
//        
//        let handler = {(lines : [NSObject : AnyObject]?, distance : Int, duration : Int, success : Bool) -> Void in
//            if success && lines != nil{
//                self.drawRoute(lines!)
//            }
//        }
//        LocationManager.sharedInstance().getDirection(place, completionHandler: handler)
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
//        return false
        showNavigationAlctionSheet(self.locationInfo?.coordinate)
        return true
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
    }
}
