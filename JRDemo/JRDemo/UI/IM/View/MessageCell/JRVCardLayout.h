//
//  JRVCardLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleLayout.h"

@interface JRVCardLayout : JRBaseBubbleLayout

@property (nonatomic, strong) UIImage *vIconImage;
@property (nonatomic, assign) CGRect vIconFrame;

@property (nonatomic, copy) NSString *vNumber;
@property (nonatomic, assign) CGRect vNumberLabelFrame;

@property (nonatomic, copy) NSString *vName;
@property (nonatomic, assign) CGRect vNameLabelFrame;

@end
