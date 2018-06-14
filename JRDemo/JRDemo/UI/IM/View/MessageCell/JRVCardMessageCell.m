//
//  JRVCardMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRVCardMessageCell.h"
#import "JRVCardLayout.h"

@implementation JRVCardMessageCell

- (void)configWithLayout:(JRBaseBubbleLayout *)layout {
    [super configWithLayout:layout];
    if (!_vIconImageView) {
        _vIconImageView = [[UIImageView alloc] init];
        _vIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _vIconImageView.userInteractionEnabled = YES;
        [self.msgContentView addSubview:_vIconImageView];
    }
    if (!_vNameLabel) {
        _vNameLabel = [[UILabel alloc] init];
        _vNameLabel.textColor = [UIColor blackColor];
        _vNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.msgContentView addSubview:_vNameLabel];
    }
    if (!_vNumberLabel) {
        _vNumberLabel = [[UILabel alloc] init];
        _vNumberLabel.textColor = [UIColor grayColor];
        _vNumberLabel.textAlignment = NSTextAlignmentCenter;
        [self.msgContentView addSubview:_vNumberLabel];
    }
    
    JRVCardLayout *tempLayout = (JRVCardLayout *)layout;
    _vIconImageView.image = tempLayout.vIconImage;
    _vNameLabel.text = tempLayout.vName;
    _vNumberLabel.text = tempLayout.vNumber;
    self.bubbleView.backgroundColor = layout.bubbleViewBackgroupColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    JRVCardLayout *tempLayout = (JRVCardLayout *)self.layout;
    _vIconImageView.frame = tempLayout.vIconFrame;
    _vNameLabel.frame = tempLayout.vNameLabelFrame;
    _vNumberLabel.frame = tempLayout.vNumberLabelFrame;
}

@end
