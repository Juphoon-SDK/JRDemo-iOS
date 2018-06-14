//
//  ImageMessageCell.h
//  MeetYou
//
//  Created by Ginger on 2017/8/11.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "JRBaseBubbleMessageCell.h"

@interface JRThumbImageMessageCell : JRBaseBubbleMessageCell

@property (nonatomic, strong) UIImageView *thumbImage;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *playBtn;

@end
