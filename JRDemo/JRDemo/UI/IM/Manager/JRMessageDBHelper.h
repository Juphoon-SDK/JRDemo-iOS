//
//  JRMessageDBHelper.h
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRConversationObject.h"
#import "JRMessageObject.h"

@interface JRMessageDBHelper : NSObject

/**
 将对应联系人的未读消息置为已读

 @param peerNumber 对方号码
 */
+ (void)readAllMessagesWithNumber:(NSString *)peerNumber group:(BOOL)group;

/**
 根据号码查询会话

 @param peerNumber 对方号码，如为群则为群identity
 @return 会话对象
 */
+ (JRConversationObject *)getConversationWithNumber:(NSString *)peerNumber group:(BOOL)group;

/**
 根据imdnId查询消息

 @param imdnId imdnId
 @return 消息对象
 */
+ (JRMessageObject *)getMessageWithImdnId:(NSString *)imdnId;

/**
 根据transferId查询消息

 @param transId transferId
 @return 消息对象
 */
+ (JRMessageObject *)getMessageWithTransferId:(NSString *)transId;

/**
 查找对应号码的所有消息

 @param peerNumber 对方号码
 @return 消息
 */
+ (RLMResults<JRMessageObject *> *)getMessagesWithNumber:(NSString *)peerNumber group:(BOOL)group;

/**
 查找其他类型文件的所有消息

 @return 其他类型文件的所有消息
 */
+ (NSArray<JRMessageObject *> *)getOtherFileMessages;

/**
 删除对应号码的会话

 @param peerNumber 对方号码，如为群则为群identity
 */
+ (void)deleteConversationWithNumber:(NSString *)peerNumber group:(BOOL)group;

/**
 将所有传输中的文件的状态改为失败，用来重新发起
 */
+ (void)resetAllTransferingMessage;

/**
 删除所有通知消息
 */
+ (void)deleteAllNotifyMessage;

/**
 JRMessageItem与JRMessageObject相互转换
 */
+ (JRTextMessageItem *)converTextMessage:(JRMessageObject *)obj;
+ (JRFileMessageItem *)converFileMessage:(JRMessageObject *)obj;
+ (JRGeoMessageItem *)converGeoMessage:(JRMessageObject *)obj;

@end
