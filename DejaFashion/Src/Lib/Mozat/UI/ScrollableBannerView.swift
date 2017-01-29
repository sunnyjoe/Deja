//
//  ScrollableBannerView.swift
//  DejaFashion
//
//  Created by jiao qing on 7/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol ScrollableBannerViewDelegate : NSObjectProtocol{
    func scrollableBannerView(bannerView : ScrollableBannerView, didTapImage : UIImage)
    func scrollableBannerViewStartScroll(bannerView : ScrollableBannerView)
    
}

class ScrollableBannerView: UIView, UIScrollViewDelegate {
    private var scrollView = UIScrollView()
    private var imageUrls : [String]?
    private var pageControl = UIPageControl()
    weak var delegate : ScrollableBannerViewDelegate?
    
    var timer : NSTimer?
    var pageWidth : CGFloat = 100
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        addSubview(scrollView)
        
        pageControl.addTarget(self, action: #selector(didClickDot(_:)), forControlEvents: .ValueChanged)
        addSubview(pageControl)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        pageControl.frame = CGRectMake(0, frame.size.height - 30, frame.size.width, 30)
        scrollView.frame = bounds
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, frame.size.height)
    }
    
    func didClickDot(sender : UIPageControl){
        let page = CGFloat(sender.currentPage)
        scrollView.scrollRectToVisible(CGRectMake(page * frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: true)
    }
    
    
    func startTimer(){
        timer?.invalidate()
        timer = nil
        let interval = NSTimeInterval(ConfigDataContainer.sharedInstance.getScrollBannerInterval())
        unowned let weakSelf = self
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: weakSelf, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    deinit{
        stopTimer()
    }
    
    func stopTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    func scrollToNextPage(){
        let totalPage = scrollView.contentSize.width / max(pageWidth, 1)
        let cur = pageControl.currentPage
        if cur == Int(totalPage) - 1{
            scrollView.setContentOffset(CGPointZero, animated: true)
        }else{
            scrollView.setContentOffset(CGPointMake(CGFloat(cur + 1) * pageWidth, 0), animated: true)
        }
    }
    
    
    func setScrollViews(views : [UIView]){
        setScrollViews(views, spacing: 5);
        pageControl.hidden = true
        scrollView.pagingEnabled = false
    }
    
    func setScrollViewFull(views : [UIView]){
        setScrollViews(views, spacing: 0);
        pageControl.hidden = false
        scrollView.pagingEnabled = true
    }
    
    func setScrollViews(views : [UIView], spacing : CGFloat){
        pageControl.numberOfPages = views.count
        
        scrollView.removeAllSubViews()
        if views.count == 0 {
            return
        }
        
        var oX : CGFloat = 0
        var lastView : UIView?
        for one in views{
            one.frame = CGRectMake(oX, 0, one.frame.size.width, one.frame.size.height)
            scrollView.addSubview(one)
            oX += one.frame.size.width + spacing
            
            lastView = one
        }
        pageWidth = lastView!.frame.size.width + spacing
        scrollView.showsHorizontalScrollIndicator = false
        if spacing > 0 {
            scrollView.contentInset = UIEdgeInsetsMake(0, 23, 0, 23)
        }else{
            scrollView.contentInset = UIEdgeInsetsZero
        }
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView!.frame), lastView!.frame.size.height)
    }
    
    func setScrollImages(imageUrls : [String], fill : Bool = true){
        scrollView.removeAllSubViews()
        self.imageUrls = imageUrls
        
        var oX : CGFloat = 0
        for one in imageUrls{
            let imageV = UIImageView(frame: CGRectMake(oX, 0, frame.size.width, frame.size.height))
            imageV.addTapGestureTarget(self, action: #selector(imageViewDidTapped(_:)))
            
            if let url = NSURL(string: one){
                imageV.sd_setImageWithURL(url)
            }
            imageV.contentMode = .ScaleAspectFill
            if !fill {
                imageV.contentMode = .ScaleAspectFit
            }
            scrollView.addSubview(imageV)
            oX += imageV.frame.size.width
        }
        pageWidth = frame.size.width
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentSize = CGSizeMake(frame.size.width * CGFloat(imageUrls.count), frame.size.height)
        
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = 0
        
        if imageUrls.count <= 1{
            pageControl.hidden = true
        }else{
            pageControl.hidden = false
        }
    }
    
    func imageViewDidTapped(gest : UITapGestureRecognizer){
        if let iv = gest.view {
            if let tmp = iv as? UIImageView{
                if let image = tmp.image{
                    self.delegate?.scrollableBannerView(self, didTapImage: image)
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(scrollView : UIScrollView)
    {
        startTimer()
        self.delegate?.scrollableBannerViewStartScroll(self)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.frame.size.width <= 0 {
            return
        }
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
