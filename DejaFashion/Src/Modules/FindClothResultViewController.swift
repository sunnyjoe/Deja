//
//  FindClothResultViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 24/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ClothResultCondition : NSObject, NSCopying {
    var filterCondition = FilterableConditions()
    var sortBy = 0
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let one = ClothResultCondition()
        one.sortBy = self.sortBy
        one.filterCondition = filterCondition.copyWithZone(zone) as! FilterableConditions
        
        return one
    }
}

struct NetTaskStates{
    var pageIndex = 0
    var isLoading = false
    var ended = false
}

class FindClothResultViewController: DJBasicViewController, ProductCollectionViewDelegate, MONetTaskDelegate {
    private var enterInfo : ClothResultCondition!
    private var promoBannerView = DJWarningBanner()
    private var currentPromo : FindClothBanner?
    private let promoAlertView = UIView()
    
    private lazy var collectionView : ProductCollectionView = {
        let onelist = ProductCollectionView(frame: self.view.bounds)
        return onelist
    }()
    
    private lazy var topBar : UIView = {
        let topBarView = UIView(frame : CGRectMake(0, 0, self.view.frame.size.width, 36))
        topBarView.backgroundColor = UIColor.defaultBlack()
        return topBarView
    }()
    
    private var sortByStrs = ConfigDataContainer.sharedInstance.getSortByRules().map { (rule: SortRule) -> String in
        if let name = rule.name
        {
            return name
        }
        else
        {
            return ""
        }
    }
    
    private var occasions : [SearchPurpose] = {
        let whole = ConfigDataContainer.sharedInstance.getSearchPurposes()
        for one in whole {
            if one.type == PurposeType.Occasion {
                return one.subPurposes
            }
        }
        return [SearchPurpose]()
    }()
    
    private var bodyIssues : [SearchPurpose] = {
        let whole = ConfigDataContainer.sharedInstance.getSearchPurposes()
        for one in whole {
            if one.type == PurposeType.BodyIssues {
                return one.subPurposes
            }
        }
        return [SearchPurpose]()
    }()
    
    private var searchTask = FindClothesNetTask()
    
    private var sortByLabel : FuncLabel!
    private var occaLabel : FuncLabel!
    private var issueLabel : FuncLabel!
    
    private var taskState = NetTaskStates()
    
    private let nilSelectName = "Not Limited"
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(enterInfo : ClothResultCondition) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.enterInfo = enterInfo
        
        let rules = ConfigDataContainer.sharedInstance.getSortByRules()
        if rules.count > 0{
            if let theId = rules[0].value{
                self.enterInfo.sortBy = theId
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetTitle()
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        view.addSubview(topBar)
        
        var spacing : CGFloat = 0
        var scale : CGFloat = 1
        var labelFont : CGFloat = 15
        
        if view.frame.size.width > 376 {
            spacing += 13
        }else if view.frame.size.width < 374{
            spacing -= 5
            scale = 0.9
            labelFont = 13
        }
        
        sortByLabel = FuncLabel(frame: CGRectMake(23, 0, 75 * scale, topBar.frame.size.height), fontSize : labelFont)
        sortByLabel.withText("Sort by")
        sortByLabel.setSelected(true)
        sortByLabel.addTapGestureTarget(self, action: #selector(functionLabelDidTapped(_:)))
        topBar.addSubview(sortByLabel)
        
        
        occaLabel = FuncLabel(frame: CGRectMake(CGRectGetMaxX(sortByLabel.frame) + 5 + spacing, 0, 100 * scale, topBar.frame.size.height), fontSize : labelFont)
        occaLabel.withText("Occasions")
        occaLabel.addTapGestureTarget(self, action: #selector(functionLabelDidTapped(_:)))
        topBar.addSubview(occaLabel)
        
        if enterInfo.filterCondition.occasion != nil {
            occaLabel.setSelected(true)
        }
        
        issueLabel = FuncLabel(frame: CGRectMake(CGRectGetMaxX(occaLabel.frame) + 10 + spacing, 0, 104 * scale, topBar.frame.size.height), fontSize : labelFont)
        issueLabel.withText("Body Issue")
        issueLabel.addTapGestureTarget(self, action: #selector(functionLabelDidTapped(_:)))
        topBar.addSubview(issueLabel)
        if enterInfo.filterCondition.bodyIssues != nil {
            issueLabel.setSelected(true)
        }
        
        let filterBtn = UIButton(frame: CGRectMake(topBar.frame.size.width - 23 * scale - 27, topBar.frame.size.height / 2 - 27 / 2, 27, 27))
        topBar.addSubview(filterBtn)
        filterBtn.withImage(UIImage(named: "FilterIcon"))
        filterBtn.addTarget(self, action: #selector(filterBtnDidClicked), forControlEvents: .TouchUpInside)
        
        let filterBtnControlArea = UIControl(frame: CGRectMake(filterBtn.frame.origin.x - 20, 0, filterBtn.frame.size.width + 40, topBar.frame.size.height))
        topBar.addSubview(filterBtnControlArea)
        filterBtnControlArea.addTarget(self, action: #selector(filterBtnDidClicked), forControlEvents: .TouchUpInside)
        
        sendFetchClothNetTask()
        
        initPromoBanner()
    }
    
    
    
    func initPromoBanner()
    {
        
        if let brandId = self.enterInfo.filterCondition.brand?.id
        {
            let banners = ConfigDataContainer.sharedInstance.getFindClothBanners()
            for oneBanner in banners {
                if oneBanner.brandId == brandId
                {
                    currentPromo = oneBanner
                }
            }
        }
        if let promo = currentPromo
        {
            promoBannerView.frame = CGRectMake(0, 36, self.view.bounds.size.width, 38);
            promoBannerView.backgroundColor = UIColor(fromHexString: "f81f34")
            //            warningBanner.font = DJFont.contentItalicFontOfSize(14)
            //            warningBanner.setContent(promo.promotionText)
            //            let len = promo.promotionText?.characters.count
            
            let titleLabel = UILabel().withTextColor(UIColor.whiteColor()).withText(promo.promotionText)
            titleLabel.frame = CGRectMake(55, 0, self.view.bounds.size.width - 55 - 30, promoBannerView.bounds.size.height)
            //            titleLabel.setTextUnderline(UIColor.whiteColor(), range: NSMakeRange(0, len!))
            titleLabel.font = DJFont.contentItalicFontOfSize(14)
            titleLabel.addTapGestureTarget(self, action: #selector(didClickPromoBannerLink))
            promoBannerView.addSubview(titleLabel)
            promoBannerView.setIcon(UIImage(named: "Bell"))
            promoBannerView.setIconMarginX(0)
            promoBannerView.contentMode = UIViewContentMode.Left
            
            let cancelBtn = UIButton()
            cancelBtn.frame = CGRectMake(promoBannerView.bounds.size.width - 45, (promoBannerView.bounds.size.height - 22) / 2, 22, 22)
            cancelBtn.clipsToBounds = true
            cancelBtn.setImage(UIImage(named: "WhiteCloseIcon"), forState: .Normal)
            cancelBtn.addTarget(self, action: #selector(closePormotionBanner), forControlEvents: .TouchUpInside)
            promoBannerView.addSubview(cancelBtn)
            
            view.addSubview(promoBannerView)
        }
        else
        {
            promoBannerView.removeFromSuperview()
        }
    }
    
    
    func closePormotionBanner()
    {
        promoBannerView.removeFromSuperview()
    }
    
    func gotoPromoPage()
    {
        
        if let promo = currentPromo
        {
            if let urlStr = promo.jumpUrl{
                if let url = NSURL(string : urlStr){
                    DJAppCall.handleOpenURL(url, sourceApplication: "deja")
                }
            }
        }
        
    }
    
    func didClickPromoBannerLink()
    {
        self.gotoPromoPage()
        if let promo = currentPromo
        {
            DJStatisticsLogic.instance().addTraceLog("\(promo.bannerId)_Campaign_Brand_Click_LearnMore");
        }
        
    }
    
    func displayPromotionAlert()
    {
        
        //        dict.setObject(true, forKey: promo.bannerId!)
        if let promo = currentPromo
        {
//            let dict = DJConfigDataContainer.instance().hasDisplayPromoAlert as NSDictionary
//            if let hasDisplayPromo = dict[promo.bannerId!] as? Int
//            {
//                if hasDisplayPromo == 1
//                {
//                    return
//                }
//            }
            promoAlertView.backgroundColor = UIColor(fromHexString: "262729", alpha: 0.45)
            promoAlertView.frame = view.bounds
            let promotionView = UIView()
            promotionView.frame = CGRectMake((self.view.bounds.size.width - 260) / 2, (self.view.bounds.size.height - 300) / 2, 260, 300)
            promotionView.backgroundColor = UIColor.whiteColor()
            
            let titleLabel = UILabel().withFontHeleticaMedium(14).withTextColor(UIColor.defaultBlack()).withText(promo.promotionAlertTitle).textCentered()
            let messageLabel = UILabel().withFontHeleticaMedium(14).withTextColor(UIColor.defaultBlack()).withText(promo.promotionAlertText).textCentered()
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            let imageView = UIImageView()
            imageView.sd_setImageWithURL(NSURL(string: promo.imageUrl!))
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            let button = UIButton().withFontHeleticaMedium(15).withTitle(promo.promotionAlertButtonText!).withTitleColor(UIColor.whiteColor())
            button.addTarget(self, action: #selector(didClickPromoAlertButton), forControlEvents: UIControlEvents.TouchUpInside)
            button.backgroundColor = UIColor.defaultBlack()
            button.layer.cornerRadius = 19
            
            
            let close = UIImageView()
            close.image = UIImage(named: "CloseGray")
            close.addTapGestureTarget(self, action: #selector(didClickPromoAlertClose))
            
            promotionView.addSubviews(titleLabel, imageView, messageLabel, button, close)
            
            constrain(titleLabel, imageView, messageLabel, button, close) { (titleLabel, imageView, messageLabel, button, close) in
                titleLabel.top == titleLabel.superview!.top
                titleLabel.left == titleLabel.superview!.left
                titleLabel.right == titleLabel.superview!.right
                titleLabel.height == 38
                
                close.top == titleLabel.top + 10
                close.right == close.superview!.right - 10
                close.width == 15
                close.height == 15
                
                imageView.top == titleLabel.bottom
                imageView.left == titleLabel.left
                imageView.right == titleLabel.right
                imageView.height == 145
                
                messageLabel.top == imageView.bottom
                messageLabel.left == titleLabel.left + 25
                messageLabel.right == titleLabel.right - 25
                messageLabel.height == 60
                
                button.top == messageLabel.bottom
                button.left == titleLabel.left + 25
                button.right == titleLabel.right - 25
                button.height == 38
                
            }
            promoAlertView.addSubview(promotionView)
            self.view.addSubview(promoAlertView)
            
//            let mutableDict = NSMutableDictionary(dictionary: dict)
//            mutableDict.setObject(1, forKey: promo.bannerId!)
//            DJConfigDataContainer.instance().hasDisplayPromoAlert = mutableDict
        }
    }
    
    func didClickPromoAlertClose()
    {
        promoAlertView.removeFromSuperview()
    }
    
    func didClickPromoAlertButton()
    {
        
        promoAlertView.removeFromSuperview()
        self.gotoPromoPage()
        if let promo = currentPromo
        {
            DJStatisticsLogic.instance().addTraceLog("\(promo.bannerId)_Campaign_Popup_Click_ViewDeals");
        }
        
    }

    func resetTitle(){
        if let tmp = enterInfo.filterCondition.keyWords {
            title = tmp
        }else if enterInfo.filterCondition.isNewArrival {
            title = "New Arrivals"
        }else if enterInfo.filterCondition.onSale {
            title = "Deals"
        }else if let tmp = enterInfo.filterCondition.brand {
            title = tmp.name
        }else if let tmp = enterInfo.filterCondition.subCategory {
            title = tmp.name
        }else{
            title = "Searched Items"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showHomeButton(true)
        
        navigationController?.navigationBarHidden = false
    }
    
    func filterBtnDidClicked(){
        issueSelectView.hideAnimation(false)
        occasionSelectView.hideAnimation(false)
        sortSelectView.hideAnimation(false)
        
        let enterC = enterInfo.filterCondition.copy() as! FilterableConditions
        
        let filterVC = FilterAllViewController(filterInfo : enterC)
        filterVC.delegate = self
        self.presentViewController(UINavigationController(rootViewController: filterVC), animated: true, completion: nil)
    }
    
    func functionLabelDidTapped(ges : UITapGestureRecognizer){
        guard let label = ges.view as? FuncLabel else{
            return
        }
        
        var selectedView = sortSelectView
        if label == occaLabel{
            selectedView = occasionSelectView
        }else if label == issueLabel{
            selectedView = issueSelectView
        }
        
        
        if selectedView.superview == nil {
            var onView : PullDownMenuView?
            if sortSelectView.superview != nil {
                onView = sortSelectView
            }else if occasionSelectView.superview != nil {
                onView = occasionSelectView
            }else if issueSelectView.superview != nil {
                onView = issueSelectView
            }
            
            let block = { () -> Void in
                self.view.insertSubview(selectedView, belowSubview: self.topBar)
                selectedView.showAnimation()
                label.closeArrow(false)
            }
            
            if onView != nil {
                onView!.hideAnimation(true, completion: block)
            }else{
                block()
            }
        }else{
            selectedView.hideAnimation()
            label.closeArrow(true)
        }
    }
    
    func didSelectOccasionName(name : String){
        occasionSelectView.hideAnimation()
        
        occaLabel.setSelected(name != self.nilSelectName)
        occaLabel.closeArrow(true)
        enterInfo.filterCondition.occasion = nil
        for one in occasions {
            if one.name == name{
                enterInfo.filterCondition.occasion = one.id
                break
            }
        }
        
        searchConditionChanged()
    }
    
    func didSelectBodyIssueName(name : String){
        issueSelectView.hideAnimation()
        
        issueLabel.setSelected(name != self.nilSelectName)
        issueLabel.closeArrow(true)
        enterInfo.filterCondition.bodyIssues = nil
        for one in bodyIssues {
            if one.name == name{
                enterInfo.filterCondition.bodyIssues = one.id
                break
            }
        }
        searchConditionChanged()
    }
    
    func didSelectSortbyName(name : String){
        sortSelectView.hideAnimation()
        sortByLabel.closeArrow(true)
        let rule = ConfigDataContainer.sharedInstance.getSortByRules().filter { $0.name == name }
        if rule.count > 0
        {
            if let value = rule[0].value
            {
                enterInfo.sortBy = value
                searchConditionChanged()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = CGRectMake(0, 36, view.frame.size.width, view.frame.size.height - 36)
    }
    
    func searchConditionChanged(){
        taskState.pageIndex = 0
        taskState.isLoading = false
        taskState.ended = false
        
        resetTitle()
        sendFetchClothNetTask()
    }
    
    func sendFetchClothNetTask(){
        if taskState.isLoading || taskState.ended {
            return
        }
        MONetTaskQueue.instance().cancelTask(searchTask)
        searchTask = FindClothesNetTask()
        
        searchTask.extractFilterCondition(enterInfo.filterCondition)
        searchTask.sortBy = enterInfo.sortBy
        searchTask.pageIndex = taskState.pageIndex
        MONetTaskQueue.instance().addTask(searchTask)
        MONetTaskQueue.instance().addTaskDelegate(self, uri: searchTask.uri())
        
        showLoading(true)
        taskState.isLoading = true
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == searchTask{
            showLoading(false)
            
            taskState.ended = searchTask.ended
            taskState.isLoading = false
            if searchTask.pageIndex == 0{
                collectionView.products.removeAll()
                collectionView.scrollToTheTop()
            }
            collectionView.products.appendContentsOf(searchTask.clothesList)
            
            collectionView.showEmptyView(collectionView.products.count == 0)
            
            if searchTask.total > 0 {
                var text =  NSString(format: DJStringUtil.localize("%d items found.", comment:""), searchTask.total) as String
                if let brandNumber = searchTask.fromBrandNumber{
                    if brandNumber > 1 {
                        text =  NSString(format: DJStringUtil.localize("%d items found from %d brands.", comment:""), searchTask.total, brandNumber) as String
                    }
                }
                collectionView.headerInfo = text
            }else{
                collectionView.headerInfo = nil
            }
            collectionView.reloadData()
            
            displayPromotionAlert()
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task == searchTask{
            showLoading(false)
            taskState.isLoading = false
        }
    }
    
    func showLoading(show : Bool){
        if show{
            MBProgressHUD.showHUDAddedTo(view, animated: true)
        }else{
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
    
    func productCollectionViewNeedLoadMore(productView: ProductCollectionView) {
        taskState.pageIndex += 1
        sendFetchClothNetTask()
    }
    
    func productCollectionViewDidSelect(productView: ProductCollectionView, product: Clothes) {
         pushClothDetailVC(product)
    }
 
    
    private lazy var sortSelectView : PullDownMenuView = {
        let one = PullDownMenuView(frame : CGRectMake(0, CGRectGetMaxY(self.topBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.topBar.frame)))
        one.setContentSelector(self, sel : #selector(didSelectSortbyName(_:)))
        one.setTheContent(self.sortByStrs, selectedIndex : 0)
        
        return one
    }()
    
    private lazy var occasionSelectView : PullDownMenuView = {
        let one = PullDownMenuView(frame : CGRectMake(0, CGRectGetMaxY(self.topBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.topBar.frame)))
        one.setContentSelector(self, sel : #selector(didSelectOccasionName(_:)))
        
        var names = [String]()
        names.append(self.nilSelectName)
        var index = 0
        for (i, one) in self.occasions.enumerate() {
            names.append(one.name)
            
            if one.id == self.enterInfo.filterCondition.occasion{
                index = i + 1
            }
        }
        one.setTheContent(names, selectedIndex : index)
        
        return one
    }()
    
    private lazy var issueSelectView : PullDownMenuView = {
        let one = PullDownMenuView(frame : CGRectMake(0, CGRectGetMaxY(self.topBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.topBar.frame)))
        one.setContentSelector(self, sel : #selector(didSelectBodyIssueName(_:)))
        
        var names = [String]()
        names.append(self.nilSelectName)
        var index = 0
        for (i, one) in self.bodyIssues.enumerate() {
            names.append(one.name)
            
            if one.id == self.enterInfo.filterCondition.bodyIssues{
                index = i + 1
            }
        }
        one.setTheContent(names, selectedIndex : index)
        return one
    }()
}

extension FindClothResultViewController: FilterAllViewControllerDelegate{
    func filterAllViewControllerDone(filterAllViewController: FilterAllViewController, filterVCCondition: FilterableConditions) {
        filterAllViewController.dismissViewControllerAnimated(true, completion: nil)
        enterInfo.filterCondition = filterVCCondition.copy() as! FilterableConditions
        searchConditionChanged()
    }
}


class FuncLabel : UILabel {
    var labelFont : CGFloat = 15
    let arrow = UIImageView()
    
    
    init(frame: CGRect, fontSize : CGFloat) {
        super.init(frame: frame)
        labelFont = fontSize
        
        withText(text).withFontHeletica(labelFont).withTextColor(DJCommonStyle.Color81)
        arrow.frame = CGRectMake(frame.size.width - 16 - 7, frame.size.height / 2 - 8 / 2 + 2, 16, 8)
        
        arrow.image = UIImage(named: "GrayArrowDown")
        addSubview(arrow)
    }
    
    func closeArrow(close : Bool){
        if close {
            arrow.image = UIImage(named: "GrayArrowDown")
        }else{
            arrow.image = UIImage(named: "GrayArrowUp")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(select : Bool){
        if select{
            self.withFontHeleticaMedium(labelFont).withTextColor(UIColor.whiteColor())
        }else{
            self.withFontHeletica(labelFont).withTextColor(DJCommonStyle.Color81)
        }
    }
    
}
