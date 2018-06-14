//
//  JRNumberUtil.h
//  JRDemo
//
//  Created by Ginger on 2018/2/12.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRNumberUtil : NSObject

/**
 去除+86

 @param number 号码
 @return 去除+86后的号码
 */
+ (NSString *)numberWithoutChineseCountryCode:(NSString *)number;

/**
 +86格式化号码

 @param number 号码
 @return 格式化后的号码
 */
+ (NSString *)numberWithChineseCountryCode:(NSString *)number;

/**
 去除特殊字符

 @param number 号码
 @return 格式化之后的号码
 */
+ (NSString *)getDialableNumber:(NSString *)number;

/**
 对比号码是否相同

 @param firstNumber 号码1
 @param secondNumber 号码2
 @return 是否相同
 */
+ (BOOL)isNumberEqual:(NSString *)firstNumber secondNumber:(NSString *)secondNumber;

@end
