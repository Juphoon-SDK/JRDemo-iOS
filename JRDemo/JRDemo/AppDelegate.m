//
//  AppDelegate.m
//  JRDemo
//
//  Created by Ginger on 2017/11/29.
//  Copyright © 2017年 Ginger. All rights reserved.
//

#import "AppDelegate.h"
#import "JRCallManager.h"
#import "JRClientManager.h"
#import "JRMessageManager.h"
#import "JRMessageDBHelper.h"
#import "JRGroupManager.h"
#import "JRAutoConfigManager.h"

// 和飞信域
#define UC_TOKEN_APPID  @""
#define UC_TOKEN_APPKEY @""
#define LICENSE_APPKEY @""

// juphoon域
//#define LICENSE_APPKEY @""
//#define UC_TOKEN_APPID  @""
//#define UC_TOKEN_APPKEY @""

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [JRCallManager sharedInstance];
    [JRClientManager sharedInstance];
    [JRMessageManager shareInstance];
    [JRAutoConfig sharedInstance];
    [JRGroupManager sharedInstance];
    [JRCapacity sharedInstance];
    [JRProfile sharedInstance];
    
    // 统一认证初始化
    [[JRAutoConfigManager sharedInstance] initAutoLoginWithAppId:UC_TOKEN_APPID andAppKey:UC_TOKEN_APPKEY timeoutInterval:120];

    NSString *bundleLcsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"license.sign"];
    [[JRClient sharedInstance] startInitSDK:bundleLcsPath appKey:LICENSE_APPKEY deviceType:JRClientDeviceTypeApp];
    
    [UINavigationBar appearance].shadowImage = [UIImage new];
    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = [JRSettings skinColor];
    [UINavigationBar appearance].titleTextAttributes = @{
                                                         NSForegroundColorAttributeName : [UIColor whiteColor],
                                                         };
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[JRClient sharedInstance] setBackgroud:YES];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[JRClient sharedInstance] setBackgroud:NO];
    [[JRClient sharedInstance] refresh];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
