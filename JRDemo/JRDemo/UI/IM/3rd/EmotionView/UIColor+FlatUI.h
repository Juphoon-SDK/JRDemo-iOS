//
//  UIColor+FlatUI.h
//  MeetYou
//
//  Created by Ginger on 2017/8/15.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FlatUI)

+ (UIColor *) colorFromHexCode:(NSString *)hexString;
+ (UIColor *) senderColor;
+ (UIColor *) receiverColor;

@end
