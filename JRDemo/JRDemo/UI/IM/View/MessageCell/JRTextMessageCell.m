//
//  JRTextMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRTextMessageCell.h"
#import "JRTextLayout.h"

@implementation JRTextMessageCell

- (void)configWithLayout:(JRBaseBubbleLayout *)layout
{
    [super configWithLayout:layout];
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = TextFont;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 0;
        [self.msgContentView addSubview:_contentLabel];
    }
    _contentLabel.text = ((JRTextLayout *)layout).contentLabelText;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _contentLabel.textColor = ((JRTextLayout *)self.layout).contentLabelTextColor;
    _contentLabel.frame = ((JRTextLayout *)self.layout).contentLabelFrame;
}

@end
