//
//  JRLocationLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/2/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRLocationLayout.h"

@implementation JRLocationLayout

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName
{
    [super configWithMessage:message shouldShowTime:showTime shouldShowName:showName];
    _iconImage = [UIImage imageNamed:@"message_map"];
    _iconImageFrame = CGRectMake(0, 50, LocationSize.width, LocationSize.height-50);
    _titleLabelText = message.geoFreeText;
    _titleLabelFrame = CGRectMake(0, 0, LocationSize.width, 50);
    _titleLabelTextColor = [UIColor blackColor];
    self.bubbleViewBackgroupColor = [UIColor clearColor];
}

@end
