//
//  JRClientManager.h
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kClientStateChangeNotification;
extern NSString * const kClientLoginFailedNotification;
extern NSString * const kClientLogoutNotification;
extern NSString * const kClientStateKey;
extern NSString * const kClientReasonKey;

@interface JRClientManager : NSObject

@property (nonatomic, copy) NSString *multiVideoToken;

+ (JRClientManager *)sharedInstance;

@end
