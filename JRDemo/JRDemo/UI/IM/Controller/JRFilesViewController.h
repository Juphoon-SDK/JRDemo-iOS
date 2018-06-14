//
//  JRFilesViewController.h
//  JRDemo
//
//  Created by Ginger on 2018/2/27.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JRFilesViewControllerDelegate <NSObject>
@optional

/**
 点击了发送按钮

 @param filePath 相对路径
 */
- (void)fileSelected:(NSString *)filePath;

@end

@interface JRFilesViewController : UITableViewController

/**
 代理
 */
@property (nonatomic, weak) id<JRFilesViewControllerDelegate> delegate;

@end
