//
//  JRAudioMessageCell.h
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleMessageCell.h"
#import "JRAudioPlayHelper.h"

@interface JRAudioMessageCell : JRBaseBubbleMessageCell <AudioPlayerHelperDelegate>

@property (nonatomic, strong) UIImageView *messageVoiceAniamtionImageView;
@property (nonatomic, strong) UILabel *voiceDurationLabel;

- (void)startAniamtion;
- (void)stopAniamtion;

@end
