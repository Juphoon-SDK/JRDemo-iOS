//
//  JRAudioPlayHelper.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAudioPlayHelper.h"

@implementation JRAudioPlayHelper

#pragma mark - action

- (void)stopAudio
{
    self.filePath = nil;
    if (_player && _player.isPlaying) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerDidStopPlay:)])
        {
            [self.delegate audioPlayerDidStopPlay:_player];
        }
        [_player stop];
    }
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)pauseAudio {
    if (_player) {
        [_player pause];
        if ([self.delegate respondsToSelector:@selector(audioPlayerDidPausePlay:)]) {
            [self.delegate audioPlayerDidPausePlay:_player];
        }
    }
}

- (void)playAudioWithFilePath:(NSString *)filePath
{
    if (filePath.length > 0) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                         withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:nil];
        if (_filePath && [_filePath isEqualToString:filePath])
        {
            if (_player) {
                [_player play];
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                if ([self.delegate respondsToSelector:@selector(audioPlayerDidBeginPlay:)]) {
                    [self.delegate audioPlayerDidBeginPlay:_player];
                }
            }
        }
        else
        {
            if (_player)
            {
                [_player stop];
                self.player = nil;
            }
            NSString *wavPath = filePath;
            if ([filePath hasSuffix:@"amr"]) {
                wavPath = [self convertAmrToWav:filePath];
            }
            AVAudioPlayer *pl = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:wavPath] error:nil];
            pl.delegate = self;
            [pl play];
            self.player = pl;
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            if ([self.delegate respondsToSelector:@selector(audioPlayerDidBeginPlay:)]) {
                [self.delegate audioPlayerDidBeginPlay:_player];
            }
        }
        self.filePath = filePath;
    }
}

- (NSString *)convertAmrToWav:(NSString *)amrPath
{
    NSString* fileNoExtension = [amrPath substringToIndex:(amrPath.length-3)];
    NSString* wavPath = [NSString stringWithFormat:@"%@wav",fileNoExtension];
    if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath])
    {
        Mtc_MediaFileAmrToWav((ZCHAR *)[amrPath UTF8String],(ZCHAR *)[wavPath UTF8String]);
    }
    return wavPath;
}

- (BOOL)isPlaying {
    if (!_player) {
        return NO;
    }
    return _player.isPlaying;
}

#pragma mark - Life Cycle

+ (JRAudioPlayHelper *)shareInstance {
    static JRAudioPlayHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JRAudioPlayHelper alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self changeProximityMonitorEnableState:YES];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    return self;
}

- (void)dealloc
{
    [self changeProximityMonitorEnableState:NO];
}

- (void)setDelegate:(id<AudioPlayerHelperDelegate>)delegate
{
    if (_delegate && [_delegate respondsToSelector:@selector(audioPlayerDidStopPlay:)])
    {
        [_delegate audioPlayerDidStopPlay:_player];
    }
    _delegate = delegate;
}

#pragma mark - audio delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudio];
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidStopPlay:)])
    {
        [self.delegate audioPlayerDidStopPlay:_player];
    }
}

#pragma mark - 近距离传感器

- (void)changeProximityMonitorEnableState:(BOOL)enable {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        if (enable) {
            
            //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
            
        } else {
            
            //删除近距离事件监听
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

- (void)sensorStateChange:(NSNotificationCenter *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        //黑屏
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    } else {
        //没黑屏幕
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_player || !_player.isPlaying) {
            //没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

@end
