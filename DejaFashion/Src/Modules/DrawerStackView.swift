//
//  DrawerStackView.swift
//  DejaFashion
//
//  Created by DanyChen on 8/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

class DrawerView : UIView {
    
    static let ItemSize = CGSizeMake((ScreenWidth - horizontalMargin * 2) / 3, (ScreenWidth - horizontalMargin * 2) * 272 / 218 / 3 )
        
    let topAreaView = UIView()
    
    weak var panGestureRecognizer : UIPanGestureRecognizer?
    
    var longPressGesture: UILongPressGestureRecognizer?
    
    var scrollEnabled = false
    
    var sectionInset = UIEdgeInsetsZero
    
    let cardColorBackgroud = UIView(frame: CGRectMake(0, 10, ScreenWidth, topAreaHeight - 10))
    
    var editMode = false
    
    var items : [Clothes]?
    
    var name : String?
    
    func setDrawerStyle(style : DrawerStyle, index : Int) {
    }
    
    func showContent() {
    }
    
    func showLeftCountLabel() {
    }
    
    func hideContent() {
    }
    
    func refresh() {
    }
    
    func scrollContentToTop() {
    }
    
    func showRightCountLabel() {
    }
}

class DrawerStackView<T : DrawerView>: UIScrollView, UIScrollViewDelegate {
    
    var drawerStyle = DrawerStyle.Default {
        didSet {
            if oldValue == drawerStyle {
                return
            }
            
            if let count = drawers?.count {
                for index in 0..<count {
                    let drawer = drawers![index]
                    let convertedIndex = index >= drawerStyle.backgroundColors.count ? drawerStyle.backgroundColors.count - 1 : drawerStyle.backgroundColors.count - count + index
                    drawer.setDrawerStyle(drawerStyle, index: convertedIndex)
                }
            }
        }
    }
    
    private let gapWhenFolded = 9 as CGFloat
    private let needScaleWhenAnimated = true
    private var allDrawer : DrawerView?
    
    var cardHeight = ScreenHeight - 64

    var openedDrawerIndex : Int?
    
    override var frame: CGRect {
        didSet {
            cardHeight = frame.height
        }
    }

    var drawers : [T]? {
        didSet {
            removeAllSubViews()
            if drawers?.count > 0 {
                let count = drawers!.count
                for index in 0..<count {
                    let drawer = drawers![index]
                    drawer.frame = CGRect(origin: CGPoint(x: 0, y: Int(topAreaHeight) * index), size: CGSize(width: cardWidth, height:  cardHeight - gapWhenFolded * CGFloat(count)))
                    
                    drawer.tag = index
                    drawer.topAreaView.tag = index
                    drawer.topAreaView.userInteractionEnabled = true
                    drawer.topAreaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DrawerStackView.tapCard(_:))))
                    drawer.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawerStackView.panCard(_:)))
                    drawer.panGestureRecognizer?.enabled = false
                    drawer.scrollEnabled = false
                    let convertedIndex = index >= drawerStyle.backgroundColors.count ? drawerStyle.backgroundColors.count - 1 : drawerStyle.backgroundColors.count - count + index
                    drawer.setDrawerStyle(drawerStyle, index: convertedIndex)
                    addSubview(drawer)
                    if index == count - 1 {
                        allDrawer = drawer
                        originLastCardCenterY = drawer.center.y
                        allDrawer?.cardColorBackgroud.hidden = true
                        allDrawer?.showContent()
                        allDrawer?.panGestureRecognizer?.enabled = true
                        allDrawer?.sectionInset = UIEdgeInsetsMake(5, 23, 20, 23)
                    }
                }
                let totalHeightOfTitle = CGFloat(Int(topAreaHeight) * subviews.count)
                if totalHeightOfTitle > self.frame.height {
                    contentSize = CGSize(width: cardWidth, height: totalHeightOfTitle)
                }else {
                    contentSize = CGSize(width: cardWidth, height: self.frame.height)
                }
            }
        }
    }
    
    private var originLastCardCenterY : CGFloat = 0
    
    override init(frame: CGRect) {
        cardHeight = frame.height
        super.init(frame: frame)
        alwaysBounceHorizontal = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        delegate = self
    }
    
    func panCard(recognizer : UIPanGestureRecognizer) {
        if drawers?.count <= 1 {
            return
        }
        if let openIndex = openedDrawerIndex {
            if #available(iOS 9.0, *) {
                
            }else {
                return
            }
            if drawers![openIndex].editMode {
                return
            }
            if recognizer.state == .Ended || recognizer.state == .Cancelled || recognizer.state == .Failed{
                if recognizer.view?.frame.origin.y > CGFloat((subviews.count - 1) * Int(topAreaHeight) / 2) {
                    closeDrawer()
                }else {
                    openDrawer(openIndex)
                }
            }else {
                let point = recognizer.translationInView(superview)
                if recognizer.view!.center.y + point.y >= recognizer.view!.frame.height / 2 {
                    recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x)!, y: (recognizer.view?.center.y)! + point.y)
                }
                for i in 0..<self.subviews.count - 1 {
                    let card = self.subviews[i]
                    var offsetX = 0.0 as CGFloat
                    if needScaleWhenAnimated {
                        offsetX = (0.05 * point.y / CGFloat(i + 1))
                    }
                    card.frame = CGRectMake(card.frame.origin.x + offsetX, card.frame.origin.y - (0.05 * point.y / CGFloat(i + 1)), card.frame.width - offsetX * 2, card.frame.height)
                }
                recognizer.setTranslation(CGPointZero, inView: superview)
            }
            
        }else {
            if recognizer.state == .Ended || recognizer.state == .Cancelled || recognizer.state == .Failed{
                if contentOffset.y != 0 {
                    setContentOffset(CGPointZero, animated: true)
                }else {
                    if recognizer.view?.frame.origin.y > CGFloat((subviews.count - 1) * Int(topAreaHeight) / 2) {
                        closeDrawer()
                    }else {
                        openDrawer(allDrawer!.tag)
                    }
                }
            }else {
                let point = recognizer.translationInView(superview)
                var offsetY : CGFloat = 0
                if originLastCardCenterY <= recognizer.view?.center.y {
                    offsetY = contentOffset.y - point.y / 3
                }
                if offsetY < 0 {
                    contentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y - point.y / 3)
                    self.resetViewsWhenOffsetChanged(self)
                }else {
                    recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x)!, y: (recognizer.view?.center.y)! + point.y)
                    for i in 0..<self.subviews.count - 1 {
                        let card = self.subviews[i]
                        var offsetX = 0.0 as CGFloat
                        if needScaleWhenAnimated {
                            offsetX = (0.05 * point.y / CGFloat(i + 1))
                        }
                        card.frame = CGRectMake(card.frame.origin.x - offsetX, card.frame.origin.y - (0.05 * point.y / CGFloat(i + 1)), card.frame.width + offsetX * 2, card.frame.height)
                    }
                }
                recognizer.setTranslation(CGPointZero, inView: superview)
            }
        }
    }
    
    func tapCard(gesture : UITapGestureRecognizer) {
        if drawers?.count <= 1 {
            return
        }
        if openedDrawerIndex != nil {
            if let drawer = drawers?[openedDrawerIndex!] {
                if drawer.editMode {
//                    drawer.editMode = false
                    return
                }
            }
            closeDrawer()
        }else {
            let index = indexOfView(gesture.view!.superview!)
            openDrawer(index)
        }
    }
    
    func openDrawer(index : Int, animated : Bool = true) {
        if drawers?.count <= 1 {
            return
        }
        if let subview = self.subviews[index] as? DrawerView {
            if self.openedDrawerIndex == nil {
                subview.scrollEnabled = true
                subview.panGestureRecognizer?.enabled = true
                subview.showLeftCountLabel()
                subview.showContent()
            }
        }
        
        UIView.animateWithDuration(animated ? 0.3 : 0, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            let count = self.subviews.count
            for i in 0..<count {
                let card = self.subviews[i]
                let height = self.cardHeight - CGFloat(count - 1) * self.gapWhenFolded
                if !(card is DrawerView) {
                    return
                }
                if i == index {
                    card.frame = CGRectMake(0, self.contentOffset.y, cardWidth, height)
                }else {
                    var ii = i
                    if i > index {
                        ii -= 1
                    }
                    var offSetX = 0.0 as CGFloat
                    if self.needScaleWhenAnimated {
                        offSetX = CGFloat(6 - ii) * 2 - 1
                    }
                    card.frame = CGRectMake(offSetX, self.contentOffset.y + height + CGFloat(ii + 1) * self.gapWhenFolded
                        , cardWidth - offSetX * 2, height)
                    card.alpha = 0.4 + CGFloat(i) * 0.1
                }
            }
            }, completion: { (finished) -> Void in
                self.openedDrawerIndex = index
                self.scrollEnabled = false
                self.drawers?.forEach({ (drawer) -> () in
                    if drawer != self.drawers![index] {
                        drawer.topAreaView.alpha = 0.1
                    }
                })
                self.drawers?[index].longPressGesture?.enabled = true
        })
    }
    
    func closeDrawer() {
        if self.openedDrawerIndex != nil {
            for view in self.subviews {
                if let drawerView = view as? DrawerView {
                    drawerView.panGestureRecognizer?.enabled = false
                    drawerView.showRightCountLabel()
                    drawerView.editMode = false
                    drawerView.scrollEnabled = false
                    drawerView.topAreaView.alpha = 1.0
                    drawerView.alpha = 1.0
                    drawerView.longPressGesture?.enabled = false
                }
            }
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            for i in 0..<self.subviews.count {
                let card = self.subviews[i]
                let originY = (Int(topAreaHeight) * i)
                let height = self.cardHeight - CGFloat(self.subviews.count - 1) * self.gapWhenFolded
                if CGFloat(originY) <= self.contentOffset.y {
                    card.frame = CGRect(x : 0, y: self.contentOffset.y, width: cardWidth, height: height)
                }else {
                    card.frame = CGRect(origin: CGPoint(x: 0, y: originY), size: CGSize(width: cardWidth, height: height))
                }
            }
            }, completion: { (finished) -> Void in
                self.openedDrawerIndex = nil
                self.scrollEnabled = true
                for drawerView in self.drawers! {
                    if drawerView != self.allDrawer {
                        drawerView.hideContent()
                    }else {
                        drawerView.panGestureRecognizer?.enabled = true
                        drawerView.scrollContentToTop()
                    }
                    drawerView.alpha = 1.0
                }
                if WardrobeDataContainer.sharedInstance.clearNewAddedClothesIds() || WardrobeDataContainer.sharedInstance.clearNewStreetSnapClothesIds()  {
                    self.allDrawer?.refresh()
                }
        })
    }
    
    func indexOfView(card : UIView) -> Int {
        for i in 0..<self.subviews.count {
            let c = self.subviews[i]
            if card == c {
                return i
            }
        }
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        resetViewsWhenOffsetChanged(scrollView)
    }
    
    func resetViewsWhenOffsetChanged(scrollView: UIScrollView) {
        let height = cardHeight - CGFloat(self.subviews.count - 1) * self.gapWhenFolded
        if scrollView.contentOffset.y <= 0 {
            for i in 0 ..< scrollView.subviews.count {
                let view = scrollView.subviews[i]
                let offset = scrollView.contentOffset.y * CGFloat(i) / 4
                view.frame = CGRect(x : 0, y: -offset + topAreaHeight * CGFloat(i), width: cardWidth, height: height)
            }
        }else {
            for i in 0 ..< scrollView.subviews.count {
                let view = scrollView.subviews[i]
                let originY = (Int(topAreaHeight) * i)
                if CGFloat(originY) <= scrollView.contentOffset.y {
                    view.frame = CGRect(x : 0, y: scrollView.contentOffset.y, width: cardWidth, height: height)
                }
            }
        }
    }
}
