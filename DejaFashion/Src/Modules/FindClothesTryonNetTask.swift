//
//  FindClothesTryonNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 31/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

class FindClothesTryonNetTask: FindClothesNetTask {
    override func uri() -> String!
    {
        return "apis_bm/product/get_by_filter_tryon/v4"
    }

}
