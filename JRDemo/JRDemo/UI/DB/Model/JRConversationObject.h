//
//  JRConversationObject.h
//  JRDemo
//
//  Created by Ginger on 2018/2/7.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Realm/Realm.h>
#import "JRMessageObject.h"

@interface JRConversationObject : RLMObject

/**
 对端号码，如果为群聊即是群identity
 */
@property NSString *peerNumber;

/**
 会话更新时间
 */
@property NSString *updateTime;

/**
 是否为群聊
 */
@property BOOL isGroup;

/**
 是否置顶
 */
@property BOOL isTop;

/**
 获取这个会话的所有消息

 @return 所有消息
 */
- (RLMResults<JRMessageObject *> *)getAllMessages;

/**
 获取这个会话未读消息数量

 @return 这个会话未读消息数量
 */
- (NSInteger)getUnreadCount;

/**
 将这个会话的所有未读消息设为已读
 */
- (void)readAllMessages;

/**
 获取这个会话最后一条消息

 @return 最后一条消息
 */
- (JRMessageObject *)getLastMessage;

@end
