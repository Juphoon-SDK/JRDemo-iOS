//
//  JPhotoManger.h
//  JPhotoPicker
//
//  Created by Ginger on 2017/5/25.
//  Copyright © 2017年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface JPhotoManger : NSObject

//选择过滤
@property (nonatomic, strong) NSPredicate *selectionFilter;
//选中的项
@property (nonatomic, strong) NSMutableArray *indexPathsForSelectedItems;
//最多选择项
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;
//最少选择项
@property (nonatomic, assign) NSInteger minimumNumberOfSelection;

@property (nonatomic, strong) NSMutableArray *assets;
@property  (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

+ (JPhotoManger *)sharedInstance;
- (void)clearAll;
- (void)laodAssetsWithCompleteBlock:(void (^)(bool succeed))block;

@end
