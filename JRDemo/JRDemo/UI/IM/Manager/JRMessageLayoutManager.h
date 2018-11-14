//
//  JRMessageLayoutManager.h
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRMessageObject.h"
#import "JRTextLayout.h"
#import "JRThumbImageLayout.h"
#import "JRLocationLayout.h"
#import "JRAudioLayout.h"
#import "JRVCardLayout.h"
#import "JROtherFileLayout.h"
#import "JRGroupNotifyLayout.h"
#import "JRRevokeLayout.h"
#import "JRExVCardLayout.h"

@interface JRMessageLayoutManager : NSObject

/**
 用于存放layout
 */
@property (nonatomic, strong) NSMutableDictionary *layoutDic;

+ (JRMessageLayoutManager *)shareInstance;

/**
 创建layout

 @param message 消息对象
 @param showTime 是否显示时间
 */
- (void)creatLayoutWithMessage:(JRMessageObject *)message showTime:(BOOL)showTime;

@end
