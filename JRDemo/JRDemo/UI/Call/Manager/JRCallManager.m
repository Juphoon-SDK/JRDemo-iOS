//
//  JRCallManager.m
//  JRDemo
//
//  Created by Ginger on 2018/1/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRCallManager.h"
#import "JRCallViewController.h"
#import "JRRingHelper.h"
#import "JRCallObject.h"

NSString * const kCallUpdateNotification = @"kCallUpdateNotification";
NSString * const kCallAddNotification = @"kCallAddNotification";
NSString * const kCallRemoveNotification = @"kCallRemoveNotification";
NSString * const kCallItemKey = @"kCallItemKey";
NSString * const kCallUpdateTypeKey = @"kCallUpdateTypeKey";
NSString * const kCallTermReasonKey = @"kCallTermReasonKey";

@interface JRCallManager () <JRCallCallback>

@property (nonatomic, strong) JRCallViewController *callViewController;

@end

@implementation JRCallManager

+ (JRCallManager *)sharedInstance {
    static JRCallManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JRCallManager alloc] init];
        [JRCall sharedInstance].delegate = instance;
    });
    return instance;
}

#pragma mark - Call Delegate

- (void)onCallItemAdd:(JRCallItem *)item {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRCallObject *obj = [[JRCallObject alloc] initWithCall:item];
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!_callViewController) {
        _callViewController = [[JRCallViewController alloc] init];
    }
    NSDictionary *dic = @{kCallItemKey:item};
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallAddNotification object:nil userInfo:dic];
    
    if ([JRCall sharedInstance].currentCall) {
        if (item.direction == JRCallDirectionIn) {
            JRRingStartRing();
        }
        if (root.presentedViewController) {
            [root.presentedViewController presentViewController:_callViewController animated:YES completion:nil];
        } else {
            [root presentViewController:_callViewController animated:YES completion:nil];
        }
    }
}

- (void)onCallItemRemove:(JRCallItem *)item reason:(JRCallTermReason)reason {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRCallObject *obj = [[JRCallObject alloc] initWithCall:item];
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
    if (_callViewController.presentedViewController) {
        [_callViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [_callViewController dismissViewControllerAnimated:YES completion:nil];
    _callViewController = nil;
    if ((reason == JRCallTermReasonForbidden || reason == JRCallTermReasonNotFound || reason == JRCallTermReasonNotAcpted || reason == JRCallTermReasonInternalErr || reason == JRCallTermReasonSrvUnavail || reason == JRCallTermReasonTempUnavail || reason == JRCallTermReasonOtherError) && item.direction == JRCallDirectionOut) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"呼叫失败" message:@"是否使用系统电话呼叫" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)item.callMembers.firstObject.number, NULL, (CFStringRef)@"()", kCFStringEncodingUTF8));
            NSString *s = [NSString stringWithFormat:@"tel:%@", encodedString];
            NSURL *tel = [NSURL URLWithString:s];
            [[UIApplication sharedApplication] openURL:tel];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root.presentedViewController) {
            [root.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [root presentViewController:alert animated:YES completion:nil];
    }
    
    NSDictionary *dic = @{kCallItemKey:item, kCallTermReasonKey:[NSNumber numberWithInt:reason]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallRemoveNotification object:nil userInfo:dic];
}

- (void)onCallItemUpdate:(JRCallItem *)item updateType:(JRCallUpdateType)type {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRCallObject *obj = [[JRCallObject alloc] initWithCall:item];
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:obj];
        [realm commitWriteTransaction];
    }
    if (type == JRCallUpdateTypeTermed || type == JRCallUpdateTypeTalking) {
        JRRingStopRing();
    }
    NSDictionary *dic = @{kCallItemKey:item, kCallUpdateTypeKey:[NSNumber numberWithInt:type]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallUpdateNotification object:nil userInfo:dic];
}

@end
