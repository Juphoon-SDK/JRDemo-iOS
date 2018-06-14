//
//  ImageMessageCell.m
//  MeetYou
//
//  Created by Ginger on 2017/8/11.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "JRThumbImageMessageCell.h"
#import "UIImage+Tint.h"
#import "JRThumbImageLayout.h"

@implementation JRThumbImageMessageCell

- (void)configWithLayout:(JRBaseBubbleLayout *)layout {
    [super configWithLayout:layout];
    if (!_thumbImage) {
        _thumbImage = [[UIImageView alloc] init];
        _thumbImage.contentMode = UIViewContentModeScaleToFill;
        _thumbImage.layer.cornerRadius = 10.0;
        _thumbImage.layer.masksToBounds = YES;
        _thumbImage.clipsToBounds = YES;
        [self.msgContentView addSubview:_thumbImage];
    }
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.text = @"";
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        [self.msgContentView addSubview:_durationLabel];
    }
    if (!_playBtn) {
        _playBtn = [[UIImageView alloc] init];
        [self.msgContentView addSubview:_playBtn];
    }
    
    JRThumbImageLayout *tempLayout = (JRThumbImageLayout *)layout;
    _playBtn.hidden = !tempLayout.showPlayBtn;
    _playBtn.image = tempLayout.playBtnImage;
    _thumbImage.image = tempLayout.thumbnail;
    _durationLabel.hidden = !tempLayout.showDurationLabel;
    _durationLabel.text = tempLayout.durationLabelText;
    self.bubbleView.backgroundColor = layout.bubbleViewBackgroupColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    JRThumbImageLayout *tempLayout = (JRThumbImageLayout *)self.layout;
    _thumbImage.frame = tempLayout.thumbnailFrame;
    _playBtn.frame = tempLayout.playBtnFrame;
    _durationLabel.frame = tempLayout.durationLabelFrame;
}

@end
