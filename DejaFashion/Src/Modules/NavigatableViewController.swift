//
//  NavigatableViewController.swift
//  DejaFashion
//
//  Created by Sun lin on 29/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation
import MapKit

class NavigatableViewController: DJBasicViewController {
    
    var destination : CLLocationCoordinate2D?
    
    func showNavigationAlctionSheet(to : CLLocationCoordinate2D?)
    {
        self.destination = to
        let popup = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: DJStringUtil.localize("Cancel", comment:""), destructiveButtonTitle: nil, otherButtonTitles: DJStringUtil.localize("Google Map Navigation", comment:""), DJStringUtil.localize("Apple Map Navigation", comment:""))
        popup.tag = 1
        popup.showInView(self.view)
        
    }
}
extension NavigatableViewController : UIActionSheetDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == 1 {
            if buttonIndex == 1 {
                
                let loc = LocationManager.sharedInstance().currentLocation
                let fromLat = loc.coordinate.latitude
                let fromLon = loc.coordinate.longitude
                let toLat = self.destination!.latitude
                let toLon = self.destination!.longitude
                
                let urlStr = "http://maps.google.com/maps?saddr=\(fromLat),\(fromLon)&daddr=\(toLat),\(toLon)&dirfl=d"
                if let url = NSURL.init(string: urlStr)
                {
                    UIApplication.sharedApplication().openURL(url)
                }
                
            }else if buttonIndex == 2{
                
                let currentLocation = MKMapItem.mapItemForCurrentLocation()
                let placemark = MKPlacemark.init(coordinate: self.destination!, addressDictionary: nil)
                let toLocation = MKMapItem.init(placemark: placemark)
                let options:Dictionary<String, AnyObject> = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                                             MKLaunchOptionsMapTypeKey: MKMapType.Standard.rawValue,
                                                             MKLaunchOptionsShowsTrafficKey: true]
                
                let items : [MKMapItem] = [currentLocation, toLocation]
                MKMapItem.openMapsWithItems(items, launchOptions: options)
            }
        }
    }
}
