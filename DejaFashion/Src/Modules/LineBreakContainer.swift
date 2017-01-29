//
//  LineBreakContainer.swift
//  DejaFashion
//
//  Created by DanyChen on 15/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class LineBreakContainer: UIView {
    
    var lineWidth : CGFloat = 0.0
    var lineHeight : CGFloat = 0.0
    var itemSpacing : CGFloat = 0.0
    var lineSpacing : CGFloat = 0.0
    
    private var currentX : CGFloat = 0.0
    private var currentY : CGFloat = 0.0
    
    var contentSize : CGSize {
        get {
            return CGSize(width: lineWidth, height: currentY + lineHeight)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func addSubview(subView: UIView, viewWidth : CGFloat) {
        
        if currentX > 0 {
            if currentX + viewWidth + itemSpacing > lineWidth {
                currentX = 0.0
                currentY = currentY + lineHeight + lineSpacing
            }else {
                currentX = currentX + itemSpacing
            }
        }
        subView.frame = CGRect(x: currentX, y: currentY, width: viewWidth, height: lineHeight)
        currentX = subView.frame.maxX
        currentY = subView.frame.minY
        
        addSubview(subView)
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
