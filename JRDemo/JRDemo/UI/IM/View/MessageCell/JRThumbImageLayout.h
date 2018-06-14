//
//  JRThumbImageLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/2/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleLayout.h"

@interface JRThumbImageLayout : JRBaseBubbleLayout

@property (nonatomic, strong) UIImage *playBtnImage;
@property (nonatomic, strong) UIImage *thumbnail;

@property (nonatomic, assign) BOOL showPlayBtn;
@property (nonatomic, assign) CGRect thumbnailFrame;
@property (nonatomic, assign) CGRect playBtnFrame;

@property (nonatomic, assign) BOOL showDurationLabel;
@property (nonatomic, assign) CGRect durationLabelFrame;
@property (nonatomic, copy) NSString *durationLabelText;

@end
