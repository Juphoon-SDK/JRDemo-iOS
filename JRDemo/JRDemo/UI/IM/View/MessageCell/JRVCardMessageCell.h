//
//  JRVCardMessageCell.h
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleMessageCell.h"

@interface JRVCardMessageCell : JRBaseBubbleMessageCell

@property (nonatomic, strong) UIImageView *vIconImageView;
@property (nonatomic, strong) UILabel *vNameLabel;
@property (nonatomic, strong) UILabel *vNumberLabel;

@end
