//
//  DJConfigObject+Detail.h
//  DejaFashion
//
//  Created by Sun lin on 9/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJConfigObject.h"

@interface DJBrand : NSObject

@property (nonatomic, assign) NSInteger brandID;
@property (nonatomic, strong) NSString *brandName;
@end


@interface DJCategory : NSObject

@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, assign) NSInteger subCategoryID;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryIcon;
@property (nonatomic, strong) NSArray *subCategories;

@end

@interface DJBackgroundImage : NSObject

@property (nonatomic, assign) NSInteger imageID;
@property (nonatomic, strong) NSString *imageUrl;
@end


@interface DJColor : NSObject

@property (nonatomic, assign) NSInteger colorID;
@property (nonatomic, strong) NSString *colorName;
@property (nonatomic, strong) NSString *colorValue;

@end

@interface DJUpdateInfo : NSObject

@property (nonatomic, assign) BOOL force;
@property (nonatomic, strong) NSString *URL;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *versionNumber;

@end

@interface DJTemplate : NSObject

@property (nonatomic, assign) int id;
@property (nonatomic, strong) NSString *thumb;

@end

@interface DJPatchInfo : NSObject

@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *patchUrl;

@end



@interface DJScene : NSObject

@property (nonatomic, strong) NSNumber *sceneId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *imageUrlLong;

@end



@interface DJDejaDiscount : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL isOn;

@end

@interface DJConfigObject (Detail)

-(NSArray *)allBrands;
-(NSArray *)allCategroies;
-(NSArray *)subCategoryfiltersAtCategory:(NSInteger)categoryID; // <DJCategory Array>
-(NSArray *)subColorsfiltersAtCategory:(NSInteger)categoryID; // <DJColor Array>
-(NSArray *)subCategoriesAtCategory:(NSInteger)categoryID;
-(NSArray *)allBackgroundImages;
-(NSArray *)allColors;
-(NSArray *)allTemplates;
-(DJUpdateInfo *)updateInfo;
-(DJPatchInfo *)patchInfo;

-(NSArray<DJScene *> *)scenes;
-(NSNumber *)bestDealPrice;
-(DJDejaDiscount *)dejaDiscount;
-(NSNumber *)bannerInterval;
@end
