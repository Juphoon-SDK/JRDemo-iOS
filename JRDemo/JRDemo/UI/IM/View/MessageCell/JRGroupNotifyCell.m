//
//  JRGroupNotifyCell.m
//  JRDemo
//
//  Created by Ginger on 2018/5/9.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupNotifyCell.h"

@implementation JRGroupNotifyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = nil;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configWithLayout:(JRGroupNotifyLayout *)layout
{
    self.layout = layout;
    
    if (!_groupHintLabel) {
        _groupHintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _groupHintLabel.textColor = [UIColor whiteColor];
        _groupHintLabel.textAlignment = NSTextAlignmentCenter;
        _groupHintLabel.font = InfoTextFont;
        _groupHintLabel.numberOfLines = 0;
        _groupHintLabel.layer.cornerRadius = 10.0f;
        _groupHintLabel.clipsToBounds = YES;
        [self.contentView addSubview:_groupHintLabel];
    }
    _groupHintLabel.text = layout.groupHintLabelText;
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_timeLabel];
    }
    _timeLabel.text = layout.timeLabelText;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _timeLabel.frame = self.layout.timeLabelFrame;
    _groupHintLabel.frame = self.layout.groupHintLabelFrame;
    _groupHintLabel.backgroundColor = self.layout.groupHintLabelColor;
}

@end
