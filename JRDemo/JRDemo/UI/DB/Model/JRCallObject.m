//
//  JRCallObject.m
//  JRDemo
//
//  Created by Ginger on 2018/4/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRCallObject.h"
#import "JRNumberUtil.h"

@implementation JRCallObject

+ (NSString *)primaryKey {
    return @"beginTime";
}

- (instancetype)initWithCall:(JRCallItem *)call {
    if ([super init]) {
        NSMutableArray<NSString *> *numbers = [NSMutableArray arrayWithCapacity:call.callMembers.count];
        for (JRCallMember *member in call.callMembers) {
            [numbers addObject:[JRNumberUtil numberWithChineseCountryCode:member.number]];
        }
        self.number = [numbers componentsJoinedByString:@","];
        self.direction = call.direction;
        self.type = call.type;
        self.state = call.state;
        self.beginTime = [NSString stringWithFormat:@"%ld", call.beginTime];
        self.endTime = [NSString stringWithFormat:@"%ld", call.endTime];
        self.talkingBeginTime = [NSString stringWithFormat:@"%ld", call.talkingBeginTime];
        self.read = false;
    }
    return self;
}

@end
