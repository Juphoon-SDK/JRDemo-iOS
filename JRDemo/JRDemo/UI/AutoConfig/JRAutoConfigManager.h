//
//  JRAutoConfigManager.h
//  JRDemo
//
//  Created by Home on 16/04/2018.
//  Copyright © 2018 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDMPAutoLoginViewController.h"
#import "IDMPTempSmsMode.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

typedef void (^accessTokenBlock)(NSString *token);

@protocol JRAutoConfigManagerDelegate <NSObject>

//统一认证初始化
- (void)cmccAuthIdmpInitSucceed;
- (void)cmccAuthIdmpInitFailed:(NSUInteger)resultCode;

- (void)cmccCpGetAuthInformationSucceed:(NSString *)userName password:(NSString *)password token:(NSString *)token;
- (void)cmccCpGetAuthInformationFailed:(NSUInteger)resultCode;

@end

@interface JRAutoConfigManager : NSObject

@property (nonatomic, strong) IDMPAutoLoginViewController *autoLoginViewController;
@property (nonatomic, weak) id<JRAutoConfigManagerDelegate> delegate;

/**
 单例

 @return 获取单例
 */
+ (JRAutoConfigManager *)sharedInstance;

/**
 初始化

 @param appId appid
 @param key appkey
 @param time 超时时间
 */
- (void)initAutoLoginWithAppId:(NSString *)appId andAppKey:(NSString *)key timeoutInterval:(NSInteger)time;

/**
 有蜂窝网络的情况下获取统一认证token
 */
- (void)requestLoginAuthInPs;

/**
 请求业务token

 @param block 请求结果
 */
- (void)requestAccessTokenFinishBlock:(accessTokenBlock)block;

@end
