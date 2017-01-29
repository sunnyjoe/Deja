//
//  AddByBrandViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 10/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
class BrandButton: UIButton {
    var brand : BrandInfo?
}

class AddByBrandViewController: DJBasicViewController, MONetTaskDelegate {
    var recommandList = [BrandInfo]()
    var brandList = [BrandInfo]()
    var categoryId : String?
    
    let recommendView = UIView()
    let activity = UIActivityIndicatorView()
    
    private let scrollRecBrandsView = ScrollableBannerView()
    let brandListView = UIView()
    let alphabetTV = AlphabetTableView()
    let recommendBrandNT = GetRecommendBrandsNetTask()
    
    override init() {
        super.init()
        if let tmp = ConfigDataContainer.sharedInstance.getRecommendBrandList(){
            recommandList = tmp
        }
        if let tmp = ConfigDataContainer.sharedInstance.getAllBrandList(){
            brandList = tmp
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = .All
        
        title = DJStringUtil.localize("Brands", comment:"")
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: recommendBrandNT.uri())
        MONetTaskQueue.instance().addTask(recommendBrandNT)
        
        buildRecommandView()
        buildBrandList(98)
    }
    
    func didSelectBrand(brand : BrandInfo?){
        DJStatisticsLogic.instance().addTraceLog(.Brands_Click_onebrand)
        
//        let bpv = CategoriesProductsViewController(brandIf: brand)
//        if let cateid = categoryId
//        {
//            bpv.initialCategoryId = cateid
//        }
//        navigationController?.pushViewController(bpv, animated: true)
        
        
        
        let cond = ClothResultCondition()
        cond.filterCondition.brand = brand
        let resultVC = FindClothResultViewController(enterInfo : cond)
        navigationController?.pushViewController(resultVC, animated: true)
        
        
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
                resetRecommendView(recommendBrandNT.recommendBrands)
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        resetBrandList(!recommendView.hidden)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddByBrandViewController{
    func buildRecommandView(){
        recommendView.frame = CGRectMake(0, 0, view.frame.size.width, 155)
        view.addSubview(recommendView)
        
        let label = UILabel(frame: CGRectMake(23, 0, 200, 46))
        label.withFontHeletica(14).withTextColor(UIColor.gray81Color()).withText(DJStringUtil.localize("New Arrivals", comment:""))
        recommendView.addSubview(label)
        
        recommendView.addSubview(activity)
        activity.activityIndicatorViewStyle = .White
        activity.center = recommendView.center
        activity.startAnimating()
        
        scrollRecBrandsView.frame = CGRectMake(0, CGRectGetMaxY(label.frame), recommendView.frame.size.width, 100)
        recommendView.addSubviews(scrollRecBrandsView)
    }
    
    func resetRecommendView(brands : [RecommendBrandInfo]){
        var brandViews = [RecommendBrandView]()
        for brand in brands{
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
        brandListView.frame = CGRectMake(0, oY, view.frame.size.width, view.frame.size.height - oY)
        alphabetTV.frame = CGRectMake(0, 42, brandListView.frame.size.width, brandListView.frame.size.height - 10 - 42)
    }
    
    func buildBrandList(oY : CGFloat){
        brandListView.frame = CGRectMake(0, oY, view.frame.size.width, view.frame.size.height - oY)
        view.addSubview(brandListView)
        
        let label = UILabel(frame: CGRectMake(23, 0, 200, 42))
        label.withFontHeletica(14).withTextColor(UIColor.gray81Color()).withText(DJStringUtil.localize("Brand List", comment:""))
        brandListView.addSubview(label)
        
        let line = UIView(frame: CGRectMake(23, label.frame.size.height - 0.5, view.frame.size.width - 23 * 2, 0.5))
        brandListView.addSubview(line)
        line.backgroundColor = UIColor(fromHexString: "cecece")
        
        alphabetTV.frame = CGRectMake(0, 42, brandListView.frame.size.width, brandListView.frame.size.height - 10 - 42)
        var names = ["All"]
        names.appendContentsOf(ClothesDataContainer.sharedInstance.extractBrandNames(brandList))
        alphabetTV.setTheContent(names)
        brandListView.addSubview(alphabetTV)
        alphabetTV.setContentSelector(self, sel: #selector(AddByBrandViewController.didSelectBrandName(_:)))
    }
    
    func didSelectBrandName(str : String){
        if str == DJStringUtil.localize("All", comment:""){
            didSelectBrand(nil)
        }else if let brand = ClothesDataContainer.sharedInstance.findBrandByName(str){
            didSelectBrand(brand)
        }
    }
}
