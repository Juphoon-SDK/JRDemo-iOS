//
//  JRMessageManager.h
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRMessageObject.h"
#import "JRGroupObject.h"

@interface JRMessageManager : NSObject <JRMessageCallback>

/**
 当前是否处于会话界面，用来设置message的isRead属性
 */
@property (nonatomic, copy) NSString *currentNumber;

+ (JRMessageManager *)shareInstance;

/**
 发送文本消息

 @param message 内容
 @param number 对方号码
 @return 成功失败
 */
- (BOOL)sendTextMessage:(NSString *)message number:(NSString *)number;

/**
 发送文本消息
 
 @param message 内容
 @param group 群组
 @return 成功失败
 */
- (BOOL)sendTextMessage:(NSString *)message group:(JRGroupObject *)group;

/**
 发送文件

 @param path 文件相对路径
 @param thumbPath 缩略图相对路径
 @param type 文件类型
 @param number 对方号码
 @return 成功失败
 */
- (BOOL)sendFile:(NSString *)path thumbPath:(NSString *)thumbPath type:(NSString *)type number:(NSString *)number;

/**
 发送文件
 
 @param path 文件相对路径
 @param thumbPath 缩略图相对路径
 @param type 文件类型
 @param group 群组
 @return 成功失败
 */
- (BOOL)sendFile:(NSString *)path thumbPath:(NSString *)thumbPath type:(NSString *)type group:(JRGroupObject *)group;

/**
 发送地理位置消息

 @param geoLabel 描述
 @param latitude 纬度
 @param longitude 经度
 @param radius 半径
 @param number 对方号码
 @return 成功失败
 */
- (BOOL)sendGeo:(NSString *)geoLabel latitude:(double)latitude longitude:(double)longitude radius:(float)radius number:(NSString *)number;

/**
 发送地理位置消息
 
 @param geoLabel 描述
 @param latitude 纬度
 @param longitude 经度
 @param radius 半径
 @param group 群组
 @return 成功失败
 */
- (BOOL)sendGeo:(NSString *)geoLabel latitude:(double)latitude longitude:(double)longitude radius:(float)radius group:(JRGroupObject *)group;

/**
 传输文件

 @param message 消息对象
 @return 成功失败
 */
- (BOOL)transferFile:(JRFileMessageItem *)message;

/**
 加载位置消息

 @param message 消息对象
 @return 成功失败
 */
- (BOOL)fetchGeo:(JRGeoMessageItem *)message;

/**
 重发消息

 @param message 消息对象
 @return 成功失败
 */
- (BOOL)resendMessage:(JRMessageObject *)message;

@end
