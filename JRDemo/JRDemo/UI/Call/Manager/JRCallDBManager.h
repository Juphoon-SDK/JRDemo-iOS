//
//  JRCallDBManager.h
//  JRDemo
//
//  Created by Ginger on 2018/4/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRCallObject.h"

@interface JRCallDBManager : NSObject

+ (RLMResults<JRCallObject *> *)getAllCalls;

+ (RLMResults<JRCallObject *> *)getMissCalls;

+ (void)deleteAllCalls;

+ (void)deleteMissCalls;

+ (void)deleteCall:(NSString *)beginTime;

+ (void)deleteCalls:(NSArray<JRCallObject *> *)calls;

@end
