//
//  XHBVoiceRecordProgressView.h
//  webox
//
//  Created by weqia on 14-2-24.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XHBVoiceRecordProgressView : UIImageView
{
    UILabel * _label;
    
    UILabel * _timeLabel;
    
    UIImageView * _voiceimage;
    
    UIImageView * _progressLeftImage;

    UIImageView * _progressRightImage;
    
    UIImageView * _cancelImage;
    
    UIImageView * _recordAniamtionLeftImageView;
    
    UIImageView * _recordAniamtionRightImageView;
    
    NSTimer *_timer;
    
    NSDate *_firstFireDate;
}

+(XHBVoiceRecordProgressView*)shareButton;
-(void)setStrength:(int)level;
-(void)show;
-(void)hide;
-(void)willHide;
-(void)reShow;
-(void)recordTimeSmall;
-(void)recordTimeBig;
- (void)setVoiceRecord;


@end
