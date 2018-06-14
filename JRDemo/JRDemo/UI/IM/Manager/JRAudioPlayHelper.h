//
//  JRAudioPlayHelper.h
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 代理
 */
@protocol AudioPlayerHelperDelegate <NSObject>

@optional

/**
 开始播放
 */
- (void)audioPlayerDidBeginPlay:(AVAudioPlayer *)audioPlayer;

/**
 播放结束
 */
- (void)audioPlayerDidStopPlay:(AVAudioPlayer *)audioPlayer;

/**
 暂停播放
 */
- (void)audioPlayerDidPausePlay:(AVAudioPlayer *)audioPlayer;

@end

@interface JRAudioPlayHelper : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;

/**
 绝对路径
 */
@property (nonatomic, copy) NSString *filePath;

/**
 是否正在播放
 */
@property (nonatomic, assign) BOOL isPlaying;

/**
 代理
 */
@property (nonatomic, weak) id <AudioPlayerHelperDelegate> delegate;

+ (JRAudioPlayHelper *)shareInstance;

/**
 播放音频

 @param filePath 绝对路径
 */
- (void)playAudioWithFilePath:(NSString *)filePath;

/**
 结束播放
 */
- (void)stopAudio;

/**
 暂停播放
 */
- (void)pauseAudio;

@end
