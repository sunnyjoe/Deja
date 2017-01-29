//
//  SearchResultEmptyView.swift
//  DejaFashion
//
//  Created by jiao qing on 22/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit


class SearchResultEmptyView : UIView {
    weak var controller : SearchClothesViewController?
    
    var recommendKeywords : [String]?
    
    init(frame: CGRect, keyword : String, recommendKeywords: [String]?) {
        super.init(frame: frame)
        let icon = UIImageView(frame: CGRect(x: frame.width / 2 - 50, y: 30, width: 100, height: 100))
        icon.image = UIImage(named: "NotFindImage")
        let label = UILabel(frame: CGRect(x: 23, y: icon.frame.maxY + 20, width: frame.width - 46, height: 0))
        label.withTextColor(DJCommonStyle.BackgroundColor)
        label.withFontHeletica(17)
        label.numberOfLines = 0
        if recommendKeywords?.count > 0 {
            label.text = DJStringUtil.localize("Sorry, we can't find anything about \(keyword). You may search:", comment: "")
        }else {
            label.text = DJStringUtil.localize("Sorry, we can't find anything about \(keyword).", comment: "")
        }
        label.setFont(DJFont.mediumHelveticaFontOfSize(17), string: keyword)
        label.sizeToFit()
        label.frame = CGRect(x: 23, y: icon.frame.maxY + 20, width: label.frame.width, height: label.frame.height)
        self.recommendKeywords = recommendKeywords
        
        addSubviews(icon, label)
        if let keywords = recommendKeywords {
            var x = 23 as CGFloat
            var y = label.frame.maxY + 16
            for (i,k) in keywords.enumerate() {
                let label = DJLabel(frame : CGRect(x: x, y: y, width: 0, height: 30))
                label.insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                label.withFontHeletica(17)
                label.withTextColor(DJCommonStyle.BackgroundColor)
                label.text = k
                label.sizeToFit()
                label.backgroundColor = UIColor(fromHexString: "eaeaea")
                if x + label.frame.width + 8 > frame.width - 46 {
                    x = 23
                    y += 30 + 8
                    break;// just keep it one line
                }else {
                    x += label.frame.width + 8
                }
                label.tag = i
                label.addTapGestureTarget(self, action: #selector(SearchResultEmptyView.tapKeyword(_:)))
                addSubview(label)
            }
        }
    }
    
    func tapKeyword(reg : UITapGestureRecognizer) {
        if let text = recommendKeywords?[reg.view!.tag] {
            controller?.searchBar.text = text
            controller?.searchKeyword()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





