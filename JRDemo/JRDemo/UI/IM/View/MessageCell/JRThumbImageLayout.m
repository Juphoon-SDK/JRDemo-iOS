//
//  JRThumbImageLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/2/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRThumbImageLayout.h"
#import "JRFileUtil.h"

#define durationLabelHeight 20
#define durationLabelMargin 15

@implementation JRThumbImageLayout

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName {
    [super configWithMessage:message shouldShowTime:showTime shouldShowName:showName];
    if (self.message.fileThumbPath) {
        _thumbnail = [UIImage imageWithContentsOfFile:[JRFileUtil getAbsolutePathWithFileRelativePath:self.message.fileThumbPath]];
    }
    _showPlayBtn = self.message.type == JRMessageItemTypeVideo;
    
    if (self.message.type == JRMessageItemTypeVideo) {
        _playBtnImage = [UIImage imageNamed:@"btn_play"];
        _durationLabelText = [NSString stringWithFormat:@"%@\'\'", message.fileMediaDuration];
        _showDurationLabel = YES;
    } else {
        _playBtnImage = [UIImage imageNamed:@""];
        _showDurationLabel = NO;
    }
    
    _thumbnailFrame = CGRectMake(0, 0, CGRectGetWidth(self.contentViewFrame), CGRectGetHeight(self.contentViewFrame));
    _playBtnFrame = CGRectMake(_thumbnailFrame.size.width/2-25, _thumbnailFrame.size.height/2-25, 50, 50);
    _durationLabelFrame = CGRectMake(durationLabelMargin, _thumbnailFrame.size.height-durationLabelHeight-durationLabelMargin, _thumbnailFrame.size.width-2*durationLabelMargin, durationLabelHeight);
    self.bubbleViewBackgroupColor = [UIColor clearColor];
}

@end
