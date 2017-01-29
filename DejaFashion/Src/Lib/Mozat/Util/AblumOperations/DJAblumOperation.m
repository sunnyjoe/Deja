//
//  DJAblumOperation.m
//  DejaFashion
//
//  Created by jiao qing on 8/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "DJAblumOperation.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@implementation DJAblumOperation

+ (void)choosePicture:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)delegate {
    
    ALAssetsLibrary *assetLibrary = [ALAssetsLibrary new];
    
    __weak UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> *weakSelf = delegate;
    __block UIImagePickerController *imagePicker = nil;
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (!imagePicker) {
            imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = weakSelf;
            
            [weakSelf.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
    } failureBlock:^(NSError *error) {}];
}

+ (void)getAlbumPoster:(void (^)(UIImage *))completion {
    ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
    NSMutableArray *imageGroup = [NSMutableArray new];
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSString *errorMessage = @"";
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        if (completion) {
            completion(nil);
        }
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [imageGroup insertObject:group atIndex:0];
            CGImageRef posterImageRef = [group posterImage];
            UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
            if (completion) {
                completion(posterImage);
            }
        }
    };
    
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

+ (void)saveImageToAlbum:(UIImage *)image{
    ALAssetsLibrary* libraryFolder = [[ALAssetsLibrary alloc] init];
    __weak ALAssetsLibrary *lib = libraryFolder;
    
    [libraryFolder addAssetsGroupAlbumWithName:@"Deja" resultBlock:^(ALAssetsGroup *group) {
        ///checks if group previously created
        if(group == nil){
            [lib enumerateGroupsWithTypes:ALAssetsGroupAlbum
                               usingBlock:^(ALAssetsGroup *g, BOOL *stop){
                 if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Deja"]) {
                     //save image
                     [self saveImageToAssetsLibrary:lib group:g image:image];
                 }
             }failureBlock:nil];
            
        }else{
            // save image directly to library
            [self saveImageToAssetsLibrary:lib group:group image:image];
        }
        
    } failureBlock:nil];
}

+(void)saveImageToAssetsLibrary:(ALAssetsLibrary *)lib group:(ALAssetsGroup *)group image:(UIImage *)image{
    [lib writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(image) metadata:nil
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              [lib assetForURL:assetURL
                                   resultBlock:^(ALAsset *asset) {
                                       [group addAsset:asset];
                                   } failureBlock:nil];
                          }];
}
@end
