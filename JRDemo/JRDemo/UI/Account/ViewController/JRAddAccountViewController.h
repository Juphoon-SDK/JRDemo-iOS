//
//  JRAddAccountViewController.h
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JRAddAccountViewController;

@protocol JRAddAccountViewControllerDelegate <NSObject>

@optional

- (void)addAccountFinish:(JRAddAccountViewController *)addAccountViewController account:(NSString *)account;

- (void)addAccountCancel:(JRAddAccountViewController *)addAccountViewController;

@end

@interface JRAddAccountViewController : UITableViewController

+ (void)presentWithNavigationController:(void (^)(JRAddAccountViewController *addAccountViewController))configBlock presentingViewController:(UIViewController *)viewController;

@property (nonatomic, weak) id<JRAddAccountViewControllerDelegate> accountDelegate;

@end
