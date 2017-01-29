//
//  DJConfigObject+Detail.m
//  DejaFashion
//
//  Created by Sun lin on 9/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJConfigObject+Detail.h"
#import <objc/runtime.h>

@implementation DJBrand
@end

@implementation DJCategory
@end

@implementation DJBackgroundImage
@end

@implementation DJColor

@end
@implementation DJUpdateInfo

@end

@implementation DJTemplate

@end

@implementation DJPatchInfo

@end

@implementation DJScene
@end

@implementation DJDejaDiscount

@end

@implementation DJConfigObject (Detail)

static char kDJBrandAssociatedID;
static char kDJCategoryAssociatedID;
static char kDJColorAssociatedID;
static char kDJBackgroundAssociatedID;
static char kDJUpdateInfoAssociatedID;
static char kDJPatchInfoAssociatedID;
static char kDJTemplateAssociatedID;
static char kDJDejaDiscountAssociatedID;

-(NSArray *)allBrands
{
    NSArray *allBrands = objc_getAssociatedObject(self, &kDJBrandAssociatedID);
    if(!allBrands)
    {
        NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
        allBrands = [self parseBrand:data];
        objc_setAssociatedObject(self, &kDJBrandAssociatedID, allBrands, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return allBrands;
}

-(NSArray *)parseBrand:(NSArray *)originalDate
{
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dict in originalDate) {
        DJBrand *brand = [DJBrand new];
        brand.brandID = [dict[@"id"] integerValue];
        brand.brandName = dict[@"name"];
        [result addObject:brand];
    }
    return result;
}


-(NSArray *)allCategroies
{
    NSArray *allCategories = objc_getAssociatedObject(self, &kDJCategoryAssociatedID);
    if(!allCategories)
    {
        NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
        allCategories = [self parseCategory:data];
        objc_setAssociatedObject(self, &kDJCategoryAssociatedID, allCategories, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return allCategories;
}

-(NSArray *)parseCategory:(NSArray *)originalDate
{
    NSMutableArray *categories = [NSMutableArray new];
    for (NSDictionary *dict in originalDate) {
        DJCategory *cate = [DJCategory new];
        cate.categoryID = [dict[@"id"] integerValue];
        cate.categoryName = dict[@"name"];
        cate.categoryIcon = dict[@"icon"];
        NSArray *subCategories = dict[@"sub_categories"];
        if(subCategories)
        {
            cate.subCategories = [self parseCategory:subCategories];
        }
        [categories addObject:cate];
    }
    return categories;
}

-(NSArray *)subCategoryfiltersAtCategory:(NSInteger)categoryID{
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
    NSArray *subCategories;
    
    for (NSDictionary *item in data) {
        NSInteger categoryId = [[item objectForKey:@"p_category_id"] integerValue];
        if (categoryId == categoryID) {
            subCategories = [item objectForKey:@"sub_categories"];
            break;
        }
    }
    
    return [self parseCategory:subCategories];
}

-(NSArray *)parseColors:(NSArray *)originalDate
{
    NSMutableArray *colorFilters = [NSMutableArray new];
    for (NSDictionary *dict in originalDate) {
        DJColor *color = [DJColor new];
        color.colorID = [dict[@"id"] integerValue];
        color.colorName = dict[@"name"];
        color.colorValue = dict[@"value"];
        
        [colorFilters addObject:color];
    }
    return colorFilters;
}

-(NSArray *)subColorsfiltersAtCategory:(NSInteger)categoryID{
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
    NSArray *subCategories;
    for (NSDictionary *item in data) {
        NSInteger categoryId = [[item objectForKey:@"p_category_id"] integerValue];
        if (categoryId == categoryID) {
            subCategories = [item objectForKey:@"sub_colors"];
            break;
        }
    }
    
    return [self parseColors:subCategories];
}


-(NSArray *)subCategoriesAtCategory:(NSInteger)categoryID
{
    NSArray *categories = [self allCategroies];
    for (DJCategory *category in categories)
    {
        if(category.categoryID == categoryID)
        {
            return category.subCategories;
        }
    }
    return nil;
}

-(NSArray *)allBackgroundImages
{
    NSArray *allUrls = objc_getAssociatedObject(self, &kDJBackgroundAssociatedID);
    if(!allUrls)
    {
        NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
        allUrls = [self parseBackgroundImage:data];
        objc_setAssociatedObject(self, &kDJCategoryAssociatedID, allUrls, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return allUrls;
}

-(NSArray *)parseBackgroundImage:(NSArray *)originalDate
{
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dict in originalDate) {
        DJBackgroundImage *img = [DJBackgroundImage new];
        img.imageID = [dict[@"id"] integerValue];
        img.imageUrl = dict[@"image_url"];
        [result addObject:img];
    }
    return result;
}

-(NSArray *)allColors
{
    NSArray *allColors = objc_getAssociatedObject(self, &kDJColorAssociatedID);
    if(!allColors)
    {
        NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
        allColors = [self parseColor:data];
        objc_setAssociatedObject(self, &kDJColorAssociatedID, allColors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return allColors;
}

-(NSArray *)parseColor:(NSArray *)originalDate
{
    NSMutableArray *colours = [NSMutableArray new];
    for (NSDictionary *dict in originalDate) {
        DJColor *color = [DJColor new];
        color.colorID = [dict[@"id"] integerValue];
        color.colorName = dict[@"name"];
        color.colorValue = dict[@"value"];
        [colours addObject:color];
    }
    return colours;
}

-(NSArray *)allTemplates
{
    NSArray *allTemplates = objc_getAssociatedObject(self, &kDJTemplateAssociatedID);
    if(!allTemplates)
    {
        NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
        allTemplates = [self parseTemplates:data];
        objc_setAssociatedObject(self, &kDJTemplateAssociatedID, allTemplates, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return allTemplates;
}

-(NSArray *)parseTemplates:(NSArray *)originalData
{
    NSMutableArray *templates = [NSMutableArray new];
    for (NSDictionary *dic in originalData) {
        DJTemplate *template = [DJTemplate new];
        template.id = [dic[@"id"] intValue];
        template.thumb = dic[@"thumb"];
        [templates addObject:template];
    }
    return templates;
}

-(DJUpdateInfo *)updateInfo
{
    DJUpdateInfo *updateInfo = objc_getAssociatedObject(self, &kDJUpdateInfoAssociatedID);
    if(!updateInfo)
    {
        NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
        updateInfo = [DJUpdateInfo new];
        updateInfo.force = [data[@"force"] integerValue];
        updateInfo.info = data[@"desc"];
        updateInfo.versionNumber = data[@"version"];
        updateInfo.URL= data[@"url"];
        objc_setAssociatedObject(self, &kDJUpdateInfoAssociatedID, updateInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return updateInfo;
    
}

-(DJPatchInfo *)patchInfo
{
    DJPatchInfo *patchInfo = objc_getAssociatedObject(self, &kDJPatchInfoAssociatedID);
    if(!patchInfo)
    {
        NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
        patchInfo = [DJPatchInfo new];
        patchInfo.appVersion = data[@"appVersion"];
        patchInfo.patchUrl = data[@"url"];
        objc_setAssociatedObject(self, &kDJPatchInfoAssociatedID, patchInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return patchInfo;
    
}

-(NSArray<DJScene *> *)scenes {
    NSMutableArray<DJScene *> *array = [NSMutableArray<DJScene *> new];
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
    for (NSDictionary *dic in data) {
        DJScene *scene = [DJScene new];
        scene.imageUrl = dic[@"image"];
        scene.sceneId = dic[@"id"];
        scene.name = dic[@"name"];
        scene.imageUrlLong = dic[@"i_image"];
        [array addObject:scene];
    }
    return array;
}

-(NSNumber *)bestDealPrice {
    NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
    return data[@"price"];
}

-(DJDejaDiscount *)dejaDiscount
{
    DJDejaDiscount *dejaDiscount = objc_getAssociatedObject(self, &kDJDejaDiscountAssociatedID);
    if(!dejaDiscount)
    {
        NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
        dejaDiscount = [DJDejaDiscount new];
        dejaDiscount.imageUrl = data[@"image"];
        dejaDiscount.isOn = ((NSNumber *)data[@"is_on"]).boolValue;
        objc_setAssociatedObject(self, &kDJDejaDiscountAssociatedID, dejaDiscount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dejaDiscount;
    
}

-(NSNumber *)bannerInterval {
    NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:self.originalData];
    return data[@"interval"];
}
@end

