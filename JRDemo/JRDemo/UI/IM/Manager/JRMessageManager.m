//
//  JRMessageManager.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRMessageManager.h"
#import "JRMessageDBHelper.h"
#import "JRNumberUtil.h"
#import "JRGroupDBManager.h"
#import "JRClientManager.h"

@implementation JRMessageManager

+ (JRMessageManager *)shareInstance {
    static JRMessageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JRMessageManager alloc] init];
        [JRMessage sharedInstance].delegate = instance;
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(regStateChanged:) name:kClientStateChangeNotification object:nil];
    });
    return instance;
}

- (void)regStateChanged:(NSNotification *)notification {
    JRClientState state = [(NSNumber *)[notification.userInfo objectForKey:kClientStateKey] intValue];
    if (state == JRClientStateLogined) {
        // 重置消息状态
        [JRMessageDBHelper resetAllTransferingMessage];
        // 删除群组提示消息
        [JRMessageDBHelper deleteAllNotifyMessage];
    }
}

#pragma mark - Send

- (BOOL)sendTextMessage:(NSString *)message number:(NSString *)number contentType:(JRTextMessageContentType)contentType convId:(NSString *)convId {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    if ([JRNumberUtil isNumberEqual:number secondNumber:[JRClient sharedInstance].currentNumber]) {
        return NO;
    }
    JRTextMessageItem *item;
    NSArray<NSString *> *numbers = [number componentsSeparatedByString:@","];
    if (numbers.count == 1) {
        NSString *formatNumber = [JRNumberUtil numberWithChineseCountryCode:numbers.firstObject];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:formatNumber forKey:PEER_NUMBER];
        [dic setObject:[NSNumber numberWithInt:contentType] forKey:TEXT_CONTENT_TYPE];
        if (convId.length) {
            [dic setObject:convId forKey:CONVERSATION_ID];
        }
        item = [[JRMessage sharedInstance] sendTextMessage:message chatType:JRMessageChannelType1On1 extraParams:dic];
    } else if (numbers.count > 1) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:numbers.count];
        for (NSString *number in numbers) {
            [array addObject:[JRNumberUtil numberWithChineseCountryCode:number]];
        }
        item = [[JRMessage sharedInstance] sendTextMessage:message chatType:JRMessageChannelTypeList extraParams:array];
    }
    if (item) {
        // 成功则插入
        JRMessageObject *obj = [[JRMessageObject alloc] initWithTextMessage:item];
        RLMRealm *realm = [JRRealmWrapper getRealmInstance];
        if (realm) {
            JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:obj.peerNumber group:NO];
            if (!conversation) {
                conversation = [[JRConversationObject alloc] init];
                conversation.peerNumber = obj.peerNumber;
            }
            [realm beginWriteTransaction];
            conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
            [realm addObject:obj];
            [realm addOrUpdateObject:conversation];
            [realm commitWriteTransaction];
            return YES;
        }
    }
    return NO;
}

- (BOOL)sendTextMessage:(NSString *)message group:(JRGroupObject *)group members:(NSArray<JRGroupMemberObject *> *)atMembers atAll:(BOOL)atAll {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{GROUP_CHAT_ID:group.chatId, SESSION_IDENTITY:group.identity, SUBJECT:group.name, GROUP_VERSION:[NSNumber numberWithInteger:group.groupVersion], GROUP_TYPE:[NSNumber numberWithInteger:group.type]}];
    if (atAll) {
        [dic setObject:@1 forKey:AT_ALL_NUMBERS];
    } else if (atMembers.count) {
        [dic setObject:@0 forKey:AT_ALL_NUMBERS];
        NSMutableArray<NSString *> *members = [NSMutableArray arrayWithCapacity:atMembers.count];
        for (JRGroupMemberObject *member in atMembers) {
            [members addObject:member.number];
        }
        [dic setObject:members forKey:AT_NUMBERS];
    }
    JRTextMessageItem *item = [[JRMessage sharedInstance] sendTextMessage:message chatType:JRMessageChannelTypeGroup extraParams:dic];
    if (item) {
        // 成功则插入
        JRMessageObject *obj = [[JRMessageObject alloc] initWithTextMessage:item];
        RLMRealm *realm = [JRRealmWrapper getRealmInstance];
        if (realm) {
            JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:group.identity group:YES];
            if (!conversation) {
                conversation = [[JRConversationObject alloc] init];
                conversation.peerNumber = group.identity;
                conversation.isGroup = YES;
            }
            [realm beginWriteTransaction];
            conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
            [realm addObject:obj];
            [realm addOrUpdateObject:conversation];
            [realm commitWriteTransaction];
            return YES;
        }
    }
    return NO;
}

- (BOOL)sendFile:(NSString *)path thumbPath:(NSString *)thumbPath type:(NSString *)type number:(NSString *)number {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    if ([JRNumberUtil isNumberEqual:number secondNumber:[JRClient sharedInstance].currentNumber]) {
        return NO;
    }
    
    JRFileMessageItem *item;
    NSArray<NSString *> *numbers = [number componentsSeparatedByString:@","];
    if (numbers.count == 1) {
        NSString *formatNumber = [JRNumberUtil numberWithChineseCountryCode:number];
        item = [[JRMessage sharedInstance] sendFileMessage:[JRFileUtil getAbsolutePathWithFileRelativePath:path] thumbPath:[JRFileUtil getAbsolutePathWithFileRelativePath:thumbPath] fileType:type chatType:JRMessageChannelType1On1 extraParams:formatNumber];
    } else if (numbers.count > 1) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:numbers.count];
        for (NSString *number in numbers) {
            [array addObject:[JRNumberUtil numberWithChineseCountryCode:number]];
        }
        item = [[JRMessage sharedInstance] sendFileMessage:[JRFileUtil getAbsolutePathWithFileRelativePath:path] thumbPath:[JRFileUtil getAbsolutePathWithFileRelativePath:thumbPath] fileType:type chatType:JRMessageChannelTypeList extraParams:array];
    }
    if (item) {
        JRMessageObject *obj = [[JRMessageObject alloc] initWithFileMessage:item];
        RLMRealm *realm = [JRRealmWrapper getRealmInstance];
        if (realm) {
            JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:obj.peerNumber group:NO];
            if (!conversation) {
                conversation = [[JRConversationObject alloc] init];
                conversation.peerNumber = obj.peerNumber;
            }
            [realm beginWriteTransaction];
            conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
            [realm addObject:obj];
            [realm addOrUpdateObject:conversation];
            [realm commitWriteTransaction];
            return YES;
        }
    }
    return NO;
}

- (BOOL)sendFile:(NSString *)path thumbPath:(NSString *)thumbPath type:(NSString *)type group:(JRGroupObject *)group {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    JRFileMessageItem *item = [[JRMessage sharedInstance] sendFileMessage:[JRFileUtil getAbsolutePathWithFileRelativePath:path] thumbPath:[JRFileUtil getAbsolutePathWithFileRelativePath:thumbPath] fileType:type chatType:JRMessageChannelTypeGroup extraParams:@{GROUP_CHAT_ID:group.chatId, SESSION_IDENTITY:group.identity, SUBJECT:group.name, GROUP_VERSION:[NSNumber numberWithInteger:group.groupVersion], GROUP_TYPE:[NSNumber numberWithInteger:group.type]}];
    if (item) {
        JRMessageObject *obj = [[JRMessageObject alloc] initWithFileMessage:item];
        RLMRealm *realm = [JRRealmWrapper getRealmInstance];
        if (realm) {
            JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:group.identity group:YES];
            if (!conversation) {
                conversation = [[JRConversationObject alloc] init];
                conversation.peerNumber = group.identity;
                conversation.isGroup = YES;
            }
            [realm beginWriteTransaction];
            conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
            [realm addObject:obj];
            [realm addOrUpdateObject:conversation];
            [realm commitWriteTransaction];
            return YES;
        }
    }
    return NO;
}

- (BOOL)sendGeo:(NSString *)geoLabel latitude:(double)latitude longitude:(double)longitude radius:(float)radius number:(NSString *)number {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    if ([JRNumberUtil isNumberEqual:number secondNumber:[JRClient sharedInstance].currentNumber]) {
        return NO;
    }
    
    JRGeoMessageItem *item;
    NSArray<NSString *> *numbers = [number componentsSeparatedByString:@","];
    if (numbers.count == 1) {
        NSString *formatNumber = [JRNumberUtil numberWithChineseCountryCode:number];
        item = [[JRMessage sharedInstance] sendGeoMessage:geoLabel latitude:latitude longitude:longitude radius:radius chatType:JRMessageChannelType1On1 extraParams:formatNumber];
    } else if (numbers.count > 1) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:numbers.count];
        for (NSString *number in numbers) {
            [array addObject:[JRNumberUtil numberWithChineseCountryCode:number]];
        }
        item = [[JRMessage sharedInstance] sendGeoMessage:geoLabel latitude:latitude longitude:longitude radius:radius chatType:JRMessageChannelTypeList extraParams:array];
    }

    if (item) {
        JRMessageObject *obj = [[JRMessageObject alloc] initWithGeoMessage:item];
        RLMRealm *realm = [JRRealmWrapper getRealmInstance];
        if (realm) {
            JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:obj.peerNumber group:NO];
            if (!conversation) {
                conversation = [[JRConversationObject alloc] init];
                conversation.peerNumber = obj.peerNumber;
            }
            [realm beginWriteTransaction];
            conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
            [realm addObject:obj];
            [realm addOrUpdateObject:conversation];
            [realm commitWriteTransaction];
            return YES;
        }
    }
    return NO;
}

- (BOOL)sendGeo:(NSString *)geoLabel latitude:(double)latitude longitude:(double)longitude radius:(float)radius group:(JRGroupObject *)group {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    JRGeoMessageItem *item = [[JRMessage sharedInstance] sendGeoMessage:geoLabel latitude:latitude longitude:longitude radius:radius chatType:JRMessageChannelTypeGroup extraParams:@{GROUP_CHAT_ID:group.chatId, SESSION_IDENTITY:group.identity, SUBJECT:group.name, GROUP_VERSION:[NSNumber numberWithInteger:group.groupVersion], GROUP_TYPE:[NSNumber numberWithInteger:group.type]}];
    if (item) {
        JRMessageObject *obj = [[JRMessageObject alloc] initWithGeoMessage:item];
        RLMRealm *realm = [JRRealmWrapper getRealmInstance];
        if (realm) {
            JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:group.identity group:YES];
            if (!conversation) {
                conversation = [[JRConversationObject alloc] init];
                conversation.peerNumber = group.identity;
                conversation.isGroup = YES;
            }
            [realm beginWriteTransaction];
            conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
            [realm addObject:obj];
            [realm addOrUpdateObject:conversation];
            [realm commitWriteTransaction];
            return YES;
        }
    }
    return NO;
}

- (BOOL)transferFile:(JRFileMessageItem *)message {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRMessage sharedInstance] transferFileMessage:message];
}

- (BOOL)fetchGeo:(JRGeoMessageItem *)message {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    return [[JRMessage sharedInstance] fetchGeoMessage:message];
}

- (BOOL)resendMessage:(JRMessageObject *)message {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    if (message.direction == JRMessageItemDirectionReceive) {
        return NO;
    }
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    switch (message.type) {
        case JRMessageItemTypeText: {
            BOOL ret;
            if (message.groupChatId) {
                ret = [self sendTextMessage:message.content group:[JRGroupDBManager getGroupWithIdentity:message.peerNumber] members:nil atAll:NO];
            } else {
                ret = [self sendTextMessage:message.content number:message.receiverNumber contentType:message.contentType convId:nil];
            }
            if (ret) {
                if (realm) {
                    [realm beginWriteTransaction];
                    [realm deleteObject:message];
                    [realm commitWriteTransaction];
                }
            }
            return ret;
        }
        case JRMessageItemTypeGeo: {
            BOOL ret;
            if (message.groupChatId) {
                ret = [self sendGeo:message.geoFreeText latitude:[message.geoLatitude floatValue] longitude:[message.geoLongitude floatValue] radius:[message.geoRadius floatValue]group:[JRGroupDBManager getGroupWithIdentity:message.peerNumber]];
            } else {
                ret = [self sendGeo:message.geoFreeText latitude:[message.geoLatitude floatValue] longitude:[message.geoLongitude floatValue] radius:[message.geoRadius floatValue] number:message.receiverNumber];
            }
            if (ret) {
                if (realm) {
                    [realm beginWriteTransaction];
                    [realm deleteObject:message];
                    [realm commitWriteTransaction];
                }
            }
            return ret;
        }
        case JRMessageItemTypeAudio:
        case JRMessageItemTypeImage:
        case JRMessageItemTypeVideo:
        case JRMessageItemTypeVcard:
        case JRMessageItemTypeOtherFile: {
            if (message.fileTransSize > 0 && message.transId.length) {
                return [self transferFile:[JRMessageDBHelper converFileMessage:message]];
            } else {
                if ([self sendFile:message.filePath thumbPath:message.fileThumbPath type:message.fileType number:message.receiverNumber]) {
                    if (realm) {
                        [realm beginWriteTransaction];
                        [realm deleteObject:message];
                        [realm commitWriteTransaction];
                    }
                    return YES;
                }
                return NO;
            }
        }
        default:
            return NO;
    }
}

- (BOOL)sendCommand:(JRMessageObject *)message command:(JRMessageCommandType)command group:(JRGroupObject *)group {
    if ([JRClient sharedInstance].state != JRClientStateLogined) {
        return NO;
    }
    NSObject *extra = nil;
    if (group) {
        extra = @{GROUP_CHAT_ID:group.chatId, SESSION_IDENTITY:group.identity, SUBJECT:group.name, GROUP_VERSION:[NSNumber numberWithInteger:group.groupVersion], GROUP_TYPE:[NSNumber numberWithInteger:group.type]};
    }
    if (message.type == JRMessageItemTypeText) {
        JRTextMessageItem *text = [JRMessageDBHelper converTextMessage:message];
        return [[JRMessage sharedInstance] sendCommand:text command:command extraParams:extra];
    } else if (message.type == JRMessageItemTypeGeo) {
        JRGeoMessageItem *geo = [JRMessageDBHelper converGeoMessage:message];
        return [[JRMessage sharedInstance] sendCommand:geo command:command extraParams:extra];
    } else {
        JRFileMessageItem *file = [JRMessageDBHelper converFileMessage:message];
        return [[JRMessage sharedInstance] sendCommand:file command:command extraParams:extra];
    }
}

#pragma mark - Receive

- (void)onTextMessageReceived:(JRTextMessageItem *)item {
    // 发送回执
    if (item.imdnType == JRMessageItemImdnTypeBoth || item.imdnType == JRMessageItemImdnTypeDeli) {
        [[JRMessage sharedInstance] sendCommand:item command:JRMessageCommandTypeDelivered extraParams:nil];
    }
    JRMessageObject *message = [JRMessageDBHelper getMessageWithImdnId:item.messageImdnId];
    if (message) {
        // 已存在该消息
        return;
    }
    JRMessageObject *obj = [[JRMessageObject alloc] initWithTextMessage:item];
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        NSString *formatNumber;
        if (item.sessIdentity.length) {
            formatNumber = item.sessIdentity;
            obj.isRead = [obj.peerNumber isEqualToString:self.currentNumber];
        } else {
            formatNumber = [JRNumberUtil numberWithChineseCountryCode:obj.peerNumber];
            obj.isRead = [JRNumberUtil isNumberEqual:obj.peerNumber secondNumber:self.currentNumber];
        }
        if (obj.isRead) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[JRMessageManager shareInstance] sendCommand:obj command:JRMessageCommandTypeRead group:nil];
            });
        }
        
        JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:formatNumber group:item.sessIdentity.length];
        if (!conversation) {
            conversation = [[JRConversationObject alloc] init];
            conversation.peerNumber = formatNumber;
            conversation.isGroup = item.sessIdentity.length;
        }
        [realm beginWriteTransaction];
        conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
        [realm addOrUpdateObject:obj];
        [realm addOrUpdateObject:conversation];
        [realm commitWriteTransaction];
    }
}

- (void)onTextMessageUpdate:(JRTextMessageItem *)item {
    JRMessageObject *message = [JRMessageDBHelper getMessageWithImdnId:item.messageImdnId];
    if (!message || message.state == JRMessageItemStateRevoked) {
        // 消息不存在
        return;
    }
    JRMessageObject *obj = [[JRMessageObject alloc] initWithTextMessage:item];
    obj.isRead = message.isRead;
    obj.peerNumber = message.peerNumber;
    obj.groupChatId = message.groupChatId;
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
}

- (void)onGeoMessageReceived:(JRGeoMessageItem *)item {
    // 发送回执
    if (item.imdnType == JRMessageItemImdnTypeBoth || item.imdnType == JRMessageItemImdnTypeDeli) {
        [[JRMessage sharedInstance] sendCommand:item command:JRMessageCommandTypeDelivered extraParams:nil];
    }
    JRMessageObject *message = [JRMessageDBHelper getMessageWithTransferId:item.geoTransId];
    if (message) {
        // 已存在该消息
        return;
    }
    JRMessageObject *obj = [[JRMessageObject alloc] initWithGeoMessage:item];
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        NSString *formatNumber;
        if (item.sessIdentity.length) {
            formatNumber = item.sessIdentity;
            obj.isRead = [obj.peerNumber isEqualToString:self.currentNumber];
        } else {
            formatNumber = [JRNumberUtil numberWithChineseCountryCode:obj.peerNumber];
            obj.isRead = [JRNumberUtil isNumberEqual:obj.peerNumber secondNumber:self.currentNumber];
        }
        if (obj.isRead) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[JRMessageManager shareInstance] sendCommand:obj command:JRMessageCommandTypeRead group:nil];
            });
        }
        JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:formatNumber group:item.sessIdentity.length];
        if (!conversation) {
            conversation = [[JRConversationObject alloc] init];
            conversation.peerNumber = formatNumber;
            conversation.isGroup = item.sessIdentity.length;
        }
        [realm beginWriteTransaction];
        conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
        [realm addOrUpdateObject:obj];
        [realm addOrUpdateObject:conversation];
        [realm commitWriteTransaction];
    }
    // 地理位置消息自动接收
    [[JRMessage sharedInstance] fetchGeoMessage:item];
}

- (void)onGeoMessageUpdate:(JRGeoMessageItem *)item {
    JRMessageObject *message = [JRMessageDBHelper getMessageWithTransferId:item.geoTransId];
    if (!message || message.state == JRMessageItemStateRevoked) {
        // 消息不存在
        return;
    }
    JRMessageObject *obj = [[JRMessageObject alloc] initWithGeoMessage:item];
    obj.isRead = message.isRead;
    obj.peerNumber = message.peerNumber;
    obj.groupChatId = message.groupChatId;
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
}

- (void)onFileMessageReceived:(JRFileMessageItem *)item {
    // 发送回执
    if (item.imdnType == JRMessageItemImdnTypeBoth || item.imdnType == JRMessageItemImdnTypeDeli) {
        [[JRMessage sharedInstance] sendCommand:item command:JRMessageCommandTypeDelivered extraParams:nil];
    }
    JRMessageObject *message = [JRMessageDBHelper getMessageWithTransferId:item.fileTransId];
    if (message) {
        // 已存在该消息
        return;
    }
    JRMessageObject *obj = [[JRMessageObject alloc] initWithFileMessage:item];
    
    NSString *formatNumber;
    if (item.sessIdentity.length) {
        formatNumber = item.sessIdentity;
        obj.isRead = [obj.peerNumber isEqualToString:self.currentNumber];
    } else {
        formatNumber = [JRNumberUtil numberWithChineseCountryCode:obj.peerNumber];
        obj.isRead = [JRNumberUtil isNumberEqual:obj.peerNumber secondNumber:self.currentNumber];
    }
    if (obj.isRead) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[JRMessageManager shareInstance] sendCommand:obj command:JRMessageCommandTypeRead group:nil];
        });
    }
    // 存缩略图
    if (item.fileThumbPath.length) {
        NSString *thumbRelativePath = [JRFileUtil createFilePathWithFileName:[JRFileUtil getFileNameWithType:@"png"] folderName:@"thumb" peerUserName:formatNumber];
        NSString *absolutePath = [JRFileUtil getAbsolutePathWithFileRelativePath:thumbRelativePath];
        if ([[NSFileManager defaultManager] moveItemAtPath:item.fileThumbPath toPath:absolutePath error:NULL]) {
            obj.fileThumbPath = thumbRelativePath;
        }
    }
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:formatNumber group:item.sessIdentity.length];
        if (!conversation) {
            conversation = [[JRConversationObject alloc] init];
            conversation.peerNumber = formatNumber;
            conversation.isGroup = item.sessIdentity.length;
        }
        [realm beginWriteTransaction];
        conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
        [realm addOrUpdateObject:obj];
        [realm addOrUpdateObject:conversation];
        [realm commitWriteTransaction];
    }
    if (item.messageType == JRMessageItemTypeAudio || item.messageType == JRMessageItemTypeVcard) {
        // 音频和名片自动接收
        NSString *folderName = item.messageType == JRMessageItemTypeAudio ? @"audio" : @"vcard";
        NSString *fileRPath = [JRFileUtil createFilePathWithFileName:item.fileName folderName:folderName peerUserName:formatNumber];
        item.filePath = [JRFileUtil getAbsolutePathWithFileRelativePath:fileRPath];
        [[JRMessage sharedInstance] transferFileMessage:item];
    }
}

- (void)onFileMessageUpdate:(JRFileMessageItem *)item {
    JRMessageObject *message = [JRMessageDBHelper getMessageWithTransferId:item.fileTransId];
    if (!message || message.state == JRMessageItemStateRevoked) {
        // 消息不存在
        return;
    }
    JRMessageObject *obj = [[JRMessageObject alloc] initWithFileMessage:item];
    obj.isRead = message.isRead;
    obj.fileThumbPath = message.fileThumbPath;
    obj.peerNumber = message.peerNumber;
    obj.groupChatId = message.groupChatId;
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
}

- (void)onOfflineMessageReceive:(NSArray<JRMessageItem *> *)items {
    for (JRMessageItem *item in items) {
        // 发送回执
        if (item.imdnType == JRMessageItemImdnTypeBoth || item.imdnType == JRMessageItemImdnTypeDeli) {
            [[JRMessage sharedInstance] sendCommand:item command:JRMessageCommandTypeDelivered extraParams:nil];
        }
    }
    // 一次性插入
    NSMutableArray<JRMessageObject *> *messages = [NSMutableArray arrayWithCapacity:items.count];
    NSMutableArray<JRConversationObject *> *conversations = [[NSMutableArray alloc] init];
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        for (JRMessageItem *item in items) {
            if ([item isKindOfClass:[JRTextMessageItem class]]) {
                JRMessageObject *obj = [[JRMessageObject alloc] initWithTextMessage:(JRTextMessageItem *)item];
                NSString *formatNumber;
                if (item.sessIdentity.length) {
                    formatNumber = item.sessIdentity;
                    obj.isRead = [obj.peerNumber isEqualToString:self.currentNumber];
                } else {
                    formatNumber = [JRNumberUtil numberWithChineseCountryCode:item.senderNumber];
                    obj.isRead = [JRNumberUtil isNumberEqual:obj.peerNumber secondNumber:self.currentNumber];
                }
                if (obj.isRead) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[JRMessageManager shareInstance] sendCommand:obj command:JRMessageCommandTypeRead group:nil];
                    });
                }
                [messages addObject:obj];
                JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:formatNumber group:item.sessIdentity.length];
                if (!conversation) {
                    conversation = [[JRConversationObject alloc] init];
                    conversation.peerNumber = formatNumber;
                    conversation.isGroup = item.sessIdentity.length;
                }
                [conversations addObject:conversation];
            } else if ([item isKindOfClass:[JRFileMessageItem class]]) {
                JRMessageObject *obj = [[JRMessageObject alloc] initWithFileMessage:(JRFileMessageItem *)item];
                NSString *formatNumber;
                if (item.sessIdentity.length) {
                    formatNumber = item.sessIdentity;
                    obj.isRead = [obj.peerNumber isEqualToString:self.currentNumber];
                } else {
                    formatNumber = [JRNumberUtil numberWithChineseCountryCode:item.senderNumber];
                    obj.isRead = [JRNumberUtil isNumberEqual:obj.peerNumber secondNumber:self.currentNumber];
                }
                if (obj.isRead) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[JRMessageManager shareInstance] sendCommand:obj command:JRMessageCommandTypeRead group:nil];
                    });
                }
                // 存缩略图
                if (((JRFileMessageItem *)item).fileThumbPath.length) {
                    NSString *thumbRelativePath = [JRFileUtil createFilePathWithFileName:[JRFileUtil getFileNameWithType:@"png"] folderName:@"thumb" peerUserName:formatNumber];
                    NSString *absolutePath = [JRFileUtil getAbsolutePathWithFileRelativePath:thumbRelativePath];
                    if ([[NSFileManager defaultManager] moveItemAtPath:((JRFileMessageItem *)item).fileThumbPath toPath:absolutePath error:NULL]) {
                        obj.fileThumbPath = thumbRelativePath;
                    }
                }
                [messages addObject:obj];
                JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:formatNumber group:item.sessIdentity.length];
                if (!conversation) {
                    conversation = [[JRConversationObject alloc] init];
                    conversation.peerNumber = formatNumber;
                    conversation.isGroup = item.sessIdentity.length;
                }
                [conversations addObject:conversation];
            } else if ([item isKindOfClass:[JRGeoMessageItem class]]) {
                JRMessageObject *obj = [[JRMessageObject alloc] initWithGeoMessage:(JRGeoMessageItem *)item];
                NSString *formatNumber;
                if (item.sessIdentity.length) {
                    formatNumber = item.sessIdentity;
                    obj.isRead = [obj.peerNumber isEqualToString:self.currentNumber];
                } else {
                    formatNumber = [JRNumberUtil numberWithChineseCountryCode:item.senderNumber];
                    obj.isRead = [JRNumberUtil isNumberEqual:obj.peerNumber secondNumber:self.currentNumber];
                }
                if (obj.isRead) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[JRMessageManager shareInstance] sendCommand:obj command:JRMessageCommandTypeRead group:nil];
                    });
                }
                [messages addObject:obj];
                JRConversationObject *conversation = [JRMessageDBHelper getConversationWithNumber:formatNumber group:item.sessIdentity.length];
                if (!conversation) {
                    conversation = [[JRConversationObject alloc] init];
                    conversation.peerNumber = formatNumber;
                    conversation.isGroup = item.sessIdentity.length;
                }
                [conversations addObject:conversation];
            }
        }
        
        [realm beginWriteTransaction];
        for (JRConversationObject *conversation in conversations) {
            conversation.updateTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
        }
        [realm addOrUpdateObjects:conversations];
        [realm addOrUpdateObjects:messages];
        [realm commitWriteTransaction];
        
        for (JRMessageItem *item in items) {
            if ([item isKindOfClass:[JRFileMessageItem class]]) {
                if (item.messageType == JRMessageItemTypeAudio || item.messageType == JRMessageItemTypeVcard) {
                    // 音频和名片自动接收
                    NSString *formatNumber;
                    if (item.sessIdentity.length) {
                        formatNumber = item.sessIdentity;
                    } else {
                        formatNumber = [JRNumberUtil numberWithChineseCountryCode:item.senderNumber];
                    }
                    
                    NSString *folderName = item.messageType == JRMessageItemTypeAudio ? @"audio" : @"vcard";
                    NSString *fileRPath = [JRFileUtil createFilePathWithFileName:((JRFileMessageItem *)item).fileName folderName:folderName peerUserName:formatNumber];
                    ((JRFileMessageItem *)item).filePath = [JRFileUtil getAbsolutePathWithFileRelativePath:fileRPath];
                    [[JRMessage sharedInstance] transferFileMessage:(JRFileMessageItem *)item];
                }
            } else if ([item isKindOfClass:[JRGeoMessageItem class]]) {
                // 地理位置消息自动接收
                [[JRMessage sharedInstance] fetchGeoMessage:(JRGeoMessageItem *)item];
            }
        }
    }
}

- (void)onCommandReceive:(NSString *)imdnId peerNumber:(NSString *)peerNumber command:(JRMessageCommandType)command {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRMessageObject *obj = [JRMessageDBHelper getMessageWithImdnId:imdnId];
        if (obj) {
            [realm beginWriteTransaction];
            if (command == JRMessageCommandTypeRevoke) {
                obj.state = JRMessageItemStateRevoked;
            } else if (command == JRMessageCommandTypeRead) {
                obj.state = JRMessageItemStateRead;
            } else if (command == JRMessageCommandTypeDelivered) {
                obj.state = JRMessageItemStateDelivered;
            }
            [realm commitWriteTransaction];
        }
    }
}

- (void)onCommandSendResult:(BOOL)result command:(JRMessageCommandType)command imdnId:(NSString *)imdnId {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRMessageObject *obj = [JRMessageDBHelper getMessageWithImdnId:imdnId];
        [realm beginWriteTransaction];
        if (command == JRMessageCommandTypeRevoke) {
            obj.state = JRMessageItemStateRevoked;
        }
        [realm commitWriteTransaction];
    }
}

@end
