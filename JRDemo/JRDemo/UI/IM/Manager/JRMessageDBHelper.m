//
//  JRMessageDBHelper.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRMessageDBHelper.h"
#import "JRMessageObject.h"
#import "JRNumberUtil.h"

@implementation JRMessageDBHelper

+ (void)readAllMessagesWithNumber:(NSString *)peerNumber group:(BOOL)group {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        if (!group) {
            peerNumber = [JRNumberUtil numberWithChineseCountryCode:peerNumber];
        }
        RLMResults *results = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@ && %K == 0", @"peerNumber", peerNumber, @"isRead"]];
        int count = (int)results.count;
        [realm beginWriteTransaction];
        for (int i=0; i<count; i++) {
            JRMessageObject *message = results[0];
            message.isRead = YES;
        }
        [realm commitWriteTransaction];
    }
}

+ (JRConversationObject *)getConversationWithNumber:(NSString *)peerNumber group:(BOOL)group {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        if (!group) {
            peerNumber = [JRNumberUtil numberWithChineseCountryCode:peerNumber];
        }
        RLMResults<JRConversationObject *> *results = [JRConversationObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"peerNumber", peerNumber]];
        if (results.count == 1) {
            return results.firstObject;
        }
    }
    return nil;
}

+ (JRMessageObject *)getMessageWithImdnId:(NSString *)imdnId {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults<JRMessageObject *> *results = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"imdnId", imdnId]];
        if (results.count == 1) {
            return results.firstObject;
        }
    }
    return nil;
}

+ (JRMessageObject *)getMessageWithTransferId:(NSString *)transId {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults<JRMessageObject *> *results = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"transId", transId]];
        if (results.count == 1) {
            return results.firstObject;
        }
    }
    return nil;
}

+ (RLMResults<JRMessageObject *> *)getMessagesWithNumber:(NSString *)peerNumber group:(BOOL)group {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        if (!group) {
            peerNumber = [JRNumberUtil numberWithChineseCountryCode:peerNumber];
        }
        return [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"peerNumber", peerNumber]];
    }
    return nil;
}

+ (NSArray<JRMessageObject *> *)getOtherFileMessages {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults<JRMessageObject *> *messages = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"type", [NSNumber numberWithInt:JRMessageItemTypeOtherFile]]];
        NSMutableArray<JRMessageObject *> *array = [NSMutableArray arrayWithCapacity:messages.count];
        for (JRMessageObject *obj in messages) {
            if (obj.filePath.length && (obj.direction == JRMessageItemDirectionSend || obj.state == JRMessageItemStateReceiveOK)) {
                [array addObject:obj];
            }
        }
        // 过滤相同路径文件
        NSMutableArray *files = [NSMutableArray arrayWithCapacity:messages.count];
        for (int i = 0; i < array.count; i ++) {
            NSString *string = [array objectAtIndex:i].filePath;
            NSMutableArray *tempArray = [@[] mutableCopy];
            [tempArray addObject:[array objectAtIndex:i]];
            for (int j = i+1; j < array.count; j ++) {
                NSString *jstring = [array objectAtIndex:j].filePath;
                if([string isEqualToString:jstring]){
                    [tempArray addObject:[array objectAtIndex:j]];
                    [array removeObjectAtIndex:j];
                    j -= 1;
                }
            }
            [files addObject:[tempArray firstObject]];
        }
        return [NSArray arrayWithArray:files];
    }
    return nil;
}

+ (void)resetAllTransferingMessage {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        RLMResults *receving = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@ || %K == %@", @"state", [NSNumber numberWithInteger:JRMessageItemStateReceiveInvite], @"state", [NSNumber numberWithInteger:JRMessageItemStateReceiving]]];
        int recevingCount = (int)receving.count;
        RLMResults *sending = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@ || %K == %@", @"state", [NSNumber numberWithInteger:JRMessageItemStateSendInvite], @"state", [NSNumber numberWithInteger:JRMessageItemStateSending]]];
        int sendingCount = (int)sending.count;
        [realm beginWriteTransaction];
        for (int i=0; i<recevingCount; i++) {
            JRMessageObject *message = receving[0];
            message.state = JRMessageItemStateReceiveFailed;
        }
        for (int i=0; i<sendingCount; i++) {
            JRMessageObject *message = sending[0];
            message.state = JRMessageItemStateSendFailed;
        }
        [realm commitWriteTransaction];
    }
}

+ (void)deleteAllNotifyMessage {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"type", [NSNumber numberWithInt:JRMessageItemTypeNotify]];
        RLMResults<JRMessageObject *> *messages = [JRMessageObject objectsInRealm:realm withPredicate:pred];
        [realm beginWriteTransaction];
        [realm deleteObjects:messages];
        [realm commitWriteTransaction];
    }
}

+ (void)deleteConversationWithNumber:(NSString *)peerNumber group:(BOOL)group {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        if (!group) {
            peerNumber = [JRNumberUtil numberWithChineseCountryCode:peerNumber];
        }
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"peerNumber", peerNumber];
        RLMResults *conversations = [JRConversationObject objectsInRealm:realm withPredicate:pred];
        RLMResults *messages = [JRMessageObject objectsInRealm:realm withPredicate:pred];
        [JRFileUtil deleteFilesWithNumber:[JRNumberUtil numberWithChineseCountryCode:peerNumber]];
        [realm beginWriteTransaction];
        [realm deleteObjects:conversations];
        [realm deleteObjects:messages];
        [realm commitWriteTransaction];
    }
}

+ (JRFileMessageItem *)converFileMessage:(JRMessageObject *)obj {
    JRFileMessageItem *message = [[JRFileMessageItem alloc] init];
    message.messageImdnId = obj.imdnId;
    message.senderNumber = obj.senderNumber;
    message.receiverNumber = obj.receiverNumber;
    message.timestamp = [obj.timestamp longLongValue];
    message.messageType = obj.type;
    message.messageState = obj.state;
    message.messageDirection = obj.direction;
    if (obj.groupChatId.length) {
        message.groupChatId = obj.groupChatId;
        message.sessIdentity = obj.peerNumber;
    }
    
    message.fileName = obj.fileName;
    message.fileType = obj.fileType;
    message.filePath = [JRFileUtil getAbsolutePathWithFileRelativePath:obj.filePath];
    message.fileThumbPath = [JRFileUtil getAbsolutePathWithFileRelativePath:obj.fileThumbPath];
    message.fileMediaDuration = [obj.fileMediaDuration integerValue];
    message.fileSize = [obj.fileSize integerValue];
    message.fileTransSize = [obj.fileTransSize integerValue];
    message.fileTransId = obj.transId;
    message.messageChannelType = obj.channelType;
    return message;
}

+ (JRGeoMessageItem *)converGeoMessage:(JRMessageObject *)obj {
    JRGeoMessageItem *message = [[JRGeoMessageItem alloc] init];
    message.messageImdnId = obj.imdnId;
    message.senderNumber = obj.senderNumber;
    message.receiverNumber = obj.receiverNumber;
    message.timestamp = [obj.timestamp longLongValue];
    message.messageType = obj.type;
    message.messageState = obj.state;
    message.messageDirection = obj.direction;
    if (obj.groupChatId.length) {
        message.groupChatId = obj.groupChatId;
        message.sessIdentity = obj.peerNumber;
    }
    
    message.geoLatitude = [obj.geoLatitude floatValue];
    message.geoLongitude = [obj.geoLongitude floatValue];
    message.geoRadius = [obj.geoRadius floatValue];
    message.geoFreeText = obj.geoFreeText;
    message.geoTransId = obj.transId;
    message.messageChannelType = obj.channelType;
    return message;
}

@end
