//
//  JRTextLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleLayout.h"

@interface JRTextLayout : JRBaseBubbleLayout

@property (nonatomic, assign) CGRect contentLabelFrame;
@property (nonatomic, copy) NSString *contentLabelText;
@property (nonatomic, strong) UIColor *contentLabelTextColor;

@end
