//
//  JREditViewController.h
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JREditViewController;

typedef NS_ENUM(NSInteger, EditType) {
    EditTypeDisplayName,
    EditTypeGroupName,
};

@protocol JREditViewControllerDelegate <NSObject>

@optional

- (void)editComplete:(JREditViewController *)viewController content:(NSString *)content;
- (void)cancelComplete:(JREditViewController *)viewController;

@end

@interface JREditViewController : UIViewController

@property (nonatomic, copy) NSString *defaultContent;
@property (nonatomic, copy) NSString *tip;
@property (nonatomic, assign) EditType type;
@property (nonatomic, weak) id<JREditViewControllerDelegate> delegate;

+ (void)presentWithNavigationController:(void (^)(JREditViewController *viewController))configBlock presentingViewController:(UIViewController *)viewController;

@end
