//
//  ClothDetailViewController.swift
//  DejaFashion
//
//  Created by Sun lin on 17/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

//let from_add_cloth_by_search = "search";
//let from_add_cloth_by_camera = "camera";
//let from_add_cloth_by_pattern = "pattern";
//let from_add_cloth_by_brand = "brand";
//let from_add_cloth_by_Scan_Tag = "scan_tag";

class ClothDetailViewController: DJWebViewController {
    
//    var fromFunction = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
         title = DJStringUtil.localize("Details", comment:"")
    }
    
    override func handleUserTraceLog(eventId: String!)
    {
//        if eventId != ""
//        {
//            return;
//        }
//
//        if fromFunction == from_add_cloth_by_search
//        {
//            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_add_cloth_by_search_done)
//        }
//        if fromFunction == from_add_cloth_by_camera
//        {
//            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_add_cloth_by_camera_done)
//        }
//        
//        if fromFunction == from_add_cloth_by_brand
//        {
//            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_add_cloth_by_brand_done)
//        }
//        
//        if fromFunction == from_add_cloth_by_pattern
//        {
//            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_add_cloth_by_pattern_done)
//        }
//        
//        if fromFunction == from_add_cloth_by_Scan_Tag
//        {
//            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_add_cloth_by_scan_done)
//        }
    }
}
