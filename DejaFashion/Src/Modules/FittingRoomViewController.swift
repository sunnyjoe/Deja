//
//  FittingRoomViewController.swift
//  DejaFashion
//
//  Created by jiao qing on 11/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

enum FunctionType {
    case Makeup
    case HairStyle
    case None
}

class FittingRoomViewController: DJBasicViewController, MONetTaskDelegate, UITextFieldDelegate{
    
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
    private let modelBGView = UIImageView()
    
    private let bottomViewHeight : CGFloat = 150
    private let funcBtnHeight : CGFloat = 75
    private let funcBtnWidth : CGFloat = 80
    private let tableView = SLExpandableTableView()
    
    private var currentCategory : ClothCategory?
    private var clothCache = [String : [Clothes]]()
    
    private var functionType = FunctionType.None
    private var getRecommendNetTask : FittingRoomRecommendNetTask?
    private var clothesInfoNetTask : GetClothesInfoNetTask?
    
    private var scoreView : WaterProgressView?
    
    private var makeupStyleList : [UIImage]?
    private var hairStyleList : [UIImage]?
    private var makeupColorPanel = UIView()
    private var hairColorPanel = UIView()
    
    private let saveBtn = DJButton()
    private let styleSaveNetTask = SaveStyleBookNetTask()
    private var getScoreNetTask = FittingRoomDejaScoreNetTask()
    private var filterView : OccasionFilterView?
    private let filterBtn = DJButton()
    private var selectedFilter = [Filter]()
    private let filterScrollViewBar = UIScrollView()
    private var selectedFilterBtns = [UIButton]()
    
    private let tipView = TipsView()
    private var missionTipView : TipsView?
    private var configCategory = [ClothCategory]()
    private var tableHeaderViews = [Int : UIButton]()
    private var delayExpandSection : Int?
    private var redDot : UIView?
    
    private var reshapeBtn = UIButton()
    private var finishTag = [false, false]
    private var missionBtn = UIButton()
    
    private var currentClothes = [Clothes]()
    var neeRefreshModelAndCloth = false
    
    private var tryonVCs = [String : TryonClothListViewController]()
    
    private var bodyShapeTip : DJTutorialView?
    lazy var myModelInfo = FittingRoomDataContainer.sharedInstance.getMyModelInfo()
    
    var tryonCounter = 0
    override init(){
        super.init()
        configCategory = ConfigDataContainer.sharedInstance.getConfigCategory()
        getFaceFuncs()
    }
    
    deinit {
        redDot?.removeFromSuperview()
        redDot = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.showBackBtn = true
        super.viewDidLoad()
        
        title = DJStringUtil.localize("Fitting Room", comment:"")
        self.edgesForExtendedLayout = UIRectEdge.None
        
        let styleBookBtn = UIButton(type: .Custom)
        styleBookBtn.frame = CGRectMake(0, 0, 70, 44)
        styleBookBtn.withTitle(DJStringUtil.localize("Favourites", comment:"")).withTitleColor(UIColor.whiteColor()).withFontHeletica(16)
        styleBookBtn.setTitleColor(UIColor.defaultRed(), forState: .Highlighted)
        styleBookBtn.sizeToFit()
        styleBookBtn.frame = CGRectMake(0, 0, styleBookBtn.frame.size.width, 44)
        styleBookBtn.addTarget(self, action: #selector(FittingRoomViewController.styleBookBtnDidTapped), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: styleBookBtn)
        
        modelBGView.image = UIImage(named: "ModelBG")
        view.userInteractionEnabled = true
        view.addSubview(modelBGView)
        view.addSubview(tableView)
        view.addSubview(dejaModelView)
        self.dejaModelView.delegate = self
        
        view.addSubview(saveBtn)
        saveBtn.frame = CGRectMake(23, 16, 38, 35)
        saveBtn.setImage(UIImage(named: "AddStyleIcon"), forState: .Normal)
        saveBtn.setImage(UIImage(named: "AddStyleRedIcon"), forState: .Highlighted)
        saveBtn.addTarget(self, action: #selector(FittingRoomViewController.saveBtnDidTapped), forControlEvents: .TouchUpInside)
        
        tableView.contentOffset = CGPointZero
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.bottomPadding = 53
        tableView.registerClass(FittingRoomClothTableCell.self, forCellReuseIdentifier: "cloth")
        tableView.registerClass(FittingRoomFaceTableCell.self, forCellReuseIdentifier: "face")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "other")
        
        view.addSubview(filterBtn)
        filterBtn.addTarget(self, action: #selector(FittingRoomViewController.filterBtnDidTapped), forControlEvents: .TouchUpInside)
        filterBtn.setImage(UIImage(named: "FilterBlackIcon"), forState: .Normal)
        filterBtn.layer.cornerRadius = 16.5
        filterBtn.layer.borderColor = UIColor.blackColor().CGColor
        filterBtn.layer.borderWidth = 0.7
        
        view.addSubview(filterScrollViewBar)
        filterScrollViewBar.backgroundColor = UIColor.whiteColor()
        filterScrollViewBar.layer.borderWidth = 1
        filterScrollViewBar.contentInset = UIEdgeInsetsMake(10, 23, 10, 23)
        filterScrollViewBar.layer.borderColor = UIColor(fromHexString: "cecece").CGColor
        filterScrollViewBar.hidden = true
        
        missionBtn.setImage(UIImage(named: "QuestionIcon"), forState: .Normal)
        missionBtn.addTarget(self, action: #selector(FittingRoomViewController.missionBtnDidTapped), forControlEvents: .TouchUpInside)
        //        view.addSubview(missionBtn)
        
        reshapeBtn.setImage(UIImage(named: "BodyReshapeIcon"), forState: .Normal)
        reshapeBtn.addTarget(self, action: #selector(FittingRoomViewController.reshapeBtnDidTapped), forControlEvents: .TouchUpInside)
        view.addSubview(reshapeBtn)
        
        scoreView = WaterProgressView(frame: CGRectMake(23, UIScreen.mainScreen().bounds.size.height - 64 - 98, 33, 33))
        scoreView?.setProgress(0.1, animated: true)
        scoreView?.delegate = self
        view.addSubview(scoreView!)
        
        tipView.frame = CGRectMake(0, 0, 224, 50)
        tipView.delegate = self
        tipView.miniHeight = 50
        tipView.viewWidth = 224
        tipView.hidden = true
        view.addSubview(tipView)
        //        DJStatisticsLogic.instance().addTraceLog(kStatisticsID_enter_fitting_room)
        
        reGetMyModelInfo()
        
        dejaModelView.refreshModelOnly()
        if FittingRoomDataContainer.sharedInstance.firstTimeEnterFittingRoom(){
            let oY = UIScreen.mainScreen().bounds.size.height - 64 - 98 - 35 - 10 - 32
            bodyShapeTip = DJTutorialView(frame: CGRect(x: 62, y: oY, width: 270, height: 100), direction: DJTurorialViewArrowDirectionLeft)
            bodyShapeTip!.setText(DJStringUtil.localize("You can customize the body shape of the model here", comment: ""))
            view.addSubview(bodyShapeTip!)
        }
    }
    
    func reGetMyModelInfo(){
        myModelInfo = FittingRoomDataContainer.sharedInstance.getMyModelInfo()
        dejaModelView.makeupId = myModelInfo.makeupId
        dejaModelView.skinColor = myModelInfo.skinColor
        dejaModelView.hairColor = myModelInfo.hairColor
        dejaModelView.hairStyleId = myModelInfo.hairStyle
        dejaModelView.bodyShape = myModelInfo.halfBodyShap()//FittingRoomDataContainer.sharedInstance.extractHalfBodyShape(myModelInfo.fullBodyShape())
        dejaModelView.cupSize = myModelInfo.cupSize
        dejaModelView.armShape = myModelInfo.armShape()//FittingRoomDataContainer.sharedInstance.extractArmShape(myModelInfo.fullBodyShape())
        dejaModelView.legShape = myModelInfo.legShape()//FittingRoomDataContainer.sharedInstance.extractLegShape(myModelInfo.fullBodyShape())
    }
    
    func sendGetRecommendTask(clothes : [String]?, filters : [Filter]?) {
        getRecommendNetTask = FittingRoomRecommendNetTask()
        if filters != nil{
            selectedFilter = filters!
            getRecommendNetTask?.refineIds = extractFilterIds(filters!)
        }
        getRecommendNetTask?.onBodyClothIds = clothes
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: getRecommendNetTask?.uri())
        MONetTaskQueue.instance().addTask(getRecommendNetTask)
        fetchLoading(true)
    }
    
    func setEnterCondition(clothes : [String]?, filters : [Filter]?){
        sendGetClothesInfoTask(clothes)
        
        if filters != nil{
            selectedFilter = filters!
        }
        sendGetRecommendTask(clothes, filters: filters)
    }
    
    func sendGetClothesInfoTask(clothes : [String]?) {
        if clothes?.count > 0 {
            clothesInfoNetTask = GetClothesInfoNetTask()
            clothesInfoNetTask!.clothedIds = clothes!
            
            MONetTaskQueue.instance().addTaskDelegate(self, uri: clothesInfoNetTask!.uri())
            MONetTaskQueue.instance().addTask(clothesInfoNetTask)
            fetchLoading(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateFilterBar()
        
        if neeRefreshModelAndCloth {
            putonNewClothes(self.currentClothes)
            neeRefreshModelAndCloth = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        redDot?.removeFromSuperview()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        modelBGView.frame = view.bounds
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 61, 0)
        tableView.frame = CGRectMake(view.frame.size.width - funcBtnWidth, 0, funcBtnWidth, view.frame.size.height)
        
        missionBtn.frame = CGRectMake(22, reshapeBtn.frame.origin.y - 35 - 10, 35, 35)
        reshapeBtn.frame = CGRectMake(22, view.frame.size.height - 98 - 35 - 10, 35, 35)
        filterBtn.frame = CGRectMake(23, view.frame.size.height - 53, 33, 33)
        filterScrollViewBar.frame = CGRectMake(-1, view.frame.size.height - 53, view.frame.size.width + 2, 53)
    }
    
    func missionBtnDidTapped(){
        //        DJStatisticsLogic.instance().addTraceLog(kStatisticsID_fitting_room_help)
        if AccountDataContainer.sharedInstance.isAnonymous() {
            let v = LoginViewController()
            self.navigationController?.pushViewController(v, animated: true)
            return
        }
        
        let v = StylingMissionCreatingViewController()
        self.navigationController?.pushViewController(v, animated: true)
    }
    
    func reshapeBtnDidTapped(){
        let v = BodyReshapeViewController()
        navigationController?.pushViewController(v, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.FittingRoom_Click_BodyAdjustment)
    }
    
    func styleBookBtnDidTapped(){
        let v = StyleBookViewController(URLString: ConfigDataContainer.sharedInstance.getStyleBookUrl() + "tab=1")
        navigationController?.pushViewController(v, animated: true)
        DJStatisticsLogic.instance().addTraceLog(.FittingRoom_Click_Favourites)
    }
    
    func sendSaveStyleNetTask(){
        fetchLoading(true)
        styleSaveNetTask.clothedIds = currentProductIds()
        styleSaveNetTask.tmplate = nil
        MONetTaskQueue.instance().addTaskDelegate(self, uri: styleSaveNetTask.uri())
        MONetTaskQueue.instance().addTask(styleSaveNetTask)
    }
    
    func saveBtnDidTapped(){
        DJStatisticsLogic.instance().addTraceLog(.FittingRoom_Click_Save)
        if self.dejaModelView.isNeatlyDressedWithAlert() {
            sendSaveStyleNetTask()
            return
        }
    }
    
    func fillColorPanel(funcType : FunctionType){
        var colorView = makeupColorPanel
        var colorArray = [String]()
        var selectedColor = ""
        if funcType == .Makeup {
            colorView.removeAllSubViews()
            colorArray = FittingRoomDataContainer.sharedInstance.skinColorArray
            selectedColor = myModelInfo.skinColor
        }else{
            colorView = hairColorPanel
            colorView.removeAllSubViews()
            colorArray = FittingRoomDataContainer.sharedInstance.hairColorArray
            selectedColor = myModelInfo.hairColor
        }
        colorView.backgroundColor = UIColor.whiteColor()
        
        let spacing : CGFloat = 0.5
        let btnWidth = CGFloat(funcBtnWidth - spacing) / 2
        let btnHeight : CGFloat = 29.5
        var oX : CGFloat = 0
        var oY = spacing
        for colorValue in colorArray {
            let cBtn = DJButton(frame: CGRectMake(oX, oY, btnWidth, btnHeight))
            cBtn.setBackgroundColor(UIColor(fromHexString: colorValue), forState: .Normal)
            cBtn.property = colorValue
            cBtn.addTarget(self, action: #selector(FittingRoomViewController.colorBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            colorView.addSubview(cBtn)
            
            if selectedColor == colorValue {
                let icon = UIImageView(frame: CGRectMake(btnWidth / 2 - 9, 5.5, 18, 18))
                icon.image = UIImage(named: "SelectorIcon")
                if funcType == .Makeup{
                    icon.image = UIImage(named: "SelectorBlackIcon")
                }
                cBtn.addSubview(icon)
            }
            
            oX += btnWidth + spacing
            if oX + btnWidth > funcBtnWidth && colorArray.indexOf(colorValue) < colorArray.count - 1{
                oX = 0
                oY += btnHeight + spacing * 2
            }
        }
        colorView.frame = CGRectMake(0, 23, funcBtnWidth, oY + btnHeight + spacing)
    }
    
    func colorBtnDidTap(cBtn : UIButton){
        var cv = cBtn.property
        if (cv as? String) != nil{
            cv = cv as! String
        }else{
            return
        }
        
        if functionType == .Makeup {
            dejaModelView.skinColor = cv as! String
            myModelInfo.skinColor = dejaModelView.skinColor
        }else if functionType == .HairStyle{
            dejaModelView.hairColor = cv as! String
            myModelInfo.hairColor = dejaModelView.hairColor
        }
        
        fillColorPanel(functionType)
        tableView.reloadData()
        
        dejaModelView.refreshModelWithClothes(self.currentClothes)
        FittingRoomDataContainer.sharedInstance.updateMyModelInfo(myModelInfo)
    }
    
    func getFaceFuncs(){
        if hairStyleList == nil {
            hairStyleList = [UIImage]()
            
            let hairModels = DJSelectionModels.getHairModels()
            let hairType = hairModels.objectForKey("type")
            if hairType == nil {
                return
            }
            var j = 0
            while j < hairType!.count {
                if let typeName = hairType?.objectAtIndex(j) {
                    if let hairModelsLengthType = hairModels.objectForKey(typeName){
                        var detailHairs = hairModelsLengthType as? [AnyObject]
                        var index = 0
                        while index < detailHairs?.count {
                            let hairId = detailHairs![index]
                            let imageName = "r_f_hair\(hairId).png"
                            hairStyleList?.append(UIImage(named: imageName)!)
                            index += 1
                        }
                    }
                }
                j += 1
            }
            
        }
        
        if makeupStyleList == nil {
            makeupStyleList = [UIImage]()
            let makeupModel = DJSelectionModels.getMakeupOrder()
            var index = 1
            
            while index < makeupModel.count {
                let makeupId = makeupModel.objectForKey(NSString(format: "position%d", index))?.integerValue
                if let makeupImage = UIImage(named: String("\(makeupId!)MakeupModel.png")) {
                    makeupStyleList!.append(makeupImage)
                }
                index += 1
            }
        }
    }
    
    func hairStyleBtnDidTap(btn : UIButton){
        functionType = .HairStyle
        updateFuncButtonState(configCategory.count + 1, btn: btn)
    }
    
    func makeUpBtnDidTap(btn : UIButton){
        functionType = .Makeup
        updateFuncButtonState(configCategory.count, btn: btn)
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
        
        for i in 0 ..< configCategory.count {
            
            if configCategory[i].categoryId == cate.categoryId {
                updateFuncButtonState(i, btn: btn)
                break
            }
        }
    }
    
    func takeoffCloth(cloth : Clothes){
        for item in self.currentClothes{
            if item.uniqueID == cloth.uniqueID{
                self.currentClothes.removeAtIndex(self.currentClothes.indexOf(item)!)
                break
            }
        }
        putonNewClothes(self.currentClothes)
    }
    
    func putonNewClothes(clothes : [Clothes]){
        tryonCounter += 1
        if tryonCounter >= 5{
            //            if !FittingRoomDataContainer.sharedInstance.isMissionTipShowedForLast1day(){
            //                FittingRoomDataContainer.sharedInstance.setMissionLastTipShowTime()
            //                let hintView = TipsView(frame: CGRectMake(CGRectGetMaxX(missionBtn.frame) + 3, missionBtn.frame.origin.y - 20, 260, 65))
            //                hintView.setTextContent(DJStringUtil.localize("Can’t find a suitable outfit? Click to invite your friends to help you create more outfits.", comment:""))
            //                view.addSubview(hintView)
            //                missionTipView = hintView
            //                tipView.hidden = true
            //            }
        }
        
        let successB = {() -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            self.currentClothes = FittingRoomDataContainer.sharedInstance.getFinalClothAfterPutNewCloth(self.currentClothes, products: clothes, fullBodyShape: self.myModelInfo.fullBodyShape())
            self.dejaModelView.refreshModelWithClothes(self.currentClothes)
            
            self.tableView.reloadData()
            self.sendGetScoreNetTask()
            self.saveBtn.setImage(UIImage(named: "AddStyleIcon"), forState: .Normal)
        }
        
        let failedB = {() -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Oops! Clothes have error.", comment: ""), animated: true)
        }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        FittingRoomDataContainer.sharedInstance.fetchClothResource(clothes, fullBodyShape: myModelInfo.fullBodyShape(), success: successB, failed: failedB)
    }
    
    func netTaskDidEnd(task: MONetTask!) {
        if task == getRecommendNetTask{
            if (getRecommendNetTask!.clothesCateList != nil){
                clothCache = getRecommendNetTask!.clothesCateList!
                tableView.reloadData()
            }
            fetchLoading(false)
        }else if task == clothesInfoNetTask {
            fetchLoading(false)
            let infoTask = task as! GetClothesInfoNetTask
            if infoTask.clothesList != nil {
                putonNewClothes(infoTask.clothesList!)
            }
        }else if task == styleSaveNetTask{
            fetchLoading(false)
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()) {
                self.saveBtn.setImage(UIImage(named: "AddStyleRedIcon"), forState: .Normal)
            }
            
            let heart = UIImageView(image: UIImage(named: "RedHeart"))
            heart.frame = CGRectMake(40, 100, 24, 20)
            navigationController?.view.addSubview(heart)
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                heart.frame = CGRectMake(ScreenWidth - 30 ,30, 0, 0)
                }, completion: { (finished) -> Void in
                    heart.removeFromSuperview()
                    if self.redDot == nil {
                        self.redDot = UIView(frame: CGRect(x: ScreenWidth - 18, y: 35, width: 8, height: 8)).withBackgroundColor(DJCommonStyle.ColorRed)
                    }
                    self.redDot?.layer.cornerRadius = (self.redDot?.frame.size.width)! / 2
                    self.navigationController?.view.addSubview(self.redDot!)
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                        self.redDot?.removeFromSuperview()
                    }
            })
        }else if task == getScoreNetTask {
            if let scoreClothIds = getScoreNetTask.clothedIds{
                if !scoreClothIds.compareEqualityWithoutOrder(currentProductIds()) {
                    return
                }
            }
            updateTipView()
            if let tmp = getScoreNetTask.score{
                scoreView?.setProgress(CGFloat(tmp) / 10, animated: true)
            }else{
                scoreView?.setProgress(1 / 10, animated: true)
            }
        }else if task.isKindOfClass(GetinspirationNetTask) {
            fetchLoading(false)
            let inspTask = task as! GetinspirationNetTask
            if inspTask.clothesList != nil{
                self.currentClothes.removeAll()
                putonNewClothes(inspTask.clothesList!)
            }
        }
    }
    
    func netTaskDidFail(task: MONetTask!) {
        if task != getScoreNetTask{
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
        }
        MBProgressHUD.showHUDAddedTo(self.view, text: DJStringUtil.localize("Oops! Network down.", comment: ""), animated: true)
    }
    
    override func notificationNames() -> [AnyObject]! {
        return [DJNotifyDejaModelShapeChanged]
    }
    
    override func didReceiveNotification(notification: NSNotification!) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let eventName = notification.name
            if eventName == DJNotifyDejaModelShapeChanged{
                self.neeRefreshModelAndCloth = true
                self.reGetMyModelInfo()
            }
        })
    }
    
    func currentProductIds() -> [String] {
        var clothedIds = [String]()
        for item in self.currentClothes{
            clothedIds.append(item.uniqueID!)
        }
        return clothedIds
    }
    
    func sendGetScoreNetTask(){
        MONetTaskQueue.instance().cancelTask(getScoreNetTask)
        
        let tmp = currentProductIds()
        if tmp.count == 0 {
            return
        }
        getScoreNetTask = FittingRoomDejaScoreNetTask()
        getScoreNetTask.clothedIds = tmp
        getScoreNetTask.refineIds = extractFilterIds(selectedFilter)
        getScoreNetTask.score = nil
        getScoreNetTask.tips = nil
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: getScoreNetTask.uri())
        MONetTaskQueue.instance().addTask(getScoreNetTask)
    }
    
    func clothIsOnModel(product : Clothes) -> Bool {
        for item in self.currentClothes {
            if item.uniqueID == product.uniqueID {
                return true
            }
        }
        return false
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
    
    
    func fetchLoading(isLoading : Bool){
        if isLoading {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }else{
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
}

extension FittingRoomViewController : WaterProgressViewDelegate, TipsViewDelegate{
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first {
            let position : CGPoint = touch.locationInView(view)
            let viewHit = view.hitTest(position, withEvent: event)
            if viewHit != dejaModelView {
                dejaModelView.removeMenuViewIfDisplay()
            }
        }
    }
    
    func waterProgressViewDidClick(waterProgressView: WaterProgressView!) {
        if tipView.hidden == false{
            tipView.hidden = true
            return
        }
        tipView.hidden = false
        updateTipView()
        
        DJStatisticsLogic.instance().addTraceLog(.FittingRoom_Click_Tips)
    }
    
    func tipsViewDidClickRecommand(tipsView: TipsView) {
        sendGetInspirationNetTask()
        tipsView.hidden = true
    }
    
    func sendGetInspirationNetTask(){
        fetchLoading(true)
        
        let inspNetTask = GetinspirationNetTask()
        inspNetTask.refineIds = extractFilterIds(selectedFilter)
        
        MONetTaskQueue.instance().addTaskDelegate(self, uri: inspNetTask.uri())
        MONetTaskQueue.instance().addTask(inspNetTask)
    }
    
    func updateTipView(){
        if bodyShapeTip?.superview != nil{
            tipView.hidden = true
            return
        }
        
        if let v = missionTipView {
            if v.superview != nil && !v.hidden {
                return
            }
        }
        
        if let score = getScoreNetTask.score {
            if score == 10 {
                tipView.hidden = false
            }
        }
        
        if getScoreNetTask.needRefresh {
            tipView.hidden = false
        }
        
        var tipSize = CGSizeMake(100, 50)
        if getScoreNetTask.tips != nil {
            tipSize = tipView.updateText(getScoreNetTask.tips!, refresh: false)
        }else{
            tipSize = tipView.updateText("...", refresh: false)
        }
        
        tipView.frame = CGRectMake(61, view.frame.size.height - 62 - tipSize.height, tipSize.width, tipSize.height)
        tipView.setNeedsLayout()
    }
}
enum SectionType {
    case Cloth
    case MakeUp
    case HairStyle
}

enum ClothCellType {
    case Info
    case More
    case CommonCloth
    case Error
}

extension FittingRoomViewController : UITableViewDelegate, UITableViewDataSource, TryonClothListViewControllerDelegate{
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView.isSectionExpanded(section) && section == configCategory.count{
            return funcBtnHeight + 90
        }else if self.tableView.isSectionExpanded(section) && section == configCategory.count + 1{
            return funcBtnHeight + 120
        }
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
        let ctx = UIGraphicsGetCurrentContext()!
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect))
        CGContextClosePath(ctx)
        CGContextSetFillColorWithColor(ctx, UIColor(fromHexString: "cccccc").CGColor)
        CGContextFillPath(ctx);
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return ret
    }
    
    func cellSectionType(section: Int) -> SectionType{
        if section < configCategory.count{
            return .Cloth
        }else if section == configCategory.count{
            return .MakeUp
        }else{
            return .HairStyle
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cellSectionType(indexPath.section) == .Cloth{
            if getClothCellType(indexPath) == .Info{
                return 124
            }
        }
        return funcBtnHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var tmp : UIView?
        if cellSectionType(section) == .Cloth{
            let oneCate = configCategory[section]
            let nameBtn = makeFuncBtn(oneCate.name)
            nameBtn.addTarget(self, action: #selector(FittingRoomViewController.clothTypeBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            nameBtn.property = oneCate
            if modelClothOnCategory(oneCate.categoryId) &&  !self.tableView.isSectionExpanded(section) {
                let ver = UIImageView(frame: CGRectMake(0, 0, 10, 10))
                ver.image = drawTriangle()
                nameBtn.addSubview(ver)
            }
            if self.tableView.isSectionExpanded(section) {
                nameBtn.withTitleColor(UIColor.whiteColor())
                nameBtn.backgroundColor = UIColor.blackColor()
            }
            tmp = nameBtn
            tableHeaderViews[section] = nameBtn
        }else if cellSectionType(section) == .MakeUp{
            let coverView = UIView()
            let makeUpBtn = makeFuncBtn(DJStringUtil.localize("Make Up", comment:""))
            makeUpBtn.frame = CGRectMake(0, 0, funcBtnWidth, funcBtnHeight)
            makeUpBtn.addTarget(self, action: #selector(FittingRoomViewController.makeUpBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            tableHeaderViews[section] = makeUpBtn
            coverView.addSubview(makeUpBtn)
            if self.tableView.isSectionExpanded(section){
                makeUpBtn.withTitleColor(UIColor.whiteColor())
                makeUpBtn.backgroundColor = UIColor.blackColor()
                if makeupColorPanel.subviews.count == 0{
                    fillColorPanel(.Makeup)
                }
                makeupColorPanel.frame = CGRectMake(0, funcBtnHeight - makeupColorPanel.frame.size.height, funcBtnWidth, makeupColorPanel.frame.size.height)
                coverView.addSubview(makeupColorPanel)
                makeupColorPanel.alpha = 0
                UIView.animateWithDuration(0.3, animations: {
                    self.makeupColorPanel.alpha = 1
                    self.makeupColorPanel.frame = CGRectMake(0, self.funcBtnHeight, self.funcBtnWidth, 90)
                })
            }
            tmp = coverView
        }else{
            let coverView = UIView()
            let hairStyleBtn = makeFuncBtn(DJStringUtil.localize("Hair Style", comment:""))
            hairStyleBtn.frame = CGRectMake(0, 0, funcBtnWidth, funcBtnHeight)
            hairStyleBtn.addTarget(self, action: #selector(FittingRoomViewController.hairStyleBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            coverView.addSubview(hairStyleBtn)
            tableHeaderViews[section] = hairStyleBtn
            if self.tableView.isSectionExpanded(section){
                hairStyleBtn.withTitleColor(UIColor.whiteColor())
                hairStyleBtn.backgroundColor = UIColor.blackColor()
                if hairColorPanel.subviews.count == 0{
                    fillColorPanel(.HairStyle)
                }
                hairColorPanel.frame = CGRectMake(0, funcBtnHeight - hairColorPanel.frame.size.height, funcBtnWidth, hairColorPanel.frame.size.height)
                coverView.addSubview(hairColorPanel)
                hairColorPanel.alpha = 0
                UIView.animateWithDuration(0.1, animations: {
                    self.hairColorPanel.alpha = 1
                    self.hairColorPanel.frame = CGRectMake(0, self.funcBtnHeight, self.funcBtnWidth, 120)
                })
            }
            
            tmp = coverView
        }
        
        if tmp == nil {
            return nil
        }
        return tmp
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return configCategory.count + 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 0{
            return 0
        }
        switch cellSectionType(section){
        case .Cloth:
            if let tmp = clothCache[configCategory[section].categoryId]{
                if tmp.count == 0{
                    return 2
                }else{
                    return tmp.count + 1
                }
            }else{
                return 2
            }
        case .MakeUp:
            return makeupStyleList!.count
        case .HairStyle:
            return hairStyleList!.count
        }
    }
    
    func doNothing(){}
    
    func getClothCellType(indexPath: NSIndexPath) -> ClothCellType{
        if cellSectionType(indexPath.section) != .Cloth {
            return .Error
        }
        
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
        switch cellSectionType(indexPath.section){
        case .Cloth:
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
                label.addTapGestureTarget(self, action: #selector(FittingRoomViewController.doNothing))
                cell.addSubview(label)
                let lineView = UIView()
                lineView.frame = CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)
                lineView.backgroundColor = UIColor(fromHexString: "cecece")
                cell.addSubview(lineView)
                return cell
            }
        case .MakeUp:
            let cell = tableView.dequeueReusableCellWithIdentifier("face", forIndexPath: indexPath) as! FittingRoomFaceTableCell
            let item = makeupStyleList![indexPath.row]
            cell.setImageViewImage(item)
            cell.smallerImageView()
            let index = indexPath.row + 1
            if myModelInfo.makeupId == getMakeIdByRow(index) {
                cell.showSelectedIcon(true)
            }else{
                cell.showSelectedIcon(false)
            }
            return cell
        case .HairStyle:
            let cell = tableView.dequeueReusableCellWithIdentifier("face", forIndexPath: indexPath) as! FittingRoomFaceTableCell
            let item = hairStyleList![indexPath.row]
            cell.setImageViewImage(item)
            cell.normalImageView()
            let index = indexPath.row
            if myModelInfo.hairStyle == getHairIdByRow(index) {
                cell.showSelectedIcon(true)
            }else{
                cell.showSelectedIcon(false)
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if cellSectionType(indexPath.section) == .Cloth{
            let category = configCategory[indexPath.section]
            if clothCache[category.categoryId] == nil {
                clothCache[category.categoryId] = [Clothes]()
            }
            
            if getClothCellType(indexPath) == .CommonCloth{
                let product = clothCache[category.categoryId]![indexPath.row]
                if clothIsOnModel(product){
                    takeoffCloth(product)
                    self.dejaModelView.refreshModelWithClothes(self.currentClothes)
                }else{
                    putonNewClothes([product])
                    DJStatisticsLogic.instance().addTraceLog("\(StatisticsKey.FittingRoom_Click_Change)_\(category.name)")
                }
            }
            
            if getClothCellType(indexPath) == .More{
                DJStatisticsLogic.instance().addTraceLog("\(StatisticsKey.FittingRoom_Click_More)_\(category.name)")
                if let resultVC = tryonVCs[category.categoryId] {
                    self.navigationController?.pushViewController(resultVC, animated: true)
                }else{
                    let resultVC = TryonClothListViewController(category: category)
                    resultVC.clickClothReturn = true
                    resultVC.delegate = self
                    tryonVCs[category.categoryId] = resultVC
                    self.navigationController?.pushViewController(resultVC, animated: true)
                }
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if cellSectionType(indexPath.section) == .MakeUp{
            let index = indexPath.row + 1
            dejaModelView.makeupId = getMakeIdByRow(index)
            dejaModelView.refreshModelWithClothes(self.currentClothes)
            myModelInfo.makeupId = dejaModelView.makeupId
            FittingRoomDataContainer.sharedInstance.updateMyModelInfo(myModelInfo)
            self.tableView.reloadData()
            
            DJStatisticsLogic.instance().addTraceLog(.FittingRoom_Click_Makeup)
        }
        else{
            let index = indexPath.row
            dejaModelView.hairStyleId = getHairIdByRow(index)
            dejaModelView.refreshModelWithClothes(self.currentClothes)
            myModelInfo.hairStyle = dejaModelView.hairStyleId
            FittingRoomDataContainer.sharedInstance.updateMyModelInfo(myModelInfo)
            self.tableView.reloadData()
            DJStatisticsLogic.instance().addTraceLog(.FittingRoom_Click_Hairstyle)
        }
    }
    
    func getMakeIdByRow(index : Int) -> String{
        let makeupModel = DJSelectionModels.getMakeupOrder()
        let makeupId = makeupModel.objectForKey(NSString(format: "position%d", index)) as! String
        return makeupId
    }
    
    func getHairIdByRow(index : Int) -> String{
        let hairStyle = DJSelectionModels.getHairModels()
        
        let hairType = hairStyle.objectForKey("type")
        if hairType == nil {
            return ""
        }
        
        var begin = 0
        var j = 0
        var hairId : String = ""
        while j < hairType!.count {
            if let typeName = hairType?.objectAtIndex(j) {
                if let hairModelsLengthType = hairStyle.objectForKey(typeName){
                    var detailHairs = hairModelsLengthType as? [String]
                    if index < begin + detailHairs!.count {
                        hairId = detailHairs![index - begin]
                        break
                    }
                    begin += detailHairs!.count
                }
            }
            j += 1
            
        }
        return hairId
    }
    
    func tryonClothListViewControllerDidChooseCloth(vc: TryonClothListViewController, product: Clothes) {
        let cate = vc.category
        if cate == nil {
            return
        }
        putonNewClothes([product])
    }
}

extension FittingRoomViewController: DJModelViewDelegate{
    func modelView(modelView: DJModelView!, didClickProductDetail product: Clothes!) {
         pushClothDetailVC(product)
    }
    
    func modelView(modelView: DJModelView!, didClickTakeOff product: Clothes!) {
        takeoffCloth(product)
    }
}

extension FittingRoomViewController : OccasionFilterViewDelegate {
    func extractFilterIds(filterArray : [Filter]) -> [String]{
        var result = [String]()
        for filter in filterArray {
            result.append(filter.id)
        }
        return result
    }
    
    func filterBtnDidTapped() {
        if filterView == nil {
            let styleCondi = ConfigDataContainer.sharedInstance.getConfigStyleCategory()
            if styleCondi.count > 0{
                filterView = OccasionFilterView(frame: view.bounds)
                filterView!.delegate = self
                filterView!.hidden = true
            }
        }
        
        if filterView!.hidden {
            filterView?.showAnimation()
        }else{
            filterView?.hideAnimation()
        }
        
        if filterView == nil{
            return
        }
        
        if extractFilterIds(filterView!.selectedFilters) != extractFilterIds(selectedFilter){
            filterView?.resetSelectedFilters(selectedFilter)
        }
        view.addSubview(filterView!)
        
        DJStatisticsLogic.instance().addTraceLog(.FittingRoom_Click_Occasions)
    }
    
    func updateFilterBar(){
        if selectedFilter.count == 0 {
            filterScrollViewBar.hidden = true
            return
        }
        filterScrollViewBar.hidden = false
        
        filterScrollViewBar.removeAllSubViews()
        selectedFilterBtns = [DJButton]()
        
        let filterBtn = DJButton(frame: CGRectMake(0, 0, 33, 33))
        filterScrollViewBar.addSubview(filterBtn)
        filterBtn.addTarget(self, action: #selector(FittingRoomViewController.filterBtnDidTapped), forControlEvents: .TouchUpInside)
        filterBtn.setImage(UIImage(named: "FilterBlackIcon"), forState: .Normal)
        
        var oX : CGFloat = 50
        for item in selectedFilter {
            let filterBtn = DJButton()
            filterBtn.layer.cornerRadius = 15
            filterBtn.layer.borderColor = UIColor.blackColor().CGColor
            filterBtn.layer.borderWidth = 1
            filterBtn.property = item
            filterBtn.addTarget(self, action: #selector(FittingRoomViewController.selectedFilterBtnDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            selectedFilterBtns.append(filterBtn)
            filterScrollViewBar.addSubview(filterBtn)
            
            let label = UILabel()
            label.withText(item.name).withFontHeletica(14).withTextColor(UIColor.blackColor())
            filterBtn.addSubview(label)
            label.sizeToFit()
            label.frame = CGRectMake(15, 0, label.frame.size.width, 30)
            
            let imageView = UIImageView(frame: CGRectMake(CGRectGetMaxX(label.frame) + 8, 10, 10, 10))
            imageView.image = UIImage(named: "FilterCloseIcon")
            filterBtn.addSubview(imageView)
            
            filterBtn.frame = CGRectMake(oX, 0, CGRectGetMaxX(imageView.frame) + 15, 30)
            
            oX += filterBtn.frame.size.width + 10
            if selectedFilter.indexOf(item) == selectedFilter.count - 1{
                oX -= 10
            }
        }
        filterScrollViewBar.contentSize = CGSizeMake(oX, 30)
    }
    
    func selectedFilterBtnDidTap(btn : DJButton)
    {
        let filter = btn.property as? Filter
        if filter == nil{
            return
        }
        for item in selectedFilter{
            if item.id == filter?.id {
                selectedFilter.removeAtIndex(selectedFilter.indexOf(item)!)
                break
            }
        }
        
        if selectedFilter.count == 0{
            filterScrollViewBar.hidden = true
        }else{
            filterScrollViewBar.hidden = false
        }
        filterConditionChanged(selectedFilter)
    }
    
    func refineViewDone(refineView : OccasionFilterView) {
        filterView?.hideAnimation()
        //        DJStatisticsLogic.instance().addTraceLog(kStatisticsID_fitting_room_occasion_filter_done)
        if extractFilterIds(refineView.selectedFilters) != extractFilterIds(selectedFilter) {
            filterConditionChanged(refineView.selectedFilters)
        }
    }
    func filterConditionChanged(filters : [Filter]){
        selectedFilter = filters
        updateFilterBar()
        sendGetScoreNetTask()
        tryonCounter = 0
    }
}
