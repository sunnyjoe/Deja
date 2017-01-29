//
//  DJBasicViewController+BarItems.swift
//  DejaFashion
//
//  Created by jiao qing on 11/7/16./Users/jiaoqing/deja-ios/DejaFashion/Location.gpx
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

extension DJBasicViewController : DropMenuViewDelegate{
    func showHomeButton(show : Bool){
        let home = UIButton.init(type: .Custom)
        home.setImage(UIImage(named: "HomeIcon"), forState: .Normal)
        home.frame = CGRectMake(44, 11.5, 23, 21)
        home.addTarget(self, action: #selector(showHomeView), forControlEvents: .TouchUpInside)
        
        homeItem = UIBarButtonItem(customView : home)
        navigationItem.rightBarButtonItem = homeItem
    }
    
    func showHomeView(){
        let directorView = DropMenuView(menus:["Find", "Explore", "Me"])
        if directorView.superview != nil{
            directorView.hideAnimation()
            return
        }
        directorView.delegate = self
        
        if let nv = self.navigationController{
            nv.view.addSubview(directorView)
        }else{
            view.addSubview(directorView)
        }
        
        directorView.showAnimation()
    }
    
     func dropMenuViewDidClickIndex(dropMenuView: DropMenuView, index : Int){
        dropMenuView.removeFromSuperview()
        beforeViewDisappear()
        MainTabViewController.sharedInstance.gotoTabIndex(index)
    }
    
    func beforeViewDisappear(){
        
    }
    
    func removeViewControllerFromStack(vc : UIViewController?){
        if vc == nil{
            return
        }
        
        if let nv = navigationController{
            let vcs = NSMutableArray(array: nv.viewControllers)
            vcs.removeObject(vc!)
            nv.viewControllers = ((vcs as NSArray) as! [UIViewController])
        }
    }
    
}