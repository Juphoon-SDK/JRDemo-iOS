//
//  JRSwitchCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRSwitchCell.h"

@implementation JRSwitchCell

- (instancetype)init {
    self = [[NSBundle mainBundle] loadNibNamed:@"JRSwitchCell" owner:self options:nil].firstObject;
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
