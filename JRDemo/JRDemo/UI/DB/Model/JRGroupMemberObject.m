//
//  JRGroupMember.m
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupMemberObject.h"
#import "JRNumberUtil.h"

@implementation JRGroupMemberObject

- (instancetype)initWithGroupMember:(JRGroupMember *)member {
    if ([super init]) {
        self.displayName = member.displayName;
        self.groupIdentity = member.sessIdentity;
        self.number = [JRNumberUtil numberWithChineseCountryCode:member.number];
        self.state = member.state;
    }
    return self;
}

@end
