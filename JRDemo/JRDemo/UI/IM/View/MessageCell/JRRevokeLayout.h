//
//  JRRevokeLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/7/20.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRMessageObject.h"

#define RevokeMargin 10
#define RevokeBubbleMargin 10
#define RevokeCellWidth [UIScreen mainScreen].bounds.size.width
#define RevokeContentLabelMaxWidth RevokeCellWidth - 100
#define RevokeTextFont [UIFont systemFontOfSize:12]

@interface JRRevokeLayout : NSObject

@property (nonatomic, strong) JRMessageObject *message;

@property (nonatomic, assign) CGRect revokeHintLabelFrame;
@property (nonatomic, copy) NSString *revokeHintLabelText;
@property (nonatomic, strong) UIColor *revokeHintLabelColor;

@property (nonatomic, copy) NSString *imdnId;

- (void)configWithMessage:(JRMessageObject *)message;
- (CGFloat)calculateCellHeight;

@end
