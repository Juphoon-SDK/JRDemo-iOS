//
//  JRRecordHelper.h
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^startCompleteBlock)(void);
typedef void (^cancelCompleteBlock)(void);
typedef void (^stopCompleteBlock)(NSString *filePath);

@interface JRRecordHelper : NSObject

@property (nonatomic, strong) AVAudioRecorder *recorder;

/**
 对方号码，用来生成路径
 */
@property (nonatomic, copy) NSString *peerNumber;

+ (JRRecordHelper *)sharedRecordTool;

/**
 开始录音

 @param block 代码块
 */
- (void)startRecordingWithStartCompleteBlock:(startCompleteBlock)block;

/**
 取消录音

 @param block 代码块
 */
- (void)cancelRecordingWithCancelCompleteBlock:(cancelCompleteBlock)block;

/**
 结束录音

 @param block 代码块
 */
- (void)stopRecordingWithStopCompleteBlock:(stopCompleteBlock)block;

@end
