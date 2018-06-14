//
//  JRAutoConfigManager.m
//  JRDemo
//
//  Created by Home on 16/04/2018.
//  Copyright © 2018 Ginger. All rights reserved.
//

#import "JRAutoConfigManager.h"
#import "JRNumberUtil.h"

@implementation JRAutoConfigManager

+ (JRAutoConfigManager *)sharedInstance {
    static JRAutoConfigManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JRAutoConfigManager alloc] init];
        instance.autoLoginViewController = [[IDMPAutoLoginViewController alloc]init];
    });
    return instance;
}

- (void)initAutoLoginWithAppId:(NSString *)appId andAppKey:(NSString *)key timeoutInterval:(NSInteger)time {
    [_autoLoginViewController validateWithAppid:appId appkey:key timeoutInterval:time  finishBlock:^(NSDictionary *paraments) {
        if ([self.delegate respondsToSelector:@selector(cmccAuthIdmpInitSucceed)]) {
            [self.delegate cmccAuthIdmpInitSucceed];
        }
    } failBlock:^(NSDictionary *paraments) {
        [_autoLoginViewController validateWithAppid:appId appkey:key timeoutInterval:time  finishBlock:^(NSDictionary *paraments) {
            if ([self.delegate respondsToSelector:@selector(cmccAuthIdmpInitSucceed)]) {
                [self.delegate cmccAuthIdmpInitSucceed];
            }
        } failBlock:^(NSDictionary *paraments) {
            if ([self.delegate respondsToSelector:@selector(cmccAuthIdmpInitFailed:)]) {
                [self.delegate cmccAuthIdmpInitFailed:[[paraments objectForKey:@"resultCode"] integerValue]];
            }
        }];
    }];
}

- (void)requestLoginAuthInPs
{
    [_autoLoginViewController cleanSSO];
    
    [_autoLoginViewController getAppPasswordWithUserName:nil andLoginType:1 isUserDefaultUI:NO finishBlock:^(NSDictionary *paraments) {
        if (paraments == nil || ([paraments objectForKey:@"resultCode"] && [[paraments objectForKey:@"resultCode"] integerValue] != 102000)) {
            if ([self.delegate respondsToSelector:@selector(cmccCpGetAuthInformationFailed:)]) {
                [self.delegate cmccCpGetAuthInformationFailed:[[paraments objectForKey:@"resultCode"] integerValue]];
            }
            return;
        }
        if ([self.delegate respondsToSelector:@selector(cmccCpGetAuthInformationSucceed:password:token:)]) {
            [self.delegate cmccCpGetAuthInformationSucceed:[paraments objectForKey:@"username"] password:[paraments objectForKey:@"password"] token:[paraments objectForKey:@"token"]];
        }
    } failBlock:^(NSDictionary *paraments) {
        if ([self.delegate respondsToSelector:@selector(cmccCpGetAuthInformationFailed:)]) {
            [self.delegate cmccCpGetAuthInformationFailed:[[paraments objectForKey:@"resultCode"] integerValue]];
        }
    }];
}

- (void)requestAccessTokenFinishBlock:(accessTokenBlock)block {
    [_autoLoginViewController getAccessTokenWithUserName:[JRNumberUtil numberWithoutChineseCountryCode:[JRClient sharedInstance].currentNumber] andLoginType:1 isUserDefaultUI:NO finishBlock:^(NSDictionary *paraments) {
        if (paraments == nil || ([paraments objectForKey:@"resultCode"] && [[paraments objectForKey:@"resultCode"] integerValue] != 102000))
        {
            return;
        }
        block([paraments objectForKey:@"token"]);
    } failBlock:^(NSDictionary *paraments){
        block(nil);
    }];
}

@end
