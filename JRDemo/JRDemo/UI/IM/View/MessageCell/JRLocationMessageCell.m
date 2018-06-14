//
//  JRLocationMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRLocationMessageCell.h"
#import "JRLocationLayout.h"

@implementation JRLocationMessageCell

- (void)configWithLayout:(JRBaseBubbleLayout *)layout {
    [super configWithLayout:layout];
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleToFill;
        [self.msgContentView addSubview:_iconView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        [self.msgContentView addSubview:_titleLabel];
    }
    JRLocationLayout *tempLayout = (JRLocationLayout *)layout;
    _iconView.image = tempLayout.iconImage;
    _titleLabel.text = tempLayout.titleLabelText;
    _titleLabel.textColor = tempLayout.titleLabelTextColor;
    self.bubbleView.backgroundColor = layout.bubbleViewBackgroupColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    JRLocationLayout *tempLayout = (JRLocationLayout *)self.layout;
    _iconView.frame = tempLayout.iconImageFrame;
    _titleLabel.frame = tempLayout.titleLabelFrame;
}

@end
