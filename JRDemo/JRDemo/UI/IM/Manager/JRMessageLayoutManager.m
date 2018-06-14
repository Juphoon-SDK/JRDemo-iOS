//
//  JRMessageLayoutManager.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRMessageLayoutManager.h"
#import "JRConversationObject.h"

@implementation JRMessageLayoutManager

+ (JRMessageLayoutManager *)shareInstance {
    static JRMessageLayoutManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JRMessageLayoutManager alloc] init];
        instance.layoutDic = [[NSMutableDictionary alloc] init];
    });
    return instance;
}

- (void)creatLayoutWithMessage:(JRMessageObject *)message showTime:(BOOL)showTime {
    switch (message.type) {
        case JRMessageItemTypeNotify: {
            JRGroupNotifyLayout *layout = [[JRGroupNotifyLayout alloc] init];
            [layout configWithMessage:message];
            [self.layoutDic setObject:layout forKey:message.imdnId];
            break;
        }
        case JRMessageItemTypeText: {
            JRTextLayout *layout = [[JRTextLayout alloc] init];
            [layout configWithMessage:message shouldShowTime:showTime shouldShowName:YES];
            [self.layoutDic setObject:layout forKey:message.imdnId];
            break;
        }
        case JRMessageItemTypeImage:
        case JRMessageItemTypeVideo: {
            JRThumbImageLayout *layout = [[JRThumbImageLayout alloc] init];
            [layout configWithMessage:message shouldShowTime:showTime shouldShowName:YES];
            [self.layoutDic setObject:layout forKey:message.transId];
            break;
        }
        case JRMessageItemTypeAudio: {
            JRAudioLayout *layout = [[JRAudioLayout alloc] init];
            [layout configWithMessage:message shouldShowTime:showTime shouldShowName:YES];
            [self.layoutDic setObject:layout forKey:message.transId];
            break;
        }
        case JRMessageItemTypeGeo: {
            JRLocationLayout *layout = [[JRLocationLayout alloc] init];
            [layout configWithMessage:message shouldShowTime:showTime shouldShowName:YES];
            [self.layoutDic setObject:layout forKey:message.transId];
            break;
        }
        case JRMessageItemTypeVcard: {
            JRVCardLayout *layout = [[JRVCardLayout alloc] init];
            [layout configWithMessage:message shouldShowTime:showTime shouldShowName:YES];
            [self.layoutDic setObject:layout forKey:message.transId];
            break;
        }
        case JRMessageItemTypeOtherFile: {
            JROtherFileLayout *layout = [[JROtherFileLayout alloc] init];
            [layout configWithMessage:message shouldShowTime:showTime shouldShowName:YES];
            [self.layoutDic setObject:layout forKey:message.transId];
            break;
        }
        case JRMessageItemTypeUnknow:
        default:
            break;
    }
}

@end
