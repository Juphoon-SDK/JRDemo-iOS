//
//  JRRevokeMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/7/20.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRRevokeMessageCell.h"

@implementation JRRevokeMessageCell

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

- (void)configWithLayout:(JRRevokeLayout *)layout
{
    self.layout = layout;
    
    if (!_revokeHintLabel) {
        _revokeHintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _revokeHintLabel.textColor = [UIColor whiteColor];
        _revokeHintLabel.textAlignment = NSTextAlignmentCenter;
        _revokeHintLabel.font = RevokeTextFont;
        _revokeHintLabel.numberOfLines = 0;
        _revokeHintLabel.layer.cornerRadius = 10.0f;
        _revokeHintLabel.clipsToBounds = YES;
        [self.contentView addSubview:_revokeHintLabel];
    }
    _revokeHintLabel.text = layout.revokeHintLabelText;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _revokeHintLabel.frame = self.layout.revokeHintLabelFrame;
    _revokeHintLabel.backgroundColor = self.layout.revokeHintLabelColor;
}

@end
