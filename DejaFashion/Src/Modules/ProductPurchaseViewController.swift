//
//  ProductPurchaseViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 1/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class ProductPurchaseViewController: DJWebViewController {

    override init!(URLString urlString: String!) {
        super.init(URLString: urlString)
        self.useSingleWebview = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
