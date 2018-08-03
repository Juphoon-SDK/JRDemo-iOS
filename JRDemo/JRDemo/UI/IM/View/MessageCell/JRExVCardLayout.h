//
//  JRExVCardLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/7/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleLayout.h"

@interface JRExVCardLayout : JRBaseBubbleLayout

@property (nonatomic, assign) CGRect vContentFrame;
@property (nonatomic, copy) NSString *vContent;

@property (nonatomic, assign) BOOL vShowAccept;
@property (nonatomic, assign) CGRect vAcceptFrame;

@end
