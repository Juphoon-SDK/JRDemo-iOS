//
//  JRCallManager.h
//  JRDemo
//
//  Created by Ginger on 2018/1/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kCallUpdateNotification;
extern NSString * const kCallAddNotification;
extern NSString * const kCallRemoveNotification;
extern NSString * const kCallItemKey;
extern NSString * const kCallUpdateTypeKey;
extern NSString * const kCallTermReasonKey;

@interface JRCallManager : NSObject

+ (JRCallManager *)sharedInstance;

@end
