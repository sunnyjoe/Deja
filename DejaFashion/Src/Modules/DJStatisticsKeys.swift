//
//  DJStatisticsKeys.swift
//  DejaFashion
//
//  Created by DanyChen on 30/9/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

enum StatisticsKey : String {
    
    //done
    case Find_Click_Search
    case Find_Choose_Searchbox
    case Find_Choose_Brand
    case Find_Choose_Color
    case Find_Choose_Price
    case Find_Choose_Pur
    case Find_Click_Photo
    case Find_Click_Pricetag
    
    case Find_Click_Tutorial
    case Find_Click_Banner
    case Find_Click_Banner_Invite
    
    case Findresult_appear
    case Findresult_Click_Refine
    
    case Wardrobe_Click_Addbutton
    case Wardrobeadd_Click_Brands
    case Wardrobeadd_Click_Keywords
    case Wardrobeadd_Click_Photo
    case Wardrobeadd_Click_Pricetag
    case Wardrobe_Click_Account
    case Wardrobe_Click_Outfits
    case Wardrobe_Click_Edit
    case Wardrobe_Click_Item
    
    case Pricetag_Click_Album
    case Pricetag_Click_Shot
    case Pricetag_Click_Help
    
    
    case Pricetagmiddlepage_Click_Color
    
    case Brands_Click_onebrand
    case Brandspage_Click_Category

    case Photo_Click_Shot
    case Photo_Click_Album
    case Photo_Click_Template
    case Photo_Click_Help
    case Photo_Click_Pattern
    
    case Account_Click_FittingRoom
    case Account_Click_History
    case Account_Click_Favorites
    case Account_Click_Friends
    case Account_Click_Wardrobe
    case Account_Click_Nickname
    case Account_Click_Avatar
    case Account_Click_Setting//
    case Account_Click_ContactUs
    case Setting_Click_ContactUs
    
    case Explore_Click_Deals
    case Explore_Click_Favorites
    case Explore_Click_FittingRoom
    case Explore_Click_Inspiration
    case Explore_Click_Invite
    case Explore_Click_Nearby
    case Explore_Click_Events
    
    case Deals_Click_Refine
    case Deals_Click_Item
    
    //use Deals_Click_%@
    case Deals_Click
    case Deals_Click_Shop
    
    
    case FittingRoom_Click_Save
    case FittingRoom_Click_BodyAdjustment
    case FittingRoom_Click_Favourites
    case FittingRoom_Click_Tips
    case FittingRoom_Click_Occasions
    case FittingRoom_Click_Change
    case FittingRoom_Click_More
    case FittingRoom_Click_Makeup
    case FittingRoom_Click_Hairstyle
    
    case Mainframe_Click_FindClothes
    case Mainframe_Click_Wardrobe
    case Mainframe_Click_Explore
    //end
    
    case Nearby_List_Click_ShopYouMayLike
    case Nearby_List_Click_Shop
    case Nearby_List_Click_Mall
    case Nearby_List_Click_Search
    case Nearby_List_Click_Refresh
    case Nearby_List_Mall_Click_Map
    case Nearby_List_Mall_Click_Shop
    case Nearby_List_Shop_Click_Map
    case Nearby_List_Shop_Click_Navi
    case Nearby_List_Shop_Click_OH
    case Nearby_List_Shop_Click_Makephonecall
    case Nearby_List_Shop_Map_Click_Navi
    case Nearby_List_Mall_Map_Click_Navi
}


class DJStatisticsKeys: NSObject {
    static let H5_Click_Close = "H5_Click_Close";
    static let FittingRoom_Click_Model = "FittingRoom_Click_Model";
    static let FittingRoom_Click_TakeOff = "FittingRoom_Click_TakeOff";
    static let FittingRoom_Click_ViewDetails = "FittingRoom_Click_ViewDetails";
    
//    static let kStatisticsID_fitting_room_click_model = "fitting_room_click_model";
    static let system_click_allow_push = "system_click_allow_push";
    static let system_click_notification = "enter_app_by_click_notification";
    static let system_click_allow_location = "system_click_allow_location";
    static let system_new_launch = "system_new_launch";
    static let detail_click_share = "detail_click_share";
    static let Inspiration_Detail_Click_Share = "Inspiration_Detail_Click_Share";
    static let sharevia_click_FB = "sharevia_click_FB";
}

extension DJStatisticsLogic {
    func addTraceLog(key : StatisticsKey) {
        addTraceLog(key.rawValue)
    }
}
