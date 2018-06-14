//
//  JRAudioLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleLayout.h"

@interface JRAudioLayout : JRBaseBubbleLayout

@property (nonatomic, assign) CGRect durationLabelFrame;
@property (nonatomic, copy) NSString *durationLabelText;
@property (nonatomic, assign) NSTextAlignment durationLabelAligment;
@property (nonatomic, strong) UIColor *durationLabelTextColor;

@property (nonatomic, assign) CGRect imageViewFrame;
@property (nonatomic, strong) UIImage *audioImage;
@property (nonatomic, strong) NSArray *animationImages;

@end
