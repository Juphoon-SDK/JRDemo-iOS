//
//  JRMessageObject.m
//  JRDemo
//
//  Created by Ginger on 2018/2/7.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRMessageObject.h"
#import "JRNumberUtil.h"
#import "JRFileUtil.h"

@implementation JRMessageObject

+ (NSString *)primaryKey {
    return @"imdnId";
}

- (instancetype)initWithMessage:(JRMessageItem *)message {
    if ([super init]) {
        self.imdnId = message.messageImdnId;
        self.senderNumber = [JRNumberUtil numberWithChineseCountryCode:message.senderNumber];
        self.receiverNumber = [JRNumberUtil numberWithChineseCountryCode:message.receiverNumber];
        self.timestamp = [NSString stringWithFormat:@"%lld", message.timestamp];
        self.type = message.messageType;
        self.state = message.messageState;
        self.direction = message.messageDirection;
        self.channelType = message.messageChannelType;
        if (message.sessIdentity) {
            self.peerNumber = message.sessIdentity;
            self.groupChatId = message.groupChatId;
        } else {
            self.peerNumber = message.messageDirection == JRMessageItemDirectionReceive ? [JRNumberUtil numberWithChineseCountryCode:message.senderNumber] : [JRNumberUtil numberWithChineseCountryCode:message.receiverNumber];
        }
        self.isRead = YES;
        self.isBurnAfterReading = message.isBurnAfterReading;
        self.isSilence = message.isSilence;
        self.isDirect = message.isDirect;
        self.isCarbonCopy = message.isCarbonCopy;
        self.isOffline = message.isOffline;
    }
    return self;
}

- (instancetype)initWithTextMessage:(JRTextMessageItem *)message {
    if ([self initWithMessage:message]) {
        self.content = message.content;
        self.isAtMsg = message.isAtMsg;
    }
    return self;
}

- (instancetype)initWithFileMessage:(JRFileMessageItem *)message {
    if ([self initWithMessage:message]) {
        self.fileName = message.fileName;
        self.fileType = message.fileType;
        self.filePath = [JRFileUtil getRelativePathWithFileAbsolutePath:message.filePath];
        self.fileThumbPath = [JRFileUtil getRelativePathWithFileAbsolutePath:message.fileThumbPath];
        self.fileMediaDuration = [NSString stringWithFormat:@"%ld", (long)message.fileMediaDuration];
        self.fileSize = [NSString stringWithFormat:@"%ld", (long)message.fileSize];
        self.fileTransSize = [NSString stringWithFormat:@"%ld",(long) message.fileTransSize];
        self.transId = message.fileTransId;
    }
    return self;
}

- (instancetype)initWithGeoMessage:(JRGeoMessageItem *)message {
    if ([self initWithMessage:message]) {
        self.geoLatitude = [NSString stringWithFormat:@"%f", message.geoLatitude];
        self.geoLongitude = [NSString stringWithFormat:@"%f", message.geoLongitude];
        self.geoRadius = [NSString stringWithFormat:@"%f", message.geoRadius];
        self.geoFreeText = message.geoFreeText;
        self.transId = message.geoTransId;
    }
    return self;
}

- (instancetype)initWithGroup:(JRGroupItem *)group notify:(NSString *)content {
    if ([super init]) {
        self.imdnId = [[NSUUID UUID] UUIDString];
        self.timestamp = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
        self.channelType = JRMessageChannelTypeGroup;
        self.content = content;
        self.peerNumber = group.sessIdentity;
        self.groupChatId = group.groupChatId;
        self.type = JRMessageItemTypeNotify;
        self.isRead = true;
    }
    return self;
}

@end
