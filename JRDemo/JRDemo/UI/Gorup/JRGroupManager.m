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
            if (![object.name isEqualToString:item.subject]) {
                object.name = item.subject;
                JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:@"群名称修改为 %@", item.subject]];
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
                    JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:@"群主修改为 %@", item.chairMan]];
                    [realm addObject:message];
                }
                object.chairMan = item.chairMan;
            }
            if (item.groupChatId.length) {
                object.chatId = item.groupChatId;
            }
            if (full) {
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
                            JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:@"%@ 离开群聊", name]];
                            [realm addObject:message];
                            [realm deleteObject:obj];
                        }
                    } else {
                        if (member.state == JRGroupPartpStatusExist) {
                            JRGroupMemberObject *memberObj = [[JRGroupMemberObject alloc] initWithGroupMember:member];
                            [realm addObject:memberObj];
                            NSString *name = memberObj.displayName.length ? memberObj.displayName : memberObj.number;
                            JRMessageObject *message = [[JRMessageObject alloc] initWithGroup:item notify:[NSString stringWithFormat:@"%@ 加入群聊", name]];
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
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRGroupObject *object = [JRGroupDBManager getGroupWithIdentity:sessIdentity];
        if (object) {
            // UI的提示暂时放这里，如有需求则自行通过notification去分发
            switch (operationType) {
                case JRGroupOperationTypeCreate:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:@"创建群聊成功"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"创建群聊失败"];
                    }
                    break;
                case JRGroupOperationTypeLeave:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:@"离开群聊成功"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"离开群聊失败"];
                    }
                    break;
                case JRGroupOperationTypeModifyGroupName:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:@"修改群名称成功"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"修改群名称失败"];
                    }
                    break;
                case JRGroupOperationTypeModifyNickName:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:@"修改群昵称成功"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"修改群昵称失败"];
                    }
                    break;
                case JRGroupOperationTypeDissolve:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:@"解散群聊成功"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"解散群聊失败"];
                    }
                    break;
                case JRGroupOperationTypeRejectInvite:
                    break;
                case JRGroupOperationTypeAcceptInvite:
                    break;
                case JRGroupOperationTypeInvite:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:@"邀请成员成功"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"邀请成员失败"];
                    }
                    break;
                case JRGroupOperationTypeKick:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:@"踢出成员成功"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"踢出成员失败"];
                    }
                    break;
                case JRGroupOperationTypeModifyChairman:
                    if (succeed) {
                        [SVProgressHUD showSuccessWithStatus:@"转让群主成功"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"转让群主失败"];
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
            for (JRGroupItem *item in groupList) {
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
                    object.chatId = item.groupChatId;
                    object.groupState = item.groupState;
                    if (item.groupType > EN_MTC_IM_SESS_GRP_TYPE_ALL) {
                        object.type = item.groupType;
                    }
                    [realm commitWriteTransaction];
                }
            }
        }
    }
}

@end
