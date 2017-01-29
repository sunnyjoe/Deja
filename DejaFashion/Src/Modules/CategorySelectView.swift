//
//  CategorySelectView.swift
//  DejaFashion
//
//  Created by jiao qing on 26/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


@objc protocol CategorySelectViewDelegate : NSObjectProtocol{
    func categorySelectViewDidSelectSubCategory(categorySelectView : CategorySelectView, subCategory : ClothSubCategory?)
    optional func categorySelectViewDidClickExtraHeader(categorySelectView : CategorySelectView)
}

class CategorySelectView: UIView {
    private var configCates = [ClothCategory]()
    private let tableView = SLExpandableTableView()
    
    private var arrowIVs = [UIImageView]()
    private var rowViews = [UIView?]()
    private var downBoarders = [UIView]()
    private var subCateViews = [String : [UIView]]()
    private var selectedSubCate : ClothSubCategory?
    
    private var itemWidth : CGFloat = 1
    private var itemHeight : CGFloat = 1
    
    weak var delegate : CategorySelectViewDelegate?
    private var extraHeaderInfo : String?
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.contentOffset = CGPointZero
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.headerHeight = 50
        tableView.showsVerticalScrollIndicator = false
        tableView.bottomPadding = 64
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "BrandCategoriesViewControllerCell")
        addSubview(tableView)
        
    }
    
    func headerDidTapped(gesture : UITapGestureRecognizer){
        guard let theView = gesture.view else{
            return
        }
        
        guard let headerIndex = theView.property as? Int else{
            return
        }
       
        tableView.didClickHeaderView(headerIndex)
    }
    
    func createTitleLabel(name : String) -> UILabel{
        let label = UILabel(frame : CGRectMake(23, 0, frame.size.width - 23 * 2, 50))
        label.withText(name).withFontHeleticaMedium(16).withTextColor(UIColor.defaultBlack())
        return label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemWidth = (frame.size.width - 23 * 2) / 5
        itemHeight = itemWidth + 33 + 3
        tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
    }
    
    func resetData(cates : [ClothCategory], extraHeader : String? = nil){
        configCates = cates
        
        let number = configCates.count
        rowViews = [UIView?](count: number, repeatedValue: nil)
        arrowIVs = [UIImageView](count: number, repeatedValue: UIImageView())
        downBoarders = [UIView](count: number, repeatedValue: UIView())
        
        extraHeaderInfo = extraHeader
        if extraHeaderInfo != nil {
            buildTableHeaderView(extraHeaderInfo!)
        }else{
            tableView.tableHeaderView = nil
        }
        
        tableView.reloadData()
    }
    
    func subCategoryDidSelected(subCategory : ClothSubCategory?){
        delegate?.categorySelectViewDidSelectSubCategory(self, subCategory: subCategory)
    }
    
    func createRowView(section : Int) -> UIView{
        let height = tableView.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: section))
        let conv = UIView(frame : CGRectMake(23, 0, frame.size.width - 23 * 2, height))
        
        let cate = configCates[section]
        subCateViews[cate.categoryId] = [UIView]()
        
        for (i, subcate) in cate.subCategories.enumerate() {
            let item = UIView(frame: CGRectMake(CGFloat(i % 5) * itemWidth, CGFloat(i / 5) * itemHeight , itemWidth, itemHeight))
            
            let iconUrl = subcate.iconURL
            let name = subcate.name
            let imageViewContainer = UIView(frame: CGRectMake(0, 0, itemWidth, itemWidth))
            imageViewContainer.layer.borderWidth = 0.5
            imageViewContainer.layer.borderColor = DJCommonStyle.DividerColor.CGColor
            
            subCateViews[cate.categoryId]!.append(imageViewContainer)
            
            let padding = 8 as CGFloat
            let imageView = UIImageView(frame: CGRectMake(padding, padding, itemWidth - padding * 2, itemWidth - padding * 2))
            imageViewContainer.addSubview(imageView)
            imageView.sd_setImageWithURL(NSURL(string: iconUrl!)!)
            
            let label = UILabel(frame: CGRectMake(0, itemWidth, itemWidth, 33))
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.withFontHeletica(13).withTextColor(UIColor.defaultBlack()).withText(name).textCentered()
            item.addSubviews(imageViewContainer, label)
            
            conv.addSubview(item)
            imageViewContainer.property = subcate
            imageViewContainer.addTapGestureTarget(self, action: #selector(subCategoryDidTapped(_:)))
            
            if subcate.categoryId == selectedSubCate?.categoryId {
                imageViewContainer.layer.borderColor = UIColor.defaultRed().CGColor
            }
        }
        
        return conv
    }
    
    func setSelectedCatagory(cate : ClothSubCategory){
        selectedSubCate = cate
        self.tableView.reloadData()
        
        for (_, views) in subCateViews{
            for oneView in views{
                oneView.layer.borderColor = DJCommonStyle.DividerColor.CGColor
            }
        }
        
        if let cateId = cate.superCategoryid {
            if let subCateTheViews = subCateViews[cateId]{
                
                for oneView in subCateTheViews{
                    guard let subCategory = oneView.property as? ClothSubCategory else{
                        continue
                    }
                    if subCategory.categoryId == cate.categoryId{
                        oneView.layer.borderColor = DJCommonStyle.DividerColor.CGColor
                    }
                }
                
            }
        }
    }
    
    func subCategoryDidTapped(gesture : UITapGestureRecognizer){
        guard let theView = gesture.view else{
            return
        }
        guard let subCategory = theView.property as? ClothSubCategory else{
            return
        }
        
        if selectedSubCate != nil && subCategory.categoryId == selectedSubCate!.categoryId{
            selectedSubCate = nil
            theView.layer.borderColor = DJCommonStyle.DividerColor.CGColor
            subCategoryDidSelected(nil)
        }else{
            selectedSubCate = subCategory
            theView.layer.borderColor = UIColor.defaultRed().CGColor
            subCategoryDidSelected(subCategory)
        }
        
        self.tableView.reloadData()
        
        for (_, views) in subCateViews{
            for oneView in views{
                if oneView != theView{
                    oneView.layer.borderColor = DJCommonStyle.DividerColor.CGColor
                }
            }
        }
    }
    
    func tableHeaderDidTapped(){
        if delegate == nil {
            return
        }
        if delegate!.respondsToSelector(#selector(CategorySelectViewDelegate.categorySelectViewDidClickExtraHeader(_:))) {
            delegate!.categorySelectViewDidClickExtraHeader!(self)
        }
    }
    
    func buildTableHeaderView(text : String) {
        let conV = UIView(frame : CGRectMake(0, 0, tableView.frame.size.width, 50))
        let narLabel = createTitleLabel(text)
        conV.addSubview(narLabel)
        conV.addBorder()
        
        conV.addTapGestureTarget(self, action: #selector(tableHeaderDidTapped))
        tableView.tableHeaderView = conV
    }
}


extension CategorySelectView : UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cate = configCates[indexPath.section]
        let subC = CGFloat(cate.subCategories.count)
        
        return ceil(subC / 5) * itemHeight + 20
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let conV = UIView(frame: CGRectMake(0, 0, frame.size.width, 50))
        conV.backgroundColor = UIColor.whiteColor()
        
        let narLabel = createTitleLabel("")
        conV.addSubview(narLabel)
        narLabel.property = section
        narLabel.addTapGestureTarget(self, action: #selector(headerDidTapped(_:)))
        narLabel.withTextColor(UIColor.defaultBlack())
        
        let cate = configCates[section]
        narLabel.withText(cate.name)
        
        if selectedSubCate != nil && cate.categoryId == selectedSubCate!.superCategoryid{
            narLabel.withText("\(cate.name): \(selectedSubCate!.name)")
        }
        
        let border = UIView(frame : CGRectMake(0, CGRectGetMaxY(narLabel.frame) - 0.5, conV.frame.size.width, 0.5))
        border.backgroundColor = DJCommonStyle.ColorCE
        conV.addSubview(border)
        downBoarders[section] = border
        
        let arrow = UIImageView(frame : CGRectMake(conV.frame.size.width - 23 - 22 / 1.7, conV.frame.size.height / 2 - 19 / (2 * 1.7), 22 / 1.7, 19 / 1.7))
        conV.addSubview(arrow)
        if self.tableView.isSectionExpanded(section){
            arrow.image = UIImage(named: "FilterArrowUp")
            downBoarders[section].hidden = true
        }else{
            arrow.image = UIImage(named: "FilterArrowDown")
            downBoarders[section].hidden = false
        }
        arrowIVs[section] = arrow
        
        return conV
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return configCates.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrandCategoriesViewControllerCell", forIndexPath: indexPath)
        cell.removeAllSubViews()
        cell.selectionStyle = .None
        
        var cateview = rowViews[indexPath.section]
        if cateview == nil {
            cateview = createRowView(indexPath.section)
            rowViews[indexPath.section] = cateview
        }
        cell.addSubview(cateview!)
        cell.addBorder()
        return cell
    }
}


