//
//  StyleViewController.swift
//  DejaFashion
//
//  Created by DanyChen on 31/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

private var firstTimeIntoOutfit = true

class StyleViewController: DJWebViewController {
    
    override func viewDidLoad() {
        if sharedWebView == nil {
            firstTimeIntoOutfit = true
        }
        super.viewDidLoad()
//        DJStatisticsLogic.instance().addTraceLog(kStatisticsID_enter_outfit_page)
        title = DJStringUtil.localize("Outfits", comment:"")
        if firstTimeIntoOutfit {
            firstTimeIntoOutfit = false
        }else {
            if needRefreshOutfits {
                self.webView.reload()
            }
        }
        needRefreshOutfits = false
    }

}
