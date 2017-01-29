//
//  FindByCategoryAndFilterNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

class FilterableNetTask : DJHTTPNetTask{
    var uid : String?
    var longitude : Double?
    var latitude : Double?
    var isNewArrival = false
    var bodyIssue : String?
    var keyWords : String?
    var occasion : String?
    var onSale = false
    var sortByRule : Int?
    
    var categoryID : String?
    var subcategoryID : String?
    
    var brandID : String?
    var filterIds : [String]?

    var mark : String?
    
    var pageIndex = 0
    var pageSize = 20

    var priceMin : Int?
    var priceMax : Int?
    
    var total = 0
    var fromBrandNumber : Int?
    var ended = false
    
    func buildFilterParams() -> [NSObject : AnyObject] {
        
        var dic = Dictionary<String , AnyObject>()
        
        if let subcategoryID = self.subcategoryID
        {
            dic["sub_category"] = subcategoryID;
        }
        
        if let categoryId = self.categoryID{
            dic["category"] = categoryId;
        }
        
        if self.filterIds?.count > 0
        {
            dic["filter_ids"] = self.filterIds?.joinWithSeparator(",")
        }
        
        if let tmp = self.brandID
        {
            dic["brand_id"] = tmp
        }
        
        if let tmp = priceMin
        {
            dic["price_min"] = tmp * 100
        }
        
        if let tmp = priceMax
        {
            dic["price_max"] = tmp * 100
        }
        dic["is_deal"] = self.onSale
        dic["page"] = self.pageIndex
        dic["page_size"] = self.pageSize
        
        if let tmp = uid{
            dic["uid"] = tmp
        }
        if let tmp = keyWords{
            dic["query"] = tmp
        }
        if let tmp = longitude{
            dic["longitude"] = tmp
        }
        if let tmp = latitude{
            dic["latitude"] = tmp
        }
        if let tmp = bodyIssue{
            dic["body_issue"] =  tmp
        }
        if let tmp = occasion{
            dic["occasion"] =  tmp
        }
        dic["is_new_arrival"] = isNewArrival
        
        if let tmp = keyWords{
            dic["query"] = tmp
        }
        if mark != nil
        {
            dic["mark"] = mark!
        }

        
        return dic
    }
    
    func extractFilterCondition(filterInfo : FilterableConditions){
        if let tmp = filterInfo.brand{
            self.brandID = tmp.id
        }
        
        self.priceMin = filterInfo.lowPrice
        self.priceMax = filterInfo.highPrice
        self.keyWords = filterInfo.keyWords
        self.categoryID = filterInfo.categoryId
        if let tmp = filterInfo.subCategory{
            self.subcategoryID = tmp.categoryId
        }
        
        self.onSale = filterInfo.onSale
        self.longitude = filterInfo.position?.longitude
        self.latitude = filterInfo.position?.latitude
        self.bodyIssue = filterInfo.bodyIssues
        self.occasion = filterInfo.occasion
        
        self.isNewArrival = filterInfo.isNewArrival
        self.filterIds = [String]()
        if let tmp = filterInfo.colorFilter{
            self.filterIds = [tmp.id]
        }
        if let tmp = filterInfo.filters{
            for one in tmp{
                self.filterIds!.append(one.id)
            }
        }
        
        if let tmp = filterInfo.keyWords{
            self.keyWords = tmp
        }
        
        self.mark = filterInfo.photoMark
        
    }

}

class FindClothesNetTask : FilterableNetTask
{
    var clothesList = [Clothes]()
    var sortBy : Int?
    
    func nextPage() -> FindClothesNetTask
    {
        pageIndex += 1
        return self
    }
    
    override func uri() -> String!
    {
        return "apis_bm/product/get_by_filter/v5"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskGet
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = buildFilterParams()
        if let tmp = sortBy {
            dic["sort_by_rule"] = tmp
        }
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSArray
        {
            self.clothesList = Clothes.parseClothesList(data)
        }else {
            self.clothesList = []
        }
        if let end = response["end"] as? Bool
        {
            self.ended = end
        }
        if let total = response["total"] as? Int
        {
            self.total = total
        }
        
        if let number = response["total_brand"] as? Int {
            fromBrandNumber = number
        }else{
            fromBrandNumber = nil
        }
        
    }
    
    override func didFail(error: NSError!)
    {
    }
}
