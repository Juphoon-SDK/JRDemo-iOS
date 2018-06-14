//
//  JRGroupNotifyLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/5/9.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRMessageObject.h"

#define InfoTimeLabelHeight 20
#define InfoMargin 10
#define InfoBubbleMargin 10
#define InfoCellWidth [UIScreen mainScreen].bounds.size.width
#define InfoContentLabelMaxWidth InfoCellWidth - 100
#define InfoTextFont [UIFont systemFontOfSize:12]

@interface JRGroupNotifyLayout : NSObject

@property (nonatomic, strong) JRMessageObject *message;

@property (nonatomic, assign) CGRect groupHintLabelFrame;
@property (nonatomic, copy) NSString *groupHintLabelText;
@property (nonatomic, strong) UIColor *groupHintLabelColor;
@property (nonatomic, assign) CGRect timeLabelFrame;
@property (nonatomic, copy) NSString *timeLabelText;

@property (nonatomic, copy) NSString *imdnId;

- (void)configWithMessage:(JRMessageObject *)message;
- (CGFloat)calculateCellHeight;

@end
