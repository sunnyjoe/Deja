//
//  AddByBrandView.swift
//  DejaFashion
//
//  Created by jiao qing on 23/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol AddByBrandViewDelegate : NSObjectProtocol{
    func addByBrandViewDelegateSelectBrand(addByBrandView : AddByBrandView, brand : BrandInfo?)
     func addByBrandViewDelegateGoback(addByBrandView : AddByBrandView)
}

class AddByBrandView: UIView, MONetTaskDelegate, AlphabetTableViewDelegate {
    var recommandList = [BrandInfo]()
    var brandList = [BrandInfo]()
    var categoryId : String?
    
    weak var delegate : AddByBrandViewDelegate?
    
    let recommendView = UIView()
    let activity = UIActivityIndicatorView()
    
    private let scrollRecBrandsView = ScrollableBannerView()
    let brandListView = UIView()
    let alphabetTV = AlphabetTableView()
    let recommendBrandNT = GetRecommendBrandsNetTask()
    var recommendBrands = [RecommendBrandInfo]()
    
    var preLocation = CGPointZero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let tmp = ConfigDataContainer.sharedInstance.getRecommendBrandList(){
            recommandList = tmp
        }
        
        if let tmp = ConfigDataContainer.sharedInstance.getAllBrandList(){
            brandList = tmp
        }
        
        backgroundColor = UIColor.whiteColor()
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: recommendBrandNT.uri())
        MONetTaskQueue.instance().addTask(recommendBrandNT)
        
        addSubview(recommendView)
        
        let label = UILabel(frame: CGRectMake(23, 0, 200, 46))
        label.withFontHeletica(14).withTextColor(UIColor.gray81Color()).withText(DJStringUtil.localize("New Arrivals", comment:""))
        recommendView.addSubview(label)
        
        recommendView.addSubview(activity)
        activity.activityIndicatorViewStyle = .White
        activity.center = recommendView.center
        activity.startAnimating()
        
        recommendView.addSubviews(scrollRecBrandsView)
        
        buildBrandList(98)
        
        let pang = UIPanGestureRecognizer(target: self, action: #selector(detectPanGesture(_:)))
        pang.cancelsTouchesInView = false
        addGestureRecognizer(pang)
    }
    
    func detectPanGesture(pan : UIPanGestureRecognizer){
        let translation = pan.locationInView(self)
        if pan.state == .Began{
            preLocation = translation
        }else if pan.state == .Ended{
            if preLocation.y >= brandListView.frame.origin.y + 42{
                return
            }
            let xd = translation.x - preLocation.x
            let yd = translation.y - preLocation.y
            
            if xd < 40 && yd > 60 {
                delegate?.addByBrandViewDelegateGoback(self)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        recommendView.frame = CGRectMake(0, 0, frame.size.width, 155)
        scrollRecBrandsView.frame = CGRectMake(0, 46, recommendView.frame.size.width, 100)
        resetRecommendView()
        
        resetBrandList(!recommendView.hidden)
    }
    
    func buildBrandList(oY : CGFloat){
        brandListView.frame = CGRectMake(0, oY,frame.size.width,frame.size.height - oY)
        addSubview(brandListView)
        
        let label = UILabel(frame: CGRectMake(23, 0, 200, 42))
        label.backgroundColor = UIColor.whiteColor()
        label.withFontHeletica(14).withTextColor(UIColor.gray81Color()).withText(DJStringUtil.localize("Brand List", comment:""))
        brandListView.addSubview(label)
        
        let line = UIView()
        brandListView.addSubview(line)
        line.backgroundColor = UIColor(fromHexString: "cecece")
        constrain(line, label) { line, label in
            line.height == 0.5
            line.bottom == label.bottom
            line.left == label.left
            line.right == line.superview!.right - 23
        }
        
        alphabetTV.frame = CGRectMake(0, 42, brandListView.frame.size.width, brandListView.frame.size.height - 10 - 42)
        alphabetTV.delegate = self
        //let name = DJStringUtil.localize("All", comment:"")
        var names = ["All"]
        names.appendContentsOf(ClothesDataContainer.sharedInstance.extractBrandNames(brandList))
        alphabetTV.setTheContent(names)
        brandListView.addSubview(alphabetTV)
        alphabetTV.setContentSelector(self, sel: #selector(didSelectBrandName(_:)))
    }
    
    func didSelectBrand(brand : BrandInfo?){
        delegate?.addByBrandViewDelegateSelectBrand(self, brand: brand)
    }
    
    func brandDidClicked(btn : BrandButton){
        if btn.brand != nil{
            didSelectBrand(btn.brand!)
        }
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == recommendBrandNT{
            activity.removeFromSuperview()
            if recommendBrandNT.recommendBrands.count > 0 {
                recommendView.hidden = false
                recommendBrands = recommendBrandNT.recommendBrands
                resetRecommendView()
            }else{
                recommendView.hidden = true
            }
            resetBrandList(!recommendView.hidden)
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == recommendBrandNT{
            activity.removeFromSuperview()
            recommendView.hidden = true
            resetBrandList(false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetRecommendView(){
        var brandViews = [RecommendBrandView]()
        for brand in recommendBrands{
            let brandView = RecommendBrandView(frame : CGRectMake(0, 0, 161, scrollRecBrandsView.frame.size.height))
            brandViews.append(brandView)
            brandView.property = brand.brandInfo
            brandView.addTapGestureTarget(self, action: #selector(didTapRecommendBrand))
            brandView.setInfos(brand.brandInfo.name, number: "\(brand.newArrivals)", desc: DJStringUtil.localize("New Arrivals", comment:""))
            brandView.brandBackgroundImage(brand.backgroudImages)
        }
        scrollRecBrandsView.setScrollViews(brandViews)
    }
    
    func didTapRecommendBrand(sender: AnyObject?){
        if let gr = sender as? UITapGestureRecognizer
        {
            if let brand = gr.view?.property as? BrandInfo {
                didSelectBrand(brand)
            }
        }
    }
    
    func resetBrandList(hasRecommend : Bool){
        var oY : CGFloat = 0
        if hasRecommend{
            oY = CGRectGetMaxY(recommendView.frame)
        }
        brandListView.frame = CGRectMake(0, oY,frame.size.width,frame.size.height - oY)
        alphabetTV.frame = CGRectMake(0, 42, brandListView.frame.size.width, brandListView.frame.size.height - 10 - 42)
    }
    
    func didSelectBrandName(str : String){
        if str == DJStringUtil.localize("All", comment:""){
            didSelectBrand(nil)
        }else if let brand = ClothesDataContainer.sharedInstance.findBrandByName(str){
            didSelectBrand(brand)
        }
    }
    
    func alphabetTableViewDraggingDown(){
        delegate?.addByBrandViewDelegateGoback(self)
    }
}
