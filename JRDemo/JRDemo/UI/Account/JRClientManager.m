//
//  JRClientManager.m
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRClientManager.h"
#import "JRAutoConfigManager.h"

NSString * const kClientStateChangeNotification = @"kClientStateChangeNotification";
NSString * const kClientLoginFailedNotification = @"kClientLoginFailedNotification";
NSString * const kClientLogoutNotification = @"kClientLogoutNotification";
NSString * const kClientStateKey = @"kClientStateKey";
NSString * const kClientReasonKey = @"kClientReasonKey";

@interface JRClientManager () <JRClientCallback>

@end

@implementation JRClientManager

+ (JRClientManager *)sharedInstance {
    static JRClientManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JRClientManager alloc] init];
        [JRClient sharedInstance].delegate = instance;
    });
    return instance;
}

- (void)onClientInitResult:(BOOL)result reason:(JRClientInitReason)reason {
    if (!result) {
        [SVProgressHUD showErrorWithStatus:@"初始化失败"];
    }
}

- (void)onLogin:(bool)result reason:(JRClientReason)reason {
    if (!result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kClientLoginFailedNotification object:nil userInfo:@{kClientReasonKey:[NSNumber numberWithInt:reason]}];
    }
}

- (void)onLogout:(JRClientReason)reason {
    [[NSNotificationCenter defaultCenter] postNotificationName:kClientLogoutNotification object:nil userInfo:@{kClientReasonKey:[NSNumber numberWithInt:reason]}];
}

- (void)onClientStateChange:(JRClientState)state {
    [[NSNotificationCenter defaultCenter] postNotificationName:kClientStateChangeNotification object:nil userInfo:@{kClientStateKey:[NSNumber numberWithInt:state]}];
}

@end
