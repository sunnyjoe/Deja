//
//  AlphabetTableView.swift
//  DejaFashion
//
//  Created by jiao qing on 23/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol AlphabetTableViewDelegate: class {
    func alphabetTableViewDraggingDown()
}

class AlphabetTableView: UIView {
    private let contentTB = UITableView()
    private let indexView = UIView()
    
    private var content = [String]()
    private var alphbet = [String]()
    
    private weak var selectTarget : AnyObject?
    private var selectSelector : Selector?
    
    private var labelColor = UIColor.defaultBlack()
    private var alphbetColor = UIColor.gray81Color()
    private var cellColor = UIColor.whiteColor()
    private var blackStyle = false
    
    private var alphbetOY : CGFloat = 5
    private var alphbetHeight : CGFloat = 15
    
    private var preViewLabel = UILabel()
    
    weak var delegate : AlphabetTableViewDelegate?
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        addSubview(contentTB)
        addSubview(indexView)
        addSubview(preViewLabel)
        
        preViewLabel.withTextColor(UIColor.gray81Color()).withFontHeletica(20)
        
        contentTB.showsVerticalScrollIndicator = false
        contentTB.separatorStyle = .None
        contentTB.registerClass(SimpleLabelTableCell.self, forCellReuseIdentifier: "ContentTableCell")
        contentTB.delegate = self
        contentTB.dataSource = self
    }
    
    func setTheContent(strs : [String]){
        content = strs
        extractAlphabet()
        reloadData()
        contentTB.contentInset = UIEdgeInsetsMake(5, 0, 23, 0)
        contentTB.contentOffset = CGPointMake(0, -5)
    }
    
    func setContentSelector(target : AnyObject, sel : Selector){
        selectTarget = target
        selectSelector = sel
    }
    
    func reloadData(){
        contentTB.reloadData()
        
        indexView.removeAllSubViews()
        indexView.backgroundColor = cellColor
        
        let totalHeight = alphbetHeight * CGFloat(alphbet.count)
        alphbetOY = max(5, frame.size.height / 2 - totalHeight / 2)
        var oY = alphbetOY
        for one in alphbet{
            let label = UILabel(frame: CGRectMake(20, oY, 28, alphbetHeight))
            label.text = one
            label.withFontHeletica(11)
            label.textAlignment = .Center
            label.textColor = alphbetColor
            label.backgroundColor = UIColor.clearColor()
            indexView.addSubview(label)
            
            oY += alphbetHeight
        }
    }
    
    func setBlackColorStyle(){
        labelColor = UIColor(fromHexString: "eaeaea")
        alphbetColor = UIColor.whiteColor()
        cellColor = UIColor.defaultBlack()
        backgroundColor = cellColor
        contentTB.backgroundColor = cellColor
        indexView.backgroundColor = cellColor
        preViewLabel.textColor = UIColor(fromHexString: "f1f1f1")
        blackStyle = true
        reloadData()
    }
    
    func extractAlphabet(){
        content = content.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        
        alphbet.removeAll()
        for one in content{
            let chars = [Character](one.characters)
            if chars.count > 0{
                let str = String(chars[0])
                if alphbet.indexOf(str) == nil{
                    alphbet.append(str)
                }
            }
        }
//        if alphbet.count > 0 {
//            preViewLabel.text = alphbet[0]
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentTB.frame = CGRectMake(23, 0, frame.size.width - 23 * 2, frame.size.height)
        indexView.frame = CGRectMake(frame.size.width - 60, 0, 60, frame.size.height)
        reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AlphabetTableView: UITableViewDelegate, UITableViewDataSource{
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -80 {
            delegate?.alphabetTableViewDraggingDown()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return content.count
    }
    
    // Default is 1 if not implemented
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = SimpleLabelTableCell()
        if let tmp = tableView.dequeueReusableCellWithIdentifier("ContentTableCell"){
            cell = (tmp as! SimpleLabelTableCell)
            cell.label.text = content[indexPath.row]
            cell.setTheLableColor(labelColor)
            if blackStyle{
                cell.label.withFontHeletica(16)
            }else{
                cell.label.withFontHeleticaMedium(16)
            }
        }
        cell.backgroundColor = cellColor
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if selectTarget != nil && selectSelector != nil{
            if selectTarget!.respondsToSelector(selectSelector!){
                selectTarget!.performSelector(selectSelector!, withObject: content[indexPath.row])
            }
        }
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            let curCell = cell as! SimpleLabelTableCell
            curCell.didHighlighted(false)
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            let curCell = cell as! SimpleLabelTableCell
            curCell.didHighlighted(true)
        }
    }
    

}

extension AlphabetTableView{
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        findTouchedAlphbet(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        findTouchedAlphbet(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
         preViewLabel.text = nil
    }
    
    func findTouchedAlphbet(touches : Set<UITouch>){
        if contentTB.layer.animationKeys() != nil{
            return
        }
        
        if let touch = touches.first {
            let position : CGPoint = touch.locationInView(indexView)
            
            let index = Int((position.y - alphbetOY) / alphbetHeight)
            if index >= alphbet.count{
                preViewLabel.text = nil
                return
            }else if index < 0 {
                preViewLabel.text = nil
                return
            }
            
            let alpha = alphbet[index]
            preViewLabel.text = alpha
            var row = 0
            for one in content{
                let chars = [Character](one.characters)
                if chars.count > 0{
                    let str = String(chars[0])
                    if str == alpha{
                        break
                    }
                }
                row += 1
            }
            
            preViewLabel.frame = CGRectMake(frame.size.width - 23 - 50, position.y - 10, 20, 20)
            contentTB.scrollToRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0), atScrollPosition: .Top, animated: false)
        }
    }
    
}

class SimpleLabelTableCell : UITableViewCell {
    let label = UILabel()
    var labelColor = UIColor.defaultBlack()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        constrain(label) { label in
            label.centerY == label.superview!.centerY
            label.left == label.superview!.left
        }
        
        self.selectionStyle = .None
    }
    
    func setTheLableColor(color : UIColor){
        labelColor = color
        label.withTextColor(color)
    }
    
    func didHighlighted(highlighted : Bool){
        if  label.text == nil {
            return
        }
        let chars =  [Character](label.text!.characters)
        let range = NSRange(location: 0, length: chars.count)
        
        let finalAttribute = NSMutableAttributedString(string: label.text!)
        var anotherAttribute = [NSForegroundColorAttributeName: UIColor.defaultRed()]
        
        if (!highlighted) {
            anotherAttribute = [NSForegroundColorAttributeName: labelColor]
        }
        
        finalAttribute.addAttributes(anotherAttribute, range: range)
        label.attributedText = finalAttribute
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






