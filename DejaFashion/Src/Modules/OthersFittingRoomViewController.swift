//
//  OthersFittingRoomViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 30/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


class OthersFittingRoomViewController: DJBasicViewController, MONetTaskDelegate, UITextFieldDelegate{
    
    lazy private var dejaModelView: DJModelView = {
        var frame = CGRectZero
        if self.view.frame.size.width == 320{
            let seemFrameWidth = self.view.frame.size.width - 23 * 2 - self.funcBtnWidth
            frame.size.width = seemFrameWidth * 1.3
            frame.origin.x = 1
            frame.origin.y = 7
        }else if self.view.frame.size.width == 375{
            let seemFrameWidth = self.view.frame.size.width - 23 * 2 - self.funcBtnWidth
            frame.size.width = seemFrameWidth * 1.21
            
            frame.origin.x = 23 - seemFrameWidth * 0.1
            frame.origin.y = 7.5
        }
        else if self.view.frame.size.width == 414{
            let seemFrameWidth = self.view.frame.size.width - 23 * 2 - self.funcBtnWidth
            frame.size.width = seemFrameWidth * 1.175
            frame.origin.x = -4
            frame.origin.y = 3
        }
        frame.size.height = kDJModelViewHeight3x * frame.size.width / kDJModelViewWidth3x
        return DJModelView(frame: frame)
    }()
    let modelBGView = UIImageView()
    
    let bottomViewHeight : CGFloat = 150
    let funcBtnHeight : CGFloat = 75
    let funcBtnWidth : CGFloat = 80
    let tableView = SLExpandableTableView()
    
    var currentCategory : ClothCategory?
    var clothCache = [String : [Clothes]]()
    
    var getwardrobeNetTask = MissionWardrobeNetTask()
    
    lazy var configCategory = ConfigDataContainer.sharedInstance.getConfigCategory()
    var tableHeaderViews = [Int : UIButton]()
    var delayExpandSection : Int?
    
    private var currentClothes = [Clothes]()
    lazy var theModelInfo = FittingRoomDataContainer.sharedInstance.getDefaultModeInfo()
    let tipView = TipsView()
    var requireBtn = UIButton()
    var requireStr : String?
    var missionId = ""
    var mustTryCloth : Clothes?
    var userName : String?
    
    var avatarUrl : String? {
        didSet {
            if avatarUrl != nil {
                if let url = NSURL(string: avatarUrl!) {
                    requireBtn.sd_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "DefaultBlackAvatar"))
                }else {
                    requireBtn.setImage(UIImage(named: "DefaultBlackAvatar"), forState: .Normal)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        self.showBackBtn = true
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.None
        
        let nextBtn = UIButton(type: .Custom)
        nextBtn.frame = CGRectMake(0, 0, 70, 44)
        nextBtn.withTitle(DJStringUtil.localize("Next", comment:"")).withTitleColor(UIColor.whiteColor()).withFontHeletica(16)
        nextBtn.setTitleColor(UIColor.defaultRed(), forState: .Highlighted)
        nextBtn.sizeToFit()
        nextBtn.frame = CGRectMake(0, 0, nextBtn.frame.size.width, 44)
        nextBtn.addTarget(self, action: #selector(OthersFittingRoomViewController.nextBtnDidTapped), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextBtn)
        
        modelBGView.image = UIImage(named: "ModelBG")
        view.addSubview(modelBGView)
        view.addSubview(tableView)
        view.addSubview(dejaModelView)
        self.dejaModelView.delegate = self
        
        tableView.contentOffset = CGPointZero
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.bottomPadding = 53
        tableView.registerClass(FittingRoomClothTableCell.self, forCellReuseIdentifier: "cloth")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "other")
        
        requireBtn = UIButton(frame: CGRectMake(23, UIScreen.mainScreen().bounds.size.height - 64 - 33 - 20, 33, 33))
        requireBtn.layer.cornerRadius = 16.5
        requireBtn.clipsToBounds = true
        view.addSubview(requireBtn)
        requireBtn.setImage(UIImage(named: "DefaultBlackAvatar"), forState: .Normal)
        requireBtn.addTarget(self, action: #selector(OthersFittingRoomViewController.requireBtnDidClicked), forControlEvents: .TouchUpInside)
        
        tipView.miniHeight = 50
        tipView.viewWidth = 224
        tipView.hidden = false
        view.addSubview(tipView)
        
        dejaModelView.specailFace = StylingMissionDataContainer.sharedInstance.getFaceImageByMissionId(self.missionId)
        dejaModelView.makeupId = theModelInfo.makeupId
        dejaModelView.skinColor = theModelInfo.skinColor
        dejaModelView.hairColor = theModelInfo.hairColor
        dejaModelView.hairStyleId = theModelInfo.hairStyle
        dejaModelView.bodyShape = theModelInfo.halfBodyShap()//FittingRoomDataContainer.sharedInstance.extractHalfBodyShape(theModelInfo.fullBodyShape())
        dejaModelView.cupSize = theModelInfo.cupSize
        dejaModelView.armShape = theModelInfo.armShape()//FittingRoomDataContainer.sharedInstance.extractArmShape(theModelInfo.fullBodyShape())
        dejaModelView.legShape = theModelInfo.legShape()//FittingRoomDataContainer.sharedInstance.extractLegShape(theModelInfo.fullBodyShape())
        dejaModelView.refreshModelOnly()
    }
    
    init(missionID : String, requirement : String?, userName : String?){
        super.init(nibName: nil, bundle: nil)
        
        if userName == nil{
            title = DJStringUtil.localize("Her Fitting Room", comment:"")
        }else{
            title = userName! + DJStringUtil.localize("'s Fitting Room", comment:"")
        }
        self.userName = userName
        requireStr = requirement
        self.missionId = missionID
        getwardrobeNetTask.missionId = missionID
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: getwardrobeNetTask.uri())
        MONetTaskQueue.instance().addTask(getwardrobeNetTask)
        fetchLoading(true)//be attention, it will make viewdidload called immediately
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        modelBGView.frame = view.bounds
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 61, 0)
        tableView.frame = CGRectMake(view.frame.size.width - funcBtnWidth, 0, funcBtnWidth, view.frame.size.height)
    }
    
    func requireBtnDidClicked(){
        tipView.hidden = false
    }
    
    func updateTipView(){
        if requireStr == nil {
            return
        }
        var tipSize = CGSizeMake(100, 50)
        tipSize = tipView.updateText(requireStr!, refresh: false)
        tipView.frame = CGRectMake(61, UIScreen.mainScreen().bounds.size.height - 62 - 17 - tipSize.height, tipSize.width, tipSize.height)
        tipView.setNeedsLayout()
    }
    
    func updateFuncButtonState(section : Int, btn : UIButton){
        if self.tableView.isSectionExpanded(section){
            currentCategory = nil
            
            btn.backgroundColor = UIColor.whiteColor()
            btn.withTitleColor(UIColor.blackColor())
            tableView.didClickHeaderView(section)
        }else{
            for (key, tmpBtn) in tableHeaderViews {
                if key != section {
                    tmpBtn.withTitleColor(UIColor.blackColor())
                    tmpBtn.backgroundColor = UIColor.whiteColor()
                }
            }
            btn.backgroundColor = UIColor.blackColor()
            btn.withTitleColor(UIColor.whiteColor())
            
            if section < configCategory.count && section >= 0{
                currentCategory = configCategory[section]
            }
            tableView.didClickHeaderView(section)
        }
    }
    
    func clothTypeBtnDidTap(btn : UIButton){
        let obj = btn.property
        if !obj.isKindOfClass(ClothCategory) {
            return
        }
        let cate = obj as! ClothCategory
        
    
        for i in 0..<configCategory.count {
            if configCategory[i].categoryId == cate.categoryId {
                updateFuncButtonState(i, btn: btn)
                break
            }
        }
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == getwardrobeNetTask{
            if let mustCloth = getwardrobeNetTask.mustTryCloth{
                putonNewClothes([mustCloth])
                self.mustTryCloth = mustCloth
                self.dejaModelView.mustTryClothes = mustCloth
            }
            if (getwardrobeNetTask.clothesCateList != nil){
                clothCache = getwardrobeNetTask.clothesCateList!
                tableView.reloadData()
            }
            if let occasionId = getwardrobeNetTask.occasionId {
                if let occasionName = ConfigDataContainer.sharedInstance.getOccasionFilterNameById(occasionId) {
                    requireStr = DJStringUtil.localize("Please help me to dress for", comment:"") + occasionName
                }
            }
            updateTipView()
            
            self.fetchLoading(false)
        }else if task.isKindOfClass(CreateMissionOutfitNetTask){
            fetchLoading(false)
            let missionTask = task as! CreateMissionOutfitNetTask
            if let outfitid = missionTask.missionOutfitId{
                let v = SubmitMissionOutfitViewController(URLString : ConfigDataContainer.sharedInstance.getEditMissionOutfitUrl(outfitid))
                v.missionInfo = ["mission_id" : missionId, "mission_outfit_id" : outfitid, "user_name" : userName == nil ? "" : userName!];
                navigationController?.pushViewController(v, animated: true)
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        fetchLoading(false)
        MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Oops! Network is down.", comment:""), animated: true)
    }
    
    func clothIsOnModel(product : Clothes) -> Bool {
        for item in self.currentClothes {
            if item.uniqueID == product.uniqueID {
                return true
            }
        }
        return false
    }
    
    func nextBtnDidTapped(){
        if self.dejaModelView.isNeatlyDressedWithAlert(){
            let missionCreationNT = CreateMissionOutfitNetTask()
            missionCreationNT.clothedIds = currentProductIds()
            missionCreationNT.missionId = missionId
            
            MONetTaskQueue.instance().addTaskDelegate(self, uri: missionCreationNT.uri())
            MONetTaskQueue.instance().addTask(missionCreationNT)
            fetchLoading(true)
        }
    }
    
    func currentProductIds() -> [String] {
        var clothedIds = [String]()
        for item in self.currentClothes{
            clothedIds.append(item.uniqueID!)
        }
        return clothedIds
    }
    
    func modelClothOnCategory(categoryId : String) -> Bool {
        let clothCate = clothCache[categoryId]
        if clothCate == nil {
            return false
        }
        
        for item in self.currentClothes {
            if item.categoryID == categoryId {
                for cc in clothCate! {
                    if item.uniqueID == cc.uniqueID{
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func takeoffCloth(cloth : Clothes){
        if mustTryCloth != nil{
            if mustTryCloth!.uniqueID == cloth.uniqueID{
                MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Must wear this cloth", comment: ""), duration: 1, oY: -100)
                return
            }
        }
        for item in self.currentClothes{
            if item.uniqueID == cloth.uniqueID{
                self.currentClothes.removeAtIndex(self.currentClothes.indexOf(item)!)
                break
            }
        }
        
        putonNewClothes(self.currentClothes)
    }
    // shoes -> shoe  tops -> top
    func removeSuffixS(origin : String) -> String {
        if origin == "Dresses" {
            return "Dress"
        }else if origin.hasSuffix("s") {
            return NSString(string: origin).substringToIndex(origin.characters.count - 1)
        }
        
        return origin
    }
    
    func putonNewClothes(clothes : [Clothes]){
        if mustTryCloth != nil{
            if let conflicCloth = FittingRoomDataContainer.sharedInstance.checkConflictCloth(mustTryCloth!, newClothes: clothes){
                if conflicCloth.uniqueID != mustTryCloth!.uniqueID{
                    let cateName = WardrobeDataContainer.sharedInstance.queryCategoryNameById(mustTryCloth!.categoryID!)
                    let message = "Please style with this \(removeSuffixS(cateName!))"
                    let tip = DJLabel()
                    tip.withText(message).withTextColor(DJCommonStyle.ColorEA).textCentered().withFontHeletica(14)
                    tip.insets = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
                    tip.sizeToFit()
                    tip.frame = CGRectMake(22, 150, tip.frame.width, 34)
                    tip.backgroundColor = DJCommonStyle.backgroundColorWithAlpha(0.95)
                    view.addSubview(tip)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                        tip.removeFromSuperview()
                    }
                    return
                }
            }
        }
        
        let successB = {() -> Void in
            self.fetchLoading(false)
            self.currentClothes = FittingRoomDataContainer.sharedInstance.getFinalClothAfterPutNewCloth(self.currentClothes, products: clothes, fullBodyShape: self.theModelInfo.fullBodyShape())
            self.dejaModelView.refreshModelWithClothes(self.currentClothes)
            
            self.tableView.reloadData()
        }
        
        let failedB = {() -> Void in
            self.fetchLoading(false)
            MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Oops! Clothes have error.", comment: ""), animated: true)
        }
        
        self.fetchLoading(true)
        FittingRoomDataContainer.sharedInstance.fetchClothResource(clothes, fullBodyShape: theModelInfo.fullBodyShape(), success: successB, failed: failedB)
    }
    
    func fetchLoading(isLoading : Bool){
        if isLoading {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }else{
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
}

extension OthersFittingRoomViewController : UITableViewDelegate, UITableViewDataSource, TryonClothListViewControllerDelegate{
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return funcBtnHeight
    }
    
    func makeFuncBtn(name : String) -> UIButton {
        let btn = UIButton(frame: CGRectMake(0, 0, funcBtnWidth, funcBtnHeight))
        btn.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 3)
        btn.titleLabel?.withFontHeletica(14)
        btn.titleLabel?.numberOfLines = 0
        btn.defaultTitleColor().withTitle(name)
        btn.titleLabel?.numberOfLines = 1
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.contentHorizontalAlignment = .Left
        btn.backgroundColor = UIColor.whiteColor()
        let line = UIView(frame: CGRectMake(0, funcBtnHeight - 1, funcBtnWidth, 1))
        line.backgroundColor = UIColor(fromHexString: "cecece")
        btn.addSubview(line)
        return btn
    }
    
    func drawTriangle() -> UIImage?{
        let rect = CGRectMake(0, 0, 10, 10)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextBeginPath(ctx!)
        CGContextMoveToPoint(ctx!, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx!, CGRectGetMaxX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx!, CGRectGetMinX(rect), CGRectGetMaxY(rect))
        CGContextClosePath(ctx!)
        CGContextSetFillColorWithColor(ctx!, UIColor(fromHexString: "cccccc").CGColor)
        CGContextFillPath(ctx!);
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return ret
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if getClothCellType(indexPath) == .Info{
            return 124
        }
        return funcBtnHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let oneCate = configCategory[section]
        let nameBtn = makeFuncBtn(oneCate.name)
        nameBtn.addTarget(self, action: #selector(OthersFittingRoomViewController.clothTypeBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        nameBtn.property = oneCate
        if modelClothOnCategory(oneCate.categoryId) &&  !self.tableView.isSectionExpanded(section) {
            let ver = UIImageView(frame: CGRectMake(0, 0, 10, 10))
            ver.image = drawTriangle()
            nameBtn.addSubview(ver)
        }
        if self.tableView.isSectionExpanded(section){
            nameBtn.withTitleColor(UIColor.whiteColor())
            nameBtn.backgroundColor = UIColor.blackColor()
        }
        tableHeaderViews[section] = nameBtn
        
        
        return nameBtn
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return configCategory.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tmp = clothCache[configCategory[section].categoryId]{
            if tmp.count == 0{
                return 2
            }else{
                return tmp.count + 1
            }
        }else{
            return 2
        }
    }
    
    func doNothing(){}
    
    func getClothCellType(indexPath: NSIndexPath) -> ClothCellType{
        let category = configCategory[indexPath.section]
        var clothNumber = clothCache[category.categoryId]?.count
        if clothNumber == nil{
            clothNumber = 0
        }
        
        if indexPath.row < clothNumber{
            return .CommonCloth
        }else if clothNumber == 0 && indexPath.row == 0{
            return .Info
        }else{
            return .More
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if getClothCellType(indexPath) == .CommonCloth{
            let cell = tableView.dequeueReusableCellWithIdentifier("cloth", forIndexPath: indexPath) as! FittingRoomClothTableCell
            let category = configCategory[indexPath.section]
            let item = clothCache[category.categoryId]![indexPath.row]
            cell.product = item
            cell.setImageUrl(item.thumbUrl, colorValue: item.thumbColor)
            
            if clothIsOnModel(item) {
                cell.showSelectedIcon(true)
            }else{
                cell.showSelectedIcon(false)
            }
            
            cell.showLocker(false)
            cell.userInteractionEnabled = true
            if mustTryCloth != nil{
                if item.uniqueID == mustTryCloth!.uniqueID{
                    cell.showLocker(true)
                    cell.userInteractionEnabled = false
                }
            }
            
            if item.isInWardrobe == nil {
                cell.showRecommandLabel(true)
            }else{
                cell.showRecommandLabel(!(item.isInWardrobe!))
            }
            return cell
        }else if getClothCellType(indexPath) == .More{
            let cell = tableView.dequeueReusableCellWithIdentifier("other", forIndexPath: indexPath)
            cell.removeAllSubViews()
            cell.backgroundColor = UIColor(fromHexString: "eaeaea")
            let label = UILabel(frame: CGRectMake(0, 0, funcBtnWidth, funcBtnHeight))
            label.withFontHeletica(14).withTextColor(UIColor.gray81Color())
            label.numberOfLines = 0
            label.textAlignment = .Center
            if let name = currentCategory?.name {
                label.text = DJStringUtil.localize("More ", comment: "") + name + " >"
            }
            cell.addSubview(label)
            let lineView = UIView()
            lineView.frame = CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)
            lineView.backgroundColor = UIColor(fromHexString: "cecece")
            cell.addSubview(lineView)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("other", forIndexPath: indexPath)
            cell.removeAllSubViews()
            cell.backgroundColor = UIColor.whiteColor()
            let label = UILabel(frame: CGRectMake(0, 0, funcBtnWidth, 124))
            label.withFontHeletica(14).withTextColor(UIColor(fromHexString: "cecece")).withText(DJStringUtil.localize("Your wardrobe doesn’t have any item in this category.", comment:""))
            label.numberOfLines = 0
            label.textAlignment = .Center
            label.addTapGestureTarget(self, action: #selector(OthersFittingRoomViewController.doNothing))
            cell.addSubview(label)
            let lineView = UIView()
            lineView.frame = CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)
            lineView.backgroundColor = UIColor(fromHexString: "cecece")
            cell.addSubview(lineView)
            return cell
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let category = configCategory[indexPath.section]
        if clothCache[category.categoryId] == nil {
            clothCache[category.categoryId] = [Clothes]()
        }
        
        if getClothCellType(indexPath) == .CommonCloth{
            let product = clothCache[category.categoryId]![indexPath.row]
            
            if clothIsOnModel(product){
                takeoffCloth(product)
            }else{
                putonNewClothes([product])
                DJStatisticsLogic.instance().addTraceLog("\(StatisticsKey.FittingRoom_Click_Change)_\(category.name)")
            }
        }
        
        if getClothCellType(indexPath) == .More{
            DJStatisticsLogic.instance().addTraceLog("\(StatisticsKey.FittingRoom_Click_More)_\(category.name)")
            let resultVC = TryonClothListViewController(category: category)
            resultVC.clickClothReturn = true
            resultVC.delegate = self
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tryonClothListViewControllerDidChooseCloth(vc: TryonClothListViewController, product: Clothes) {
        let cate = vc.category
        if cate == nil {
            return
        }
        putonNewClothes([product])
    }
}

extension OthersFittingRoomViewController : DJModelViewDelegate{
    func modelView(modelView: DJModelView!, didClickProductDetail product: Clothes!) {
        pushClothDetailVC(product)
    }
    
    func modelView(modelView: DJModelView!, didClickTakeOff product: Clothes!) {
        takeoffCloth(product)
    }
}

 
