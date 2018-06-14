//
//  JRBaseBubbleLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRMessageObject.h"

#define TimeLabelHeight 20
#define NameLabelHeight 20
#define CellWidth [UIScreen mainScreen].bounds.size.width
#define ContentLabelMaxWidth CellWidth-AvatorSize-2*Margin-75
#define AvatorSize 40
#define Margin 5
#define BubbleViewMargin 10
#define StateViewSize 15
#define StateViewMargin 5

#define TextFont [UIFont systemFontOfSize:16]
#define ImgMaxLine 200.0f
#define AudioSize CGSizeMake(100, 20)
#define LocationSize CGSizeMake(200, 150)
#define VCardSize CGSizeMake(200, 100)
#define OtherFileSize CGSizeMake(200, 100)

@interface JRBaseBubbleLayout : NSObject

@property (nonatomic, strong) JRMessageObject *message;

@property (nonatomic, assign) CGRect timeLabelFrame;
@property (nonatomic, copy) NSString *timeLabelText;
@property (nonatomic, assign) BOOL showTime;

@property (nonatomic, assign) CGRect nameLabelFrame;
@property (nonatomic, assign) NSTextAlignment nameLabelTextAlignment;
@property (nonatomic, copy) NSString *nameLabelText;
@property (nonatomic, assign) BOOL showName;

@property (nonatomic, assign) CGRect avatorViewFrame;
@property (nonatomic, strong) UIImage *avatorViewImage;

@property (nonatomic, assign) CGRect stateViewFrame;
@property (nonatomic, strong) UIImage *stateViewImage;

@property (nonatomic, assign) CGRect bubbleViewFrame;
@property (nonatomic, strong) UIColor *bubbleViewBackgroupColor;

@property (nonatomic, assign) CGRect contentViewFrame;

@property (nonatomic, copy) NSString *imdnId;

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName;
- (CGFloat)calculateCellHeight;

@end
