//
//  JRMessageObject.h
//  JRDemo
//
//  Created by Ginger on 2018/2/7.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Realm/Realm.h>

@interface JRMessageObject : RLMObject

/**
 消息唯一标识
 */
@property NSString *imdnId;

/**
 传输唯一标识
 */
@property NSString *transId;

/**
 对端号码，如果是群则为群sessidentity
 */
@property NSString *peerNumber;

/**
 如果是群聊则有群groupChatId
 */
@property NSString *groupChatId;

/**
 发送号码
 */
@property NSString *senderNumber;

/**
 接收号码
 */
@property NSString *receiverNumber;

/**
 时间戳
 */
@property NSString *timestamp;

/**
 消息类型
 */
@property JRMessageItemType type;

/**
 消息状态
 */
@property JRMessageItemState state;

/**
 消息方向
 */
@property JRMessageItemDirection direction;

/**
 文本消息内容
 */
@property NSString *content;

/**
 文件名
 */
@property NSString *fileName;

/**
 文件类型
 */
@property NSString *fileType;

/**
 文件相对路径
 */
@property NSString *filePath;

/**
 文件缩略图相对路径
 */
@property NSString *fileThumbPath;

/**
 文件媒体长度
 */
@property NSString *fileMediaDuration;

/**
 文件大小
 */
@property NSString *fileSize;

/**
 文件已传输大小
 */
@property NSString *fileTransSize;

/**
 纬度
 */
@property NSString *geoLatitude;

/**
 经度
 */
@property NSString *geoLongitude;

/**
 半径
 */
@property NSString *geoRadius;

/**
 描述
 */
@property NSString *geoFreeText;

/**
 是否已读
 */
@property BOOL isRead;

/**
 是否阅后即焚
 */
@property BOOL isBurnAfterReading;

/**
 是否静默
 */
@property BOOL isSilence;

/**
 是否定向
 */
@property BOOL isDirect;

/**
 是否抄送
 */
@property BOOL isCarbonCopy;

/**
 是否离线
 */
@property BOOL isOffline;

/**
 是否@
 */
@property BOOL isAtMsg;

/**
 消息类型
 */
@property JRMessageChannelType channelType;

/**
 回执类型
 */
@property JRMessageItemImdnType imdnType;

/**
 conversationId
 */
@property NSString *conversationId;

/**
 文本消息拓展类型
 */
@property JRTextMessageContentType contentType;

/**
 根据item初始化

 @param message item
 @return object
 */
- (instancetype)initWithMessage:(JRMessageItem *)message;
- (instancetype)initWithTextMessage:(JRTextMessageItem *)message;
- (instancetype)initWithFileMessage:(JRFileMessageItem *)message;
- (instancetype)initWithGeoMessage:(JRGeoMessageItem *)message;
- (instancetype)initWithGroup:(JRGroupItem *)group notify:(NSString *)content;

@end
