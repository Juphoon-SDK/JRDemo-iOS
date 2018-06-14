//
//  JRFileUtil.h
//  JRDemo
//
//  Created by Ginger on 2018/2/7.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionHandler)(NSError *error, NSString *fileRelativePath);

@interface JRFileUtil : NSObject

/**
 获取根路径

 @return 根路径
 */
+ (NSString *)getDocumentPath;

/**
 根目录下一级路径
 
 @param dir 文件夹名称
 @return 根目录下一级路径
 */
+ (NSString *)getDirectoryForDocuments:(NSString *)dir;

/**
 创建路径 dir/number/folerName/fileName
 
 @param fileName  文件名 such as XXXX.png
 @param folderName 文件夹名称 such as Image
 @param number 号码 such as 1001
 @return 相对路径
 */
+ (NSString *)createFilePathWithFileName:(NSString *)fileName folderName:(NSString *)folderName peerUserName:(NSString *)number;

/**
 根据路径生成缩略图，支持图片和视频
 
 @param filePath 相对路径
 @param number 对方号码
 @return 缩略图相对路径
 */
+ (NSString *)getThumbPathWithFilePath:(NSString *)filePath peerUserName:(NSString *)number;

/**
 根据相对路径获取绝对路径
 
 @param 相对路径
 @return 绝对路径
 */
+ (NSString *)getAbsolutePathWithFileRelativePath:(NSString *)fileRelativePath;

/**
 根据绝对路径获取相对路径

 @param fileAbsolutePath 绝对路径
 @return 相对路径
 */
+ (NSString *)getRelativePathWithFileAbsolutePath:(NSString *)fileAbsolutePath;

/**
 根据相对路径获取图片
 
 @param 图片相对路径
 @return 图片
 */
+ (UIImage *)getImageWithFileRelativePath:(NSString *)fileRelativePath;

/**
 根据文件后缀生成唯一文件名
 
 @param type 文件后缀 such as "png" "mp4"
 @return 文件名
 */
+ (NSString *)getFileNameWithType:(NSString *)type;

/**
 删除对应号码路径下的所有文件
 
 @param number 对方号码
 @return 成功失败
 */
+ (BOOL)deleteFilesWithNumber:(NSString *)number;

/**
 根据文件路径获取MD5
 
 @param path 相对路径
 @return md5
 */
+ (NSString *)getFileMD5WithPath:(NSString *)path;

/**
 根据文件路径获取可供SDK接口使用的文件类型

 @param path 文件路径
 @return 文件类型
 */
+ (NSString *)getFileTypeWithPath:(NSString *)path;

/**
 视频转码

 @param path 视频相对路径
 @param number 对方号码，用于生成到对应路径下
 @param completionHandler 完成block
 */
+ (void)convertVideoFormat:(NSString *)path peerUserName:(NSString *)number completionHandler:(CompletionHandler)completionHandler;

/**
 根据vCard路径获取联系人信息

 @param path vCard相对路径
 @param error 错误
 @return 联系人列表
 */
+ (NSArray *)addressBookRecordsWithRelativePath:(NSString *)path error:(NSError * __autoreleasing *)error;

@end
