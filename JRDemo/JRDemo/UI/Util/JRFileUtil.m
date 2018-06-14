//
//  JRFileUtil.m
//  JRDemo
//
//  Created by Ginger on 2018/2/7.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRFileUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AddressBook/AddressBook.h>
#import "JRNumberUtil.h"

@implementation JRFileUtil

+ (NSString *)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)getDirectoryForDocuments:(NSString *)dir {
    NSString* dirPath = [[self getDocumentPath] stringByAppendingPathComponent:dir];
    BOOL isDir = NO;
    BOOL isCreated = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
    if ( isCreated == NO || isDir == NO ) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
    return dirPath;
}

+ (NSString *)createFilePathWithFileName:(NSString *)fileName folderName:(NSString *)folderName peerUserName:(NSString *)number {
    number = [JRNumberUtil numberWithChineseCountryCode:number];
    if (!number.length) {
        return nil;
    }
    NSString *user = [JRClient sharedInstance].currentUser;
    if (!user.length) {
        return nil;
    }
    NSString *userName = [JRAccount getAccountConfig:user forKey:JRAccountConfigKeyName].stringParam;
    // NSString *server = [JRAccount getAccountConfig:user forKey:JRAccountConfigKeyServerRealm].stringParam;
    // NSString *authName = [NSString stringWithFormat:@"%@@%@", userName, server];
    NSString *authName = userName;
    if (!authName.length) {
        return nil;
    }
    NSString *rootPath = [self getDirectoryForDocuments:authName];
    NSString *folderAbsolutePath = [NSString stringWithFormat:@"%@/%@/%@", rootPath, number, folderName];
    NSString *folderRelativePath = [NSString stringWithFormat:@"%@/%@/%@", authName, number, folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderAbsolutePath]) {
        [fileManager createDirectoryAtPath:folderAbsolutePath
               withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileAbsolutePath = [folderAbsolutePath stringByAppendingPathComponent:fileName];
    NSString *fileRelativePath = [folderRelativePath stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:fileAbsolutePath]) {
        NSString *pathExtension = [fileName pathExtension];
        NSString *fileNameDeleteEx = [fileName stringByDeletingPathExtension];
        fileRelativePath = [NSString stringWithFormat:@"%@/%@_%@.%@",folderRelativePath,fileNameDeleteEx,[[NSUUID UUID] UUIDString],pathExtension];
    }
    return fileRelativePath;
}

+ (NSString *)getAbsolutePathWithFileRelativePath:(NSString *)fileRelativePath {
    if (fileRelativePath && fileRelativePath.length > 0) {
        NSString *rootPath = [self getDocumentPath];
        return [rootPath stringByAppendingPathComponent:fileRelativePath];
    }
    return nil;
}

+ (NSString *)getRelativePathWithFileAbsolutePath:(NSString *)fileAbsolutePath {
    if (fileAbsolutePath && fileAbsolutePath.length > 0) {
        NSString *rootPath = [self getDocumentPath];
        return [fileAbsolutePath stringByReplacingOccurrencesOfString:rootPath withString:@""];
    }
    return nil;
}

+ (UIImage *)getImageWithFileRelativePath:(NSString *)fileRelativePath {
    if (fileRelativePath && fileRelativePath.length > 0) {
        NSString *absolutePath = [self getAbsolutePathWithFileRelativePath:fileRelativePath];
        return [[UIImage alloc] initWithContentsOfFile:absolutePath];
    }
    return nil;
}

+ (NSString *)getFileNameWithType:(NSString *)type {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    formate.dateFormat = @"yyyy-MM-dd_HH-mm-ss-SSS";
    return [NSString stringWithFormat:@"%@.%@",[formate stringFromDate:currentDate], type];
}

+ (NSString *)getThumbPathWithFilePath:(NSString *)filePath peerUserName:(NSString *)number {
    number = [JRNumberUtil numberWithChineseCountryCode:number];
    NSString *absolutePath = [self getAbsolutePathWithFileRelativePath:filePath];
    NSString *fileName = [filePath lowercaseString];
    if (fileName.length && ([fileName hasSuffix:@"jpg"] || [fileName hasSuffix:@"jpeg"] || [fileName hasSuffix:@"png"] || [fileName hasSuffix:@"bmp"] || [fileName hasSuffix:@"gif"]))
    {
        UIImage *image = [UIImage imageWithContentsOfFile:absolutePath];
        NSData *imageData = [self imageDataWithImage:image maxDataSize:6.0f];
        
        NSString *fileRelativePath = [self createFilePathWithFileName:[self getFileNameWithType:@"png"] folderName:@"thumb" peerUserName:number];
        NSString *absolutePath = [self getAbsolutePathWithFileRelativePath:fileRelativePath];
        [imageData writeToFile:absolutePath atomically:YES];
        
        return fileRelativePath;
    } else if (fileName.length && ([fileName hasSuffix:@"3gp"] || [fileName hasSuffix:@"mp4"] || [fileName hasSuffix:@"mov"])) {
        NSURL *url = [NSURL fileURLWithPath:[self getAbsolutePathWithFileRelativePath:filePath]];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMake(0, 10);
        CMTime actualTime;
        NSError *error = nil;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        
        NSString *fileRelativePath = [self createFilePathWithFileName:[self getFileNameWithType:@"png"] folderName:@"thumb" peerUserName:number];
        NSString *absolutePath = [self getAbsolutePathWithFileRelativePath:fileRelativePath];
        [[self imageDataWithImage:thumb maxDataSize:6.0f] writeToFile:absolutePath atomically:YES];
        return fileRelativePath;
    }
    return nil;
}

+ (NSData *)imageDataWithImage:(UIImage *)image maxDataSize:(NSInteger)size {
    // Compress by quality
    long maxLength = size*1024;
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return data;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return data;
}

+ (BOOL)deleteFilesWithNumber:(NSString *)number {
    NSString *user = [JRClient sharedInstance].currentUser;
    if (!user.length) {
        return NO;
    }
    NSString *userName = [JRAccount getAccountConfig:user forKey:JRAccountConfigKeyName].stringParam;
    // NSString *server = [JRAccount getAccountConfig:user forKey:JRAccountConfigKeyServerRealm].stringParam;
    // NSString *authName = [NSString stringWithFormat:@"%@@%@", userName, server];
    NSString *authName = userName;
    if (!authName.length) {
        return NO;
    }
    NSFileManager *fileManeger = [NSFileManager defaultManager];
    NSString *rootPath = [self getDirectoryForDocuments:authName];
    NSString *filesPath = [rootPath stringByAppendingPathComponent:number];
    if ([fileManeger fileExistsAtPath:filesPath]) {
        return [fileManeger removeItemAtPath:filesPath error:nil];
    }
    return YES;
}

static CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath, size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =  CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = 1024*8;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

+ (NSString*)getFileMD5WithPath:(NSString *)path {
    NSString *absolutePath = [self getAbsolutePathWithFileRelativePath:path];
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)absolutePath, 1024*8);
}

+ (NSString *)getFileTypeWithPath:(NSString *)path {
#warning 待完善！
    if (!path.length) {
        return nil;
    }
    
    NSString *type = [[path componentsSeparatedByString:@"."].lastObject lowercaseString];
    if ([type isEqualToString:@"jpeg"]) {
        return MessageTypeImageJPEG;
    } else if ([type isEqualToString:@"gif"]) {
        return MessageTypeImageGIF;
    } else if ([type isEqualToString:@"png"]) {
        return MessageTypeImagePNG;
    } else if ([type isEqualToString:@"bmp"]) {
        return MessageTypeImageBMP;
    } else if ([type isEqualToString:@"mpg"]) {
        return MessageTypeVideoMPG;
    } else if ([type isEqualToString:@"mp4"]) {
        return MessageTypeVideoMP4;
    } else if ([type isEqualToString:@"3gp"]) {
        return MessageTypeVideo3GP;
    } else if ([type isEqualToString:@"3g2"]) {
        return MessageTypeVideo3G2;
    } else if ([type isEqualToString:@"avi"]) {
        return MessageTypeVideoAVI;
    } else if ([type isEqualToString:@"wmv"]) {
        return MessageTypeVideoWMV;
    } else if ([type isEqualToString:@"wav"]) {
        return MessageTypeAudioWAV;
    } else if ([type isEqualToString:@"amr"]) {
        return MessageTypeAudioAMR;
    } else if ([type isEqualToString:@"mp3"]) {
        return MessageTypeAudioMP3;
    }
    
    return nil;
}

+ (void)convertVideoFormat:(NSString *)path peerUserName:(NSString *)number completionHandler:(CompletionHandler)completionHandler {
    NSURL* URL = [NSURL fileURLWithPath:path];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:URL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    NSString *outputRelativePath = [self createFilePathWithFileName:[self getFileNameWithType:@"mp4"] folderName:@"video" peerUserName:number];
    NSString *outputFilePath = [self getAbsolutePathWithFileRelativePath:outputRelativePath];
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputFilePath];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status])
        {
            case AVAssetExportSessionStatusFailed:
                completionHandler([exportSession error], outputRelativePath);
                break;
            case AVAssetExportSessionStatusCancelled:
                break;
            case AVAssetExportSessionStatusCompleted:
                completionHandler(nil, outputRelativePath);
                break;
            default:
                break;
        }
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
    }];
}

+ (NSArray *)addressBookRecordsWithRelativePath:(NSString *)path error:(NSError * __autoreleasing *)error {
    NSString *absolutePath = [self getAbsolutePathWithFileRelativePath:path];
    CFErrorRef addressBookError = NULL;
    CFArrayRef people = ABPersonCreatePeopleInSourceWithVCardRepresentation(NULL, (__bridge CFDataRef)[NSData dataWithContentsOfFile:absolutePath]);
    
    if (error) {
        *error = (__bridge_transfer NSError *)addressBookError;
    }
    
    return (__bridge_transfer NSArray *)people;
}

@end
