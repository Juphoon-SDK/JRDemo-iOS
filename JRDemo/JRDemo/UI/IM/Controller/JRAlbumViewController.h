//
//  JRAlbumViewController.h
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JRAlbumViewControllerDelegate <NSObject>
@optional

/**
 视频或图片选完

 @param dataArray 媒体数据列表
 @param video 是否是视频
 */
- (void)fileSelected:(NSArray<NSData *> *)dataArray isVideo:(BOOL)video;

@end

@interface JRAlbumViewController : UIViewController

/**
 代理
 */
@property (nonatomic, weak) id<JRAlbumViewControllerDelegate> delegate;

@end
