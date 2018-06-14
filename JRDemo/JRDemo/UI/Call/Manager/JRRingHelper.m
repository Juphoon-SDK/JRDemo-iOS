//
//  JRRingHelper.m
//  JRDemo
//
//  Created by Ginger on 2018/3/6.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRRingHelper.h"
#import <AVFoundation/AVFoundation.h>

static SystemSoundID _mtcRingSystemSoundID;

static void JRRingAudioServicesSystemSoundCompletionProc(SystemSoundID ssID, void *clientData)
{
    AudioServicesPlayAlertSound(ssID);
}

void JRRingStartRing() {
    CFURLRef fileURL = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"dreamy_piano" withExtension:@"m4r"];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient
                                           error:nil];
    AudioServicesCreateSystemSoundID(fileURL, &_mtcRingSystemSoundID);
    AudioServicesAddSystemSoundCompletion(_mtcRingSystemSoundID, NULL, NULL, JRRingAudioServicesSystemSoundCompletionProc, NULL);
    AudioServicesPlayAlertSound(_mtcRingSystemSoundID);
}

void JRRingStopRing() {
    if (_mtcRingSystemSoundID != 0) {
        AudioServicesRemoveSystemSoundCompletion(_mtcRingSystemSoundID);
        AudioServicesDisposeSystemSoundID(_mtcRingSystemSoundID);
        _mtcRingSystemSoundID = 0;
    }
}
