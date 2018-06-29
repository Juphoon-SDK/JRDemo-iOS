//
//  JRAudioLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAudioLayout.h"
#import "UIImage+Tint.h"

#define AudioMargin 3
#define VoiceDurationLabelWidth 30

@implementation JRAudioLayout

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName {
    [super configWithMessage:message shouldShowTime:showTime shouldShowName:showName];
    
    _durationLabelAligment = self.message.direction == JRMessageItemDirectionSend || self.message.isCarbonCopy ? NSTextAlignmentLeft : NSTextAlignmentRight;
    _durationLabelTextColor = self.message.direction == JRMessageItemDirectionSend || self.message.isCarbonCopy ? [UIColor whiteColor] : [JRSettings skinColor];
    _durationLabelText = [NSString stringWithFormat:@"%@\'\'", message.fileMediaDuration];
    if (self.message.direction == JRMessageItemDirectionSend || self.message.isCarbonCopy) {
        _durationLabelFrame = CGRectMake(AudioMargin, 0, VoiceDurationLabelWidth, self.contentViewFrame.size.height);
        _imageViewFrame = CGRectMake(CGRectGetMaxX(_durationLabelFrame)+AudioMargin, 0, self.contentViewFrame.size.width-3*AudioMargin-VoiceDurationLabelWidth, self.contentViewFrame.size.height);
        _audioImage = [[UIImage imageNamed:@"SenderVoiceNodePlaying"] imageWithColor:[UIColor whiteColor]];
    } else {
        _imageViewFrame = CGRectMake(AudioMargin, 0, self.contentViewFrame.size.width-3*AudioMargin-VoiceDurationLabelWidth, self.contentViewFrame.size.height);
        _durationLabelFrame = CGRectMake(CGRectGetMaxX(_imageViewFrame)+AudioMargin, 0, VoiceDurationLabelWidth, self.contentViewFrame.size.height);
        _audioImage = [[UIImage imageNamed:@"ReceiverVoiceNodePlaying"] imageWithColor:[JRSettings skinColor]];
    }
    NSString *imageSepatorName = self.message.direction == JRMessageItemDirectionSend || self.message.isCarbonCopy ? @"Sender" : @"Receiver";
    UIColor *imageColor = self.message.direction == JRMessageItemDirectionSend || self.message.isCarbonCopy ? [UIColor whiteColor] : [JRSettings skinColor];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger i = 0; i < 4; i ++) {
        UIImage *image = [[UIImage imageNamed:[imageSepatorName stringByAppendingFormat:@"VoiceNodePlaying00%ld", (long)i]] imageWithColor:imageColor];
        if (image)
            [images addObject:image];
    }
    _animationImages = [NSArray arrayWithArray:images];
}

@end
