//
//  JRChatViewController.h
//  JRDemo
//
//  Created by Ginger on 2018/2/6.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRConversationObject.h"
#import "JRGroupObject.h"

@interface JRChatViewController : UIViewController

/**
 根据号码初始化

 @param number 对方号码
 @return 实例
 */
- (instancetype)initWithPhone:(NSString *)number;

/**
 根据群组初始化

 @param group 群组
 @return 实例
 */
- (instancetype)initWithGroup:(JRGroupObject *)group;

@end
