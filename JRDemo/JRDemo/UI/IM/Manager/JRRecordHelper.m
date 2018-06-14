//
//  JRRecordHelper.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRRecordHelper.h"

@interface JRRecordHelper () <AVAudioRecorderDelegate>

@property (nonatomic, strong) NSURL *recordFileUrl;
@property (nonatomic, copy) NSString *recordRelativePath;
@property (nonatomic, strong) AVAudioSession *session;

@end

@implementation JRRecordHelper

+ (JRRecordHelper *)sharedRecordTool {
    static JRRecordHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[JRRecordHelper alloc] init];
        }
    });
    return instance;
}

- (void)startRecordingWithStartCompleteBlock:(startCompleteBlock)block {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    } else {
        [session setActive:YES error:nil];
    }
    self.session = session;
    
    BOOL result = [self.recorder record];
    if (result && block) {
        block();
    }
}

- (void)stopRecordingWithStopCompleteBlock:(stopCompleteBlock)block {
    if ([self.recorder isRecording]) {
        [self.recorder stop];
        self.recorder = nil;
    }
    if (block) {
        block([self.recordRelativePath copy]);
    }
}

- (void)cancelRecordingWithCancelCompleteBlock:(cancelCompleteBlock)block {
    if ([self.recorder isRecording]) {
        [self.recorder stop];
        [self destructionRecordingFile];
        self.recorder = nil;
    }
    if (block) {
        block();
    }
}

- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        self.recordRelativePath = [JRFileUtil createFilePathWithFileName:[JRFileUtil getFileNameWithType:@"wav"] folderName:@"audio" peerUserName:self.peerNumber];
        NSString *absolutePath = [JRFileUtil getAbsolutePathWithFileRelativePath:self.recordRelativePath];
        self.recordFileUrl = [NSURL fileURLWithPath:absolutePath];
        
        NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithFloat: 4100.0f],AVSampleRateKey,
                                       [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                       [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt:28000],AVEncoderBitRateKey,
                                       [NSNumber numberWithInt: AVAudioQualityHigh],AVEncoderAudioQualityKey,                                       nil];
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        
        [_recorder prepareToRecord];
    }
    return _recorder;
}

- (void)destructionRecordingFile
{
    if (self.recordFileUrl) {
        [[NSFileManager defaultManager] removeItemAtURL:self.recordFileUrl error:NULL];
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        [self.session setActive:NO error:nil];
    }
}

@end
