//
//  JRNumberUtil.m
//  JRDemo
//
//  Created by Ginger on 2018/2/12.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRNumberUtil.h"

@implementation JRNumberUtil

#pragma mark - Public Function

+ (NSString *)numberWithoutChineseCountryCode:(NSString *)number {
    NSString *temp = [self getDialableNumber:number];
    if (!temp.length) {
        return nil;
    }
    if ([self validatePhoneNum:temp] && [temp hasPrefix:@"+86"]) {
        return [temp substringFromIndex:3];
    }
    return temp;
}

+ (NSString *)numberWithChineseCountryCode:(NSString *)number {
    NSString *temp = [self getDialableNumber:number];
    if (!temp.length) {
        return nil;
    }
    if ([self validatePhoneNum:temp] && ![temp hasPrefix:@"+86"]) {
        return [@"+86" stringByAppendingString:temp];
    }
    return temp;
}

+ (BOOL)isNumberEqual:(NSString *)firstNumber secondNumber:(NSString *)secondNumber {
    if (![self getDialableNumber:firstNumber].length || ![self getDialableNumber:secondNumber].length) {
        return false;
    }
    if ([[self numberWithoutChineseCountryCode:firstNumber] isEqualToString:[self numberWithoutChineseCountryCode:secondNumber]]) {
        return true;
    }
    return false;
}

+ (NSString *)getDialableNumber:(NSString *)number {
    NSString *num = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableString *string = [NSMutableString stringWithCapacity:num.length];
    for (int i = 0; i < num.length; i ++) {
        unichar c = [num characterAtIndex:i];
        if (c == '+' || (c >= '0' && c <= '9') || c == ',') {
            [string appendFormat:@"%c", c];
        }
    }
    return [NSString stringWithString:string];
}

#pragma mark - Private Function

+ (BOOL)validatePhoneNum:(NSString *)num {
    NSString *phoneNumRegex = @"((\\+?86)|(\\(\\+86\\)))?[1][34578]\\d{9}";
    NSPredicate *phoneNumPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneNumRegex];
    return [phoneNumPredicate evaluateWithObject:[self getDialableNumber:num]];
}

@end
