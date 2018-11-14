//
//  JRGroupDBManager.m
//  JRDemo
//
//  Created by Ginger on 2018/4/22.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupDBManager.h"
#import "JRNumberUtil.h"

@implementation JRGroupDBManager

+ (JRGroupObject *)getGroupWithIdentity:(NSString *)identity {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults<JRGroupObject *> *results = [JRGroupObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"identity", identity]];
        if (results.count == 1) {
            return results.firstObject;
        }
    }
    return nil;
}

+ (RLMResults<JRGroupMemberObject *> *)getGroupMemberWithIdentity:(NSString *)identity {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults<JRGroupMemberObject *> *results = [JRGroupMemberObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"groupIdentity", identity, @"state", [NSNumber numberWithInteger:JRGroupPartpStatusExist]]];
        return results;
    }
    return nil;
}

+ (JRGroupMemberObject *)getGroupMemberWithIdentity:(NSString *)identity number:(NSString *)number {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults<JRGroupMemberObject *> *results = [JRGroupMemberObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"groupIdentity", identity, @"number", [JRNumberUtil numberWithChineseCountryCode:number]]];
        if (results.count == 1) {
            return results.firstObject;
        }
    }
    return nil;
}

+ (JRGroupMemberObject *)getGroupMemberWithIdentity:(NSString *)identity displayName:(NSString *)displayName {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults<JRGroupMemberObject *> *results = [JRGroupMemberObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"groupIdentity", identity, @"displayName", displayName]];
        if (results.count == 1) {
            return results.firstObject;
        }
    }
    return nil;
}

+ (RLMResults<JRGroupObject *> *)getGroupsWithState:(JRGroupStatus)state {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults<JRGroupObject *> *results = [JRGroupObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"groupState", [NSNumber numberWithInteger:state]]];
        return results;
    }
    return nil;
}

+ (JRGroupItem *)converGroupItem:(JRGroupObject *)group {
    JRGroupItem *item = [[JRGroupItem alloc] init];
    item.sessIdentity = group.identity;
    item.groupChatId = group.chatId;
    item.subject = group.name;
    item.groupType = group.type;
    item.groupVersion = (int)group.groupVersion;
    item.groupState = group.groupState;
    return item;
}

@end
