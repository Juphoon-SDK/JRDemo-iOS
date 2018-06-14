//
//  XHBVoiceRecordButton.h
//  webox
//
//  Created by weqia on 14-2-24.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHBVoiceRecordButton;
@protocol XHBVoiceRecordButtonDelegate <NSObject>

-(void)voiceRecordBeginRecord:(XHBVoiceRecordButton*)button;
-(void)voiceRecordEndRecord:(XHBVoiceRecordButton *)button timeDuration:(int)duration;
-(void)voiceRecordCancelRecord:(XHBVoiceRecordButton *)button;
-(void)voiceRecordContinueRecord:(XHBVoiceRecordButton *)button;
-(void)voiceRecordWillCancelRecord:(XHBVoiceRecordButton *)button;
-(void)voiceRecordRecordTimeSmall:(XHBVoiceRecordButton *)button;
-(void)voiceRecordRecordTimeBig:(XHBVoiceRecordButton *)button;

@end

@interface XHBVoiceRecordButton : UIView
{    
    BOOL _isRecord;
    
    BOOL _cancel;
    
    NSTimer * _time;
    
    int _second;
}
@property(nonatomic,assign) id<XHBVoiceRecordButtonDelegate> delegate;

@property (nonatomic, strong) UIColor *normalBorderColor;

@end
