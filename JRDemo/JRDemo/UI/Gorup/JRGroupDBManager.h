//
//  JRGroupDBManager.h
//  JRDemo
//
//  Created by Ginger on 2018/4/22.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRGroupObject.h"
#import "JRGroupMemberObject.h"

@interface JRGroupDBManager : NSObject

+ (JRGroupObject *)getGroupWithIdentity:(NSString *)identity;

+ (RLMResults<JRGroupMemberObject *> *)getGroupMemberWithIdentity:(NSString *)identity;

+ (JRGroupItem *)converGroupItem:(JRGroupObject *)group;

+ (JRGroupMemberObject *)getGroupMemberWithIdentity:(NSString *)identity number:(NSString *)number;

+ (RLMResults<JRGroupObject *> *)getGroupsWithState:(JRGroupStatus)state;

@end
