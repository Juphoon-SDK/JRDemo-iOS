//
//  JRAudioMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAudioMessageCell.h"
#import "JRAudioLayout.h"

@implementation JRAudioMessageCell

- (void)configWithLayout:(JRBaseBubbleLayout *)layout {
    [super configWithLayout:layout];
    
    if (!_messageVoiceAniamtionImageView) {
        _messageVoiceAniamtionImageView = [[UIImageView alloc] init];
        _messageVoiceAniamtionImageView.contentMode = UIViewContentModeScaleAspectFit;
        _messageVoiceAniamtionImageView.userInteractionEnabled = YES;
        [self.msgContentView addSubview:_messageVoiceAniamtionImageView];
    }
    
    if (!_voiceDurationLabel) {
        _voiceDurationLabel = [[UILabel alloc] init];
        _voiceDurationLabel.backgroundColor = [UIColor clearColor];
        _voiceDurationLabel.font = [UIFont systemFontOfSize:12.f];
        [self.msgContentView addSubview:_voiceDurationLabel];
    }
    
    if (self.layout.message.state == JRMessageItemStateReceiveOK || self.layout.message.direction == JRMessageItemDirectionSend) {
        [self.msgContentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAudio)]];
    }
    
    JRAudioLayout *tempLayout = (JRAudioLayout *)layout;
    _voiceDurationLabel.textAlignment = tempLayout.durationLabelAligment;
    _voiceDurationLabel.textColor = tempLayout.durationLabelTextColor;
    _voiceDurationLabel.text = tempLayout.durationLabelText;
    
    _messageVoiceAniamtionImageView.image = tempLayout.audioImage;
    _messageVoiceAniamtionImageView.animationImages = tempLayout.animationImages;
    _messageVoiceAniamtionImageView.animationDuration = 1.0;
    [_messageVoiceAniamtionImageView stopAnimating];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    JRAudioLayout *tempLayout = (JRAudioLayout *)self.layout;
    _voiceDurationLabel.frame = tempLayout.durationLabelFrame;
    _messageVoiceAniamtionImageView.frame = tempLayout.imageViewFrame;
}

- (void)playAudio {
    [JRAudioPlayHelper shareInstance].delegate = self;
    if (self.layout.message.state == JRMessageItemStateReceiveOK || self.layout.message.direction == JRMessageItemDirectionSend) {
        if ([[JRAudioPlayHelper shareInstance].filePath isEqualToString:[JRFileUtil getAbsolutePathWithFileRelativePath:self.layout.message.filePath]] && [JRAudioPlayHelper shareInstance].isPlaying) {
            [[JRAudioPlayHelper shareInstance] stopAudio];
        } else {
            [[JRAudioPlayHelper shareInstance] stopAudio];
            [[JRAudioPlayHelper shareInstance] playAudioWithFilePath:[JRFileUtil getAbsolutePathWithFileRelativePath:self.layout.message.filePath]];
        }
    }
}

- (void)audioPlayerDidBeginPlay:(AVAudioPlayer *)audioPlayer {
    [self.messageVoiceAniamtionImageView startAnimating];
}

- (void)audioPlayerDidStopPlay:(AVAudioPlayer *)audioPlayer {
    [self.messageVoiceAniamtionImageView stopAnimating];
}

- (void)audioPlayerDidPausePlay:(AVAudioPlayer *)audioPlayer {
    [self.messageVoiceAniamtionImageView stopAnimating];
}

- (void)startAniamtion {
    [self.messageVoiceAniamtionImageView startAnimating];
}

- (void)stopAniamtion {
    [self.messageVoiceAniamtionImageView stopAnimating];
}

@end
