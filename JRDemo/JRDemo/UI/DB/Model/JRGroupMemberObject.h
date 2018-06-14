//
//  JRGroupMemberObject.h
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Realm/Realm.h>

@interface JRGroupMemberObject : RLMObject

/**
 群identity
 */
@property NSString *groupIdentity;

/**
 号码
 */
@property NSString *number;

/**
 群昵称
 */
@property NSString *displayName;

/**
 成员状态
 */
@property JRGroupPartpStatus state;


- (instancetype)initWithGroupMember:(JRGroupMember *)member;

@end
