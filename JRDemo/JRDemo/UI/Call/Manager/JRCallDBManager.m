//
//  JRCallDBManager.m
//  JRDemo
//
//  Created by Ginger on 2018/4/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRCallDBManager.h"

@implementation JRCallDBManager

+ (RLMResults<JRCallObject *> *)getAllCalls {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        return [[JRCallObject allObjectsInRealm:realm] sortedResultsUsingKeyPath:@"beginTime" ascending:NO];;
    }
    return nil;
}

+ (RLMResults<JRCallObject *> *)getMissCalls {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        return [[JRCallObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K > %@", @"state", [NSNumber numberWithInt:JRCallStateOk]]] sortedResultsUsingKeyPath:@"beginTime" ascending:NO];;
    }
    return nil;
}

+ (void)deleteAllCalls {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        [realm beginWriteTransaction];
        [realm deleteObjects:[self getAllCalls]];
        [realm commitWriteTransaction];
    }
}

+ (void)deleteMissCalls {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        [realm beginWriteTransaction];
        [realm deleteObjects:[self getMissCalls]];
        [realm commitWriteTransaction];
    }
}

+ (void)deleteCall:(NSString *)beginTime {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        [realm beginWriteTransaction];
        [realm deleteObjects:[JRCallObject objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"beginTime", beginTime]]];
        [realm commitWriteTransaction];
    }
}

+ (void)deleteCalls:(NSArray<JRCallObject *> *)calls {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        [realm beginWriteTransaction];
        [realm deleteObjects:calls];
        [realm commitWriteTransaction];
    }
}

@end
