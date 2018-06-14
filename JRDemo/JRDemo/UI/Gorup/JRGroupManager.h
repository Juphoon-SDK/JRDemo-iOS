//
//  JRGroupManager.h
//  JRDemo
//
//  Created by Ginger on 2018/4/22.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRGroupObject.h"

@interface JRGroupManager : NSObject

+ (JRGroupManager *)sharedInstance;

- (BOOL)create:(NSString *)groupName numbers:(NSArray<NSString *> *)numbers;
- (BOOL)leave:(JRGroupObject *)group;
- (BOOL)modifyGroupName:(JRGroupObject *)group newName:(NSString *)name;
- (BOOL)modifyNickName:(JRGroupObject *)group newName:(NSString *)name;
- (BOOL)dissolve:(JRGroupObject *)group;
- (BOOL)rejectInvite:(JRGroupObject *)group;
- (BOOL)acceptInvite:(JRGroupObject *)group;
- (BOOL)invite:(JRGroupObject *)group newMembers:(NSArray<NSString *> *)members;
- (BOOL)kick:(JRGroupObject *)group members:(NSArray<NSString *> *)members;
- (BOOL)modifyChairman:(JRGroupObject *)group newChairman:(NSString *)number;
- (BOOL)subscribeGroupList;
- (BOOL)subscribeGroupInfo:(NSString *)sessionIdentity;

@end
