//
//  JRLocationLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/2/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleLayout.h"

@interface JRLocationLayout : JRBaseBubbleLayout

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, assign) CGRect iconImageFrame;
@property (nonatomic, copy) NSString *titleLabelText;
@property (nonatomic, assign) CGRect titleLabelFrame;
@property (nonatomic, strong) UIColor *titleLabelTextColor;

@end
