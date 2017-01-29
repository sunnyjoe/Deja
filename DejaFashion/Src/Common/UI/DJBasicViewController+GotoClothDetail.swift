//
//  DJBasicViewController+GotoClothDetail.swift
//  DejaFashion
//
//  Created by jiao qing on 13/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

extension DJBasicViewController {
    func pushClothDetailVC(cloth: Clothes? ) {
        if cloth == nil {
            return
        }
        HistoryDataContainer.sharedInstance.addClothesToHistory(cloth!)
        let url = ConfigDataContainer.sharedInstance.getClothDetailUrl(cloth!.uniqueID!)
        let v = ClothDetailViewController(URLString: url)
        
        navigationController?.pushViewController(v, animated: true)
    }

}
