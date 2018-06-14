//
//  JPhotoManger.m
//  JPhotoPicker
//
//  Created by Ginger on 2017/5/25.
//  Copyright © 2017年 Ginger. All rights reserved.
//

#import "JPhotoManger.h"

@implementation JPhotoManger

+ (JPhotoManger *)sharedInstance
{
    static JPhotoManger *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JPhotoManger alloc] init];
        [sharedInstance clearAll];
    });
    
    return sharedInstance;
}

- (ALAssetsLibrary *)assetsLibrary{
    
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    return _assetsLibrary;
}

- (NSMutableArray *)assets{
    if (!_assets) {
        _assets = [[NSMutableArray alloc] init];
    }
    
    return _assets;
}

- (void)clearAll
{
    self.indexPathsForSelectedItems = [[NSMutableArray alloc] init];
    self.minimumNumberOfSelection = 0;
    self.maximumNumberOfSelection = 9;
    self.selectionFilter = [NSPredicate predicateWithValue:YES];
}

- (void)laodAssetsWithCompleteBlock:(void (^)(bool succeed))block
{
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group,BOOL *stop){
        ALAssetsFilter *assetsFilter = [ALAssetsFilter allAssets];
        [group setAssetsFilter:assetsFilter];
        if (group.numberOfAssets) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [tempList addObject:result];
                }
            }];
        }
        NSArray* reversedArray = [[tempList reverseObjectEnumerator] allObjects];
        self.assets = [NSMutableArray arrayWithArray:reversedArray];
        if (block) {
            block(true);
        }
    };
    
    NSUInteger groupTypes = ALAssetsGroupAll;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:^(NSError *error) {
        //如果失败，可能因为授权问题
        NSLog(@"Not found any group!\n");
        if (block) {
            block(false);
        }
    }];
}

@end
