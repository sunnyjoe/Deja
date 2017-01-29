//
//  MainTabViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 10/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {
    let findClothVC = UINavigationController(rootViewController: FindCombineViewController())
    let meVC = UINavigationController(rootViewController: MeViewController())
    let exploreVC = UINavigationController(rootViewController: ExploreViewController())
    
    lazy var mainViewControllerDelegate = MainViewControllerDelegate()
    
    static let sharedInstance = MainTabViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let tabVCs = [findClothVC, exploreVC, meVC]
        setViewControllers(tabVCs, animated: false)
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        
        self.tabBar.frame = CGRectMake(0, view.frame.size.height - 56, view.frame.size.width, 56)
        
        let (fdNormalImage, highlightImage) = buildTabBarImage(DJStringUtil.localize("Find", comment:""), image: UIImage(named: "SearchNormal"), highlightImage: UIImage(named: "SearchHighlighted"))
        findClothVC.tabBarItem = UITabBarItem(title: nil, image: fdNormalImage, tag: 0)
        findClothVC.tabBarItem.selectedImage = highlightImage.imageWithRenderingMode(.AlwaysOriginal)
        
        let (wdNormalImage, wdghImage) = buildTabBarImage(DJStringUtil.localize("Me", comment: "") , image: UIImage(named: "MeNormal"), highlightImage: UIImage(named: "MeHighlighted"))
        meVC.tabBarItem = UITabBarItem(title: nil, image: wdNormalImage, tag: 2)
        meVC.tabBarItem.selectedImage = wdghImage.imageWithRenderingMode(.AlwaysOriginal)
        
        let (epNormalImage, epghImage) = buildTabBarImage(DJStringUtil.localize("Explore", comment:""), image: UIImage(named: "ExploreNormal"), highlightImage: UIImage(named: "ExploreHighlighted"))
        exploreVC.tabBarItem = UITabBarItem(title: nil, image: epNormalImage, tag: 1)
        exploreVC.tabBarItem.selectedImage = epghImage.imageWithRenderingMode(.AlwaysOriginal)
        mainViewControllerDelegate.viewControllerViewDidLoad()
    }
    
    func buildTabBarImage(title : String, image : UIImage?, highlightImage : UIImage?) -> (UIImage, UIImage){
        let width = view.frame.size.width / 3
        let containV = UIView(frame: CGRectMake(0, 0, width, tabBar.frame.size.height))
       
        var imageSize = image!.size
        if imageSize.width > 23{
            imageSize.height = 23 * imageSize.height / imageSize.width
            imageSize.width = 23
        }
        let imageV = UIImageView(frame: CGRectMake(width / 2 - imageSize.width / 2, 16.5, imageSize.width, imageSize.height))
        containV.addSubview(imageV)
        
        let titleLabel = UILabel(frame: CGRectMake(0, CGRectGetMaxY(imageV.frame), width, 20))
        containV.addSubview(titleLabel)
        titleLabel.withFontHeletica(12).withText(title).withTextColor(UIColor(fromHexString: "b2b2b2")).textCentered()
   
//        let padding = UIView(frame : CGRectMake(0, CGRectGetMaxY(titleLabel.frame), width, containV.frame.size.height))
//        padding.backgroundColor = UIColor.redColor()
//        containV.addSubview(padding)
        
        imageV.image = image
        let normalImage = containV.getImageFromView(4)
        
        imageV.image = highlightImage
        titleLabel.withTextColor(UIColor.defaultRed())
        let htImage = containV.getImageFromView(4)
        return (normalImage, htImage)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mainViewControllerDelegate.viewControllerViewDidAppear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        mainViewControllerDelegate.viewControllerViewDidDisappear()
    }
    
    func gotoTabIndex(index : Int){
        if index < 0 || index >= self.childViewControllers.count{
            return
        }
        if index == 0 {
            let fc = findClothVC.viewControllers[0] as! FindCombineViewController
            fc.resetSearch()
        }
        findClothVC.popToRootViewControllerAnimated(false)
        meVC.popToRootViewControllerAnimated(false)
        exploreVC.popToRootViewControllerAnimated(false)
        selectedIndex = index
    }
    
    deinit {
        mainViewControllerDelegate.viewControllerDidDealloc()
    }
}

extension MainTabViewController : UITabBarControllerDelegate
{
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        switch tabBarController.selectedIndex {
        case 0:
            DJStatisticsLogic.instance().addTraceLog(.Mainframe_Click_FindClothes)
            break
        case 2:
            DJStatisticsLogic.instance().addTraceLog(.Mainframe_Click_Wardrobe)
            break
        case 1:
            DJStatisticsLogic.instance().addTraceLog(.Mainframe_Click_Explore)
            break
        default:
            break
        }
    }
}
