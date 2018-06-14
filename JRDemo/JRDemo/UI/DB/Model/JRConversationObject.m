//
//  JRConversationObject.m
//  JRDemo
//
//  Created by Ginger on 2018/2/7.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRConversationObject.h"

@implementation JRConversationObject

+ (NSString *)primaryKey {
    return @"peerNumber";
}

- (RLMResults<JRMessageObject *> *)getAllMessages {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"peerNumber", self.peerNumber];
    RLMResults<JRMessageObject *> *result = [JRMessageObject objectsInRealm:realm withPredicate:pred];
    return result;
}

- (NSInteger)getUnreadCount {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    RLMResults<JRMessageObject *> *messages = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@ && %K == 0", @"peerNumber", self.peerNumber, @"isRead"]];
    return messages.count;
}

- (void)readAllMessages {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    [realm beginWriteTransaction];
    RLMResults *results = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@ && %K == 0", @"peerNumber", self.peerNumber, @"isRead"]];
    int count = (int)results.count;
    for (int i=0; i<count; i++) {
        JRMessageObject *message = results[0];
        message.isRead = YES;
    }
    [realm commitWriteTransaction];
}

- (JRMessageObject *)getLastMessage {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    RLMResults<JRMessageObject *> *messages = [JRMessageObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"peerNumber", self.peerNumber]];
    if (messages.count == 0) {
        return nil;
    } else {
        return messages.lastObject;
    }
}

@end
