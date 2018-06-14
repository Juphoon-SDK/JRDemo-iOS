//
//  JRCallObject.h
//  JRDemo
//
//  Created by Ginger on 2018/4/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Realm/Realm.h>

@interface JRCallObject : RLMObject

/**
 对方号码，多方用逗号隔开
 */
@property NSString *number;

/**
 呼入还是呼出
 */
@property JRCallDirection direction;

/**
 通话类型
 */
@property JRCallType type;

/**
 通话的状态
 */
@property JRCallState state;

/**
 通话开始时间
 */
@property NSString *beginTime;

/**
 通话结束时间
 */
@property NSString *endTime;

/**
 通话接通时间
 */
@property NSString *talkingBeginTime;

/**
 通话记录是否已读
 */
@property BOOL read;

- (instancetype)initWithCall:(JRCallItem *)call;

@end
