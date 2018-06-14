//
//  JRGroupObject.h
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Realm/Realm.h>

@interface JRGroupObject : RLMObject

/**
 群名称
 */
@property NSString *name;

/**
 群identity
 */
@property NSString *identity;

/**
 群chatId
 */
@property NSString *chatId;

/**
 群版本号
 */
@property NSInteger groupVersion;

/**
 群类型
 */
@property JRGroupType type;

/**
 群状态
 */
@property JRGroupStatus groupState;

/**
 群主号码
 */
@property NSString *chairMan;

- (instancetype)initWithGroup:(JRGroupItem *)group;

@end
