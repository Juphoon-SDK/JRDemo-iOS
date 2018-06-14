//
//  JRRealmWrapper.m
//  JRDemo
//
//  Created by Ginger on 2018/2/7.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRRealmWrapper.h"
#import "JRClientManager.h"

#define kJRRealmVersion 1

static RLMRealmConfiguration *configuration;

@interface RealmConfigManager : NSObject

+ (RLMRealmConfiguration *)getDefaultConfig;
+ (RLMRealmConfiguration *)getRealmConfigBeyondCurrentUser;

@end

@implementation RealmConfigManager

+ (RLMRealmConfiguration *)getDefaultConfig {
    return [RLMRealmConfiguration defaultConfiguration];
}

+ (RLMRealmConfiguration *)getRealmConfigBeyondCurrentUser {
    if (!configuration) {
        NSString *user = [JRClient sharedInstance].currentUser;
        if (!user.length) {
            return nil;
        }
        NSString *userName = [JRAccount getAccountConfig:user forKey:JRAccountConfigKeyName].stringParam;
        // NSString *server = [JRAccount getAccountConfig:user forKey:JRAccountConfigKeyServerRealm].stringParam;
        // NSString *authName = [NSString stringWithFormat:@"%@@%@", userName, server];
        NSString *authName = userName;
        if (!authName.length) {
            return nil;
        }
        // 以userName和server拼接路径，保证唯一性
        NSString *path = [[NSString alloc] initWithFormat:@"%@/realm", authName];
        path = [[JRFileUtil getDocumentPath] stringByAppendingPathComponent:@"profiles/DB"];
        BOOL isDictionary;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDictionary];
        if (!exist || !isDictionary) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.realm", authName]];
        
        configuration = [[RLMRealmConfiguration alloc] init];
        configuration.fileURL = [NSURL fileURLWithPath:path];
        configuration.schemaVersion = kJRRealmVersion;
        configuration.deleteRealmIfMigrationNeeded = NO;
        configuration.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {

        };

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChanged:) name:kClientStateChangeNotification object:nil];
    }
    
    return configuration;
}

+ (void)stateChanged:(NSNotification *)notification {
    JRClientState state = [(NSNumber *)[notification.userInfo objectForKey:kClientStateKey] intValue];
    if (state == JRClientStateLogined) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        configuration = nil;
    }
}

@end

@implementation JRRealmWrapper

+ (RLMRealm *)getRealmInstance {
    NSError *error = nil;
    RLMRealmConfiguration *configuration = [RealmConfigManager getRealmConfigBeyondCurrentUser];
    RLMRealm *realm = nil;
    if (configuration) {
        realm = [RLMRealm realmWithConfiguration:configuration error:&error];
    } else {
        NSLog(@"Need cliOpen first");
    }
    if (error) {
        NSLog(@"error=%@", error.description ? error.description : error.localizedFailureReason ? error.localizedFailureReason : @"");
        realm = nil;
    } else {
        if (![NSThread isMainThread]) {
            [realm refresh];
        }
    }
    return realm;
}

@end
