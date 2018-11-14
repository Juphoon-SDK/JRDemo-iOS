//
//  JRGroupManager.m
//  JRDemo
//
//  Created by Ginger on 2018/4/22.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupManager.h"
#import "JRGroupDBManager.h"
#import "JRMessageDBHelper.h"
#import "JRClientManager.h"
#import "JRNumberUtil.h"

@interface JRGroupManager () <JRGroupCallback>

@end

@implementation JRGroupManager

+ (JRGroupManager *)sharedInstance {
    static JRGroupManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JRGroupManager alloc] init];
        [JRGroup sharedInstance].delegate = instance;
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(regStateChanged:) name:kClientStateChangeNotification object:nil];
    });
    return instance;
}

- (void)regStateChanged:(NSNotification *)notification {
    JRClientState state = [(NSNumber *)[notification.userInfo objectForKey:kClientStateKey] intValue];
    // 订阅群列表
    if (state == JRClientStateLogined) {
        [self subscribeGroupList];
    }
}

#pragma mark - Public Function

- (BOOL)create:(NSString *)groupName numbers:(NSArray<NSString *> *)numbers {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    NSInteger ret = [[JRGroup sharedInstance] create:groupName numbers:numbers];
    return ret >= 0;
}

- (BOOL)leave:(JRGroupObject *)group {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] leave:[JRGroupDBManager converGroupItem:group]];
}

- (BOOL)modifyGroupName:(JRGroupObject *)group newName:(NSString *)name {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] modifyGroupName:[JRGroupDBManager converGroupItem:group] newName:name];
}

- (BOOL)modifyNickName:(JRGroupObject *)group newName:(NSString *)name {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] modifyNickName:[JRGroupDBManager converGroupItem:group] newName:name];
}

- (BOOL)dissolve:(JRGroupObject *)group {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] dissolve:[JRGroupDBManager converGroupItem:group]];
}

- (BOOL)rejectInvite:(JRGroupObject *)group {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] rejectInvite:[JRGroupDBManager converGroupItem:group]];
}

- (BOOL)acceptInvite:(JRGroupObject *)group {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] acceptInvite:[JRGroupDBManager converGroupItem:group]];
}

- (BOOL)invite:(JRGroupObject *)group newMembers:(NSArray<NSString *> *)members {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] invite:[JRGroupDBManager converGroupItem:group] newMembers:members];
}

- (BOOL)kick:(JRGroupObject *)group members:(NSArray<NSString *> *)members {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] kick:[JRGroupDBManager converGroupItem:group] members:members];
}

- (BOOL)modifyChairman:(JRGroupObject *)group newChairman:(NSString *)number {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] modifyChairman:[JRGroupDBManager converGroupItem:group] newChairman:number];
}

- (BOOL)subscribeGroupList {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] subscribeGroupList];
}

- (BOOL)subscribeGroupInfo:(NSString *)sessionIdentity {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRGroup sharedInstance] subscribeGroupInfo:sessionIdentity];
}

#pragma mark - JRGroupCallback

- (void)onGroupAdd:(JRGroupItem *)item {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRGroupObject *object = [JRGroupDBManager getGroupWithIdentity:item.sessIdentity];
        if (!object) {
            object = [[JRGroupObject alloc] initWithGroup:item];
            [realm beginWriteTransaction];
            [realm addObject:object];
            [realm commitWriteTransaction];
        } else {
            [realm beginWriteTransaction];
            object.name = item.subject;
            object.groupVersion = item.groupVersion;
            object.groupState = item.groupState;
            [realm commitWriteTransaction];
        }
    }
}

- (void)onGroupRemove:(JRGroupItem *)item {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRGroupObject *object = [JRGroupDBManager getGroupWithIdentity:item.sessIdentity];
        [realm beginWriteTransaction];
        [realm deleteObject:object];
        [realm deleteObjects:[JRGroupDBManager getGroupMemberWithIdentity:item.sessIdentity]];
        [realm commitWriteTransaction];
        [JRMessageDBHelper deleteConversationWithNumber:item.sessIdentity group:YES];
    }
}

- (void)onGroupUpdate:(JRGroupItem *)item full:(BOOL)full {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRGroupObject *object = [JRGroupDBManager getGroupWithIdentity:item.sessIdentity];
        if (object) {
            [realm beginWriteTransaction];
            if (![object.name isEqualToString:item.subject] && item.subject.length) {
                object.name = item.subject;
                JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:NSLocalizedString(@"GROUP_NAME_NOTIFY", nil), item.subject]];
                [realm addObject:message];
            }
            object.groupVersion = item.groupVersion;
            object.groupState = item.groupState;
            if (item.groupType > EN_MTC_IM_SESS_GRP_TYPE_ALL) {
                object.type = item.groupType;
            }
            if (item.chairMan.length && ![JRNumberUtil isNumberEqual:object.chairMan secondNumber:item.chairMan]) {
                // 增量情况下存在chairman为空的情况，即代表chairman没有变化
                if (object.chairMan.length) {
                    JRGroupMemberObject *chairMan = [JRGroupDBManager getGroupMemberWithIdentity:item.sessIdentity number:item.chairMan];
                    JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:NSLocalizedString(@"GROUP_CHAIRMAN_NOTIFY", nil), chairMan.displayName.length ? chairMan.displayName : chairMan.number]];
                    [realm addObject:message];
                }
                object.chairMan = item.chairMan;
            }
            if (item.groupChatId.length) {
                object.chatId = item.groupChatId;
            }
            if (full) {
                NSMutableArray<JRGroupMember *> *update = [[NSMutableArray alloc] init];
                NSMutableArray<JRGroupMemberObject *> *add = [[NSMutableArray alloc] init];
                NSMutableArray<JRGroupMemberObject *> *remove = [[NSMutableArray alloc] init];
                for (JRGroupMember *member in item.members) {
                    JRGroupMemberObject *object = [JRGroupDBManager getGroupMemberWithIdentity:item.sessIdentity number:member.number];
                    if (object) {
                        // 两边都存在,需要更新
                        [update addObject:member];
                    } else {
                        // 数据库中不存在,需要插入
                        object = [[JRGroupMemberObject alloc] initWithGroupMember:member];
                        [add addObject:object];
                    }
                }
                RLMResults<JRGroupMemberObject *> *dbMembers = [JRGroupDBManager getGroupMemberWithIdentity:item.sessIdentity];
                for (JRGroupMemberObject *member in dbMembers) {
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"number", member.number];
                    NSArray<JRGroupMember *> *exist = [update filteredArrayUsingPredicate:pred];
                    if (!exist.count) {
                        // 数据库中存在但是新列表里没有,需要删除
                        [remove addObject:member];
                    }
                }
                if (add.count) {
                    NSMutableString *addNotify = [[NSMutableString alloc] init];
                    for (JRGroupMemberObject *newMember in add) {
                        NSString *name = newMember.displayName.length ? newMember.displayName : newMember.number;
                        [addNotify appendString:name];
                        [addNotify appendString:@" "];
                    }
                    JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:NSLocalizedString(@"JOIN_GROUP_NOTIFY", nil), addNotify]];
                    [realm addObject:message];
                }
                if (remove.count) {
                    NSMutableString *removeNotify = [[NSMutableString alloc] init];
                    for (JRGroupMemberObject *removeMember in remove) {
                        NSString *name = removeMember.displayName.length ? removeMember.displayName : removeMember.number;
                        [removeNotify appendString:name];
                        [removeNotify appendString:@" "];
                    }
                    JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:NSLocalizedString(@"LEAVE_GROUP_NOTIFY", nil), removeNotify]];
                    [realm addObject:message];
                }
                // 成员直接全量替换,群列表订阅因为关系到会话和群成员所以需要对比更新
                [realm deleteObjects:[JRGroupDBManager getGroupMemberWithIdentity:item.sessIdentity]];
                for (JRGroupMember *member in item.members) {
                    JRGroupMemberObject *obj = [[JRGroupMemberObject alloc] initWithGroupMember:member];
                    [realm addObject:obj];
                }
            } else {
                for (JRGroupMember *member in item.members) {
                    JRGroupMemberObject *obj = [JRGroupDBManager getGroupMemberWithIdentity:item.sessIdentity number:member.number];
                    if (obj) {
                        if (member.displayName.length) {
                            // 在转让群主的时候出现平台下发的notify不带displayname，故在此做保护处理
                            obj.displayName = member.displayName;
                        }
                        obj.state = member.state;
                        if (member.state == JRGroupPartpStatusNotExist) {
                            NSString *name = obj.displayName.length ? obj.displayName : obj.number;
                            JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:NSLocalizedString(@"LEAVE_GROUP_NOTIFY", nil), name]];
                            [realm addObject:message];
                            [realm deleteObject:obj];
                        }
                    } else {
                        if (member.state == JRGroupPartpStatusExist) {
                            JRGroupMemberObject *memberObj = [[JRGroupMemberObject alloc] initWithGroupMember:member];
                            [realm addObject:memberObj];
                            NSString *name = memberObj.displayName.length ? memberObj.displayName : memberObj.number;
                            JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:NSLocalizedString(@"JOIN_GROUP_NOTIFY", nil), name]];
                            [realm addObject:message];
                        }
                    }
                }
            }
            [realm commitWriteTransaction];
        }
    }
}

- (void)onGroupOperationResult:(JRGroupOperationType)operationType succeed:(bool)succeed reason:(JRGroupReason)reason item:(NSString *)sessIdentity {
    if (operationType == JRGroupOperationTypeCreate) {
        if (succeed) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CREATE_GROUP_SUCC", nil)];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"CREATE_GROUP_FAIL", nil)];
        }
    }
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRGroupObject *object = [JRGroupDBManager getGroupWithIdentity:sessIdentity];
        if (object) {
            // UI的提示暂时放这里，如有需求则自行通过notification去分发
            switch (operationType) {
                case JRGroupOperationTypeCreate:
                    break;
                case JRGroupOperationTypeLeave:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"LEAVE_GROUP_SUCC", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LEAVE_GROUP_FAIL", nil)];
                    }
                    break;
                case JRGroupOperationTypeModifyGroupName:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MODIFY_GROUP_NAME_SUCC", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MODIFY_GROUP_NAME_FAIL", nil)];
                    }
                    break;
                case JRGroupOperationTypeModifyNickName:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MODIFY_GROUP_DISPLAYNAME_SUCC", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MODIFY_GROUP_DISPLAYNAME_FAIL", nil)];
                    }
                    break;
                case JRGroupOperationTypeDissolve:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"DISSOLVE_GROUP_SUCC", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"DISSOLVE_GROUP_FAIL", nil)];
                    }
                    break;
                case JRGroupOperationTypeRejectInvite:
                    break;
                case JRGroupOperationTypeAcceptInvite:
                    break;
                case JRGroupOperationTypeInvite:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"INVITE_NEW_MEMBER_SUCC", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"INVITE_NEW_MEMBER_FAIL", nil)];
                    }
                    break;
                case JRGroupOperationTypeKick:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"KICK_OUT_SUCC", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"KICK_OUT_FAIL", nil)];
                    }
                    break;
                case JRGroupOperationTypeModifyChairman:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"TRANSFER_CHAIRMAN_SUCC", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"TRANSFER_CHAIRMAN_FAIL", nil)];
                    }
                    break;
                case JRGroupOperationTypeSubscribeGroupList:
                    break;
                case JRGroupOperationTypeSubscribeGroupInfo:
                    break;
                case JRGroupOperationTypeAcceptSess:
                    break;
                case JRGroupOperationTypeUnknown:
                default:
                    break;
            }
        }
    }
}

- (void)onGroupListSubResult:(bool)succeed groupList:(NSArray<JRGroupItem *> *)groupList {
    if (!succeed) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SUB_GROUP_LIST_FAILED", nil)];
    } else {
        RLMRealm *realm = [JRRealmWrapper getRealmInstance];
        if (realm) {
            NSMutableArray<JRGroupItem *> *update = [[NSMutableArray alloc] init];
            NSMutableArray<JRGroupObject *> *add = [[NSMutableArray alloc] init];
            NSMutableArray<JRGroupObject *> *remove = [[NSMutableArray alloc] init];
            NSMutableArray<JRGroupMemberObject *> *members = [[NSMutableArray alloc] init];
            for (JRGroupItem *item in groupList) {
                JRGroupObject *object = [JRGroupDBManager getGroupWithIdentity:item.sessIdentity];
                if (object) {
                    // 两边都存在,需要更新
                    [update addObject:item];
                } else {
                    // 数据库中不存在,需要插入
                    object = [[JRGroupObject alloc] initWithGroup:item];
                    [add addObject:object];
                }
            }
            RLMResults<JRGroupObject *> *dbGroups = [JRGroupDBManager getGroupsWithState:JRGroupStatusStarted];
            for (JRGroupObject *group in dbGroups) {
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"sessIdentity", group.identity];
                NSArray<JRGroupItem *> *exist = [update filteredArrayUsingPredicate:pred];
                if (!exist.count) {
                    // 数据库中存在但是新列表里没有,需要删除
                    [remove addObject:group];
                    for (JRGroupMemberObject *member in [JRGroupDBManager getGroupMemberWithIdentity:group.identity]) {
                        [members addObject:member];
                    }
                    [JRMessageDBHelper deleteConversationWithNumber:group.identity group:YES];
                }
            }
            [realm beginWriteTransaction];
            if (add.count) {
                [realm addObjects:add];
            }
            if (remove.count) {
                [realm deleteObjects:remove];
            }
            if (members.count) {
                [realm deleteObjects:members];
            }
            for (JRGroupItem *item in update) {
                JRGroupObject *object = [JRGroupDBManager getGroupWithIdentity:item.sessIdentity];
                object.name = item.subject;
                object.groupVersion = item.groupVersion;
                object.groupState = item.groupState;
                object.chatId = item.groupChatId;
                object.groupState = item.groupState;
                if (item.groupType > JRGroupTypeAll) {
                    object.type = item.groupType;
                }
            }
            [realm commitWriteTransaction];
        }
    }
}

@end
