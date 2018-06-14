//
//  JRTextLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRTextLayout.h"

@implementation JRTextLayout

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName {
    [super configWithMessage:message shouldShowTime:showTime shouldShowName:showName];
    _contentLabelText = self.message.content;
    if (self.message.direction == JRMessageItemDirectionSend) {
        _contentLabelTextColor = [UIColor whiteColor];
    } else {
        _contentLabelTextColor = [UIColor blackColor];
    }
    _contentLabelFrame = CGRectMake(0, 0, CGRectGetWidth(self.contentViewFrame), CGRectGetHeight(self.contentViewFrame));
}

@end
