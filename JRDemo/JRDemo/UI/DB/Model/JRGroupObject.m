//
//  JRGroupObject.m
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupObject.h"

@implementation JRGroupObject

+ (NSString *)primaryKey {
    return @"identity";
}

- (instancetype)initWithGroup:(JRGroupItem *)group {
    if ([super init]) {
        self.name = group.subject;
        self.identity = group.sessIdentity;
        self.chatId = group.groupChatId;
        self.groupVersion = group.groupVersion;
        self.type = group.groupType;
        self.groupState = group.groupState;
        self.chairMan = group.chairMan;
    }
    return self;
}

@end
