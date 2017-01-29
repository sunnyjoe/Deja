//
//  AddByPatternView.swift
//  DejaFashion
//
//  Created by jiao qing on 1/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class AddByPatternView: CameraView {
    var croppedImages = [UIImage]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let image = UIImage(named: "PatternTemplate"){
            if let cropImage = UIImage(named: "PatternCrop"){
                mask = image
                cropMask = cropImage
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


