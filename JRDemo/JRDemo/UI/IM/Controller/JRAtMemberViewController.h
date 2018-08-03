//
//  JRAtMemberViewController.h
//  JRDemo
//
//  Created by Ginger on 2018/7/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRGroupMemberObject.h"
#import "JRGroupObject.h"

@class JRAtMemberViewController;

@protocol JRAtMemberViewControllerDelegate <NSObject>

@optional

- (void)atAllMembers:(JRAtMemberViewController *)ViewController;

- (void)atGroupMembers:(NSArray<JRGroupMemberObject *> *)members viewController:(JRAtMemberViewController *)ViewController;

@end

@interface JRAtMemberViewController : UITableViewController

@property (nonatomic, weak) id<JRAtMemberViewControllerDelegate> atDelegate;
@property (nonatomic, strong) JRGroupObject *group;

+ (void)presentWithNavigationController:(void (^)(JRAtMemberViewController *atViewController))configBlock group:(JRGroupObject *)group presentingViewController:(UIViewController *)viewController;

@end
