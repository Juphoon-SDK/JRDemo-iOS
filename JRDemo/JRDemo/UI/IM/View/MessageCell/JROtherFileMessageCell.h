//
//  JROtherFileMessageCell.h
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleMessageCell.h"

@interface JROtherFileMessageCell : JRBaseBubbleMessageCell

@property (nonatomic, strong) UIImageView *fileThumbImageView;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic, strong) UILabel *fileSizeLabel;

@end
