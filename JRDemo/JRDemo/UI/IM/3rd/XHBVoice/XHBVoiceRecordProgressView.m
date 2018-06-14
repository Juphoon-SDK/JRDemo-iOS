
//
//  XHBVoiceRecordProgressView.m
//  webox
//
//  Created by weqia on 14-2-24.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

#import "XHBVoiceRecordProgressView.h"
#define VoiceRecordBackgroundColor [UIColor colorWithRed:73.0f/255.0f green:103.0f/255.0f blue:122.0f/255.0f alpha:0.9f]
#define VoiceRecordDeleteBackgroundColor [UIColor colorWithRed:255.0f/255.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:0.9f]

@implementation XHBVoiceRecordProgressView

#pragma -mark 接口
+(XHBVoiceRecordProgressView*)shareButton
{
    static XHBVoiceRecordProgressView * view=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view=[[self alloc]initView];
    });
    return view;
}
-(void)show
{
    self.backgroundColor = VoiceRecordBackgroundColor;
    
    [self startTimer];
    _firstFireDate = [NSDate date];
    
    _timeLabel.text = @"0:00";
    _timeLabel.hidden = NO;
    _label.hidden = NO;
    _label.text = @"上滑取消";
    
    _cancelImage.hidden=YES;
    _voiceimage.hidden=NO;
    _progressLeftImage.hidden = NO;
    _progressRightImage.hidden = NO;
    [_progressLeftImage startAnimating];
    [_progressRightImage startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
-(void)hide
{
    [_progressLeftImage stopAnimating];
    [_progressRightImage stopAnimating];
    [self stopTimer];
    [self removeFromSuperview];
}

-(void)willHide
{
    self.backgroundColor = VoiceRecordDeleteBackgroundColor;
    
    _timeLabel.hidden = YES;
    _label.hidden = NO;
    _label.text=@"松开手指取消发送";
    
    _cancelImage.hidden=NO;
    _voiceimage.hidden=YES;
    _progressLeftImage.hidden = YES;
    _progressRightImage.hidden = YES;
}

-(void)reShow
{
    self.backgroundColor = VoiceRecordBackgroundColor;
    
    _timeLabel.hidden = NO;
    _label.hidden = NO;
    _label.text= @"上滑取消";
    
    _cancelImage.hidden=YES;
    _voiceimage.hidden=NO;
    _progressLeftImage.hidden = NO;
    _progressRightImage.hidden = NO;
}

-(void)recordTimeSmall
{
    self.backgroundColor = VoiceRecordBackgroundColor;
    
    [self stopTimer];
    _timeLabel.hidden = NO;
    _timeLabel.text = @"说话时间太短";
    _label.hidden = YES;
    
    _cancelImage.hidden = YES;
    _voiceimage.hidden = NO;
    _progressLeftImage.hidden = NO;
    _progressRightImage.hidden = NO;
    [_progressLeftImage stopAnimating];
    [_progressRightImage stopAnimating];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hide];
    });
}

-(void)recordTimeBig
{
    self.backgroundColor = VoiceRecordBackgroundColor;
    
    [self stopTimer];
    _timeLabel.hidden = NO;
    _timeLabel.text = @"说话时间太长";
    _label.hidden = YES;
    
    _cancelImage.hidden=YES;
    _voiceimage.hidden=NO;
    _progressLeftImage.hidden = NO;
    _progressRightImage.hidden = NO;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hide];
    });
}

//no affected,progress according to volumn
-(void)setStrength:(int)level
{
    if (level>3)
    {
        level=3;
    }
    NSString *fileLeftName= [NSString stringWithFormat:@"ic-audio-animation-left-%d",level];
    NSString *fileRightName= [NSString stringWithFormat:@"ic-audio-animation-right-%d",level];
    
    _progressLeftImage.image=[UIImage imageNamed:fileLeftName];
    _progressRightImage.image=[UIImage imageNamed:fileRightName];
}

#pragma  -mark 私有
-(id)initView
{
    self=[super init];
    if (self)
    {
        self.frame=CGRectMake(([UIScreen mainScreen].bounds.size.width-160)/2,([UIScreen mainScreen].bounds.size.height-160)/2, 160, 160);
        self.layer.cornerRadius = 13;
        
        _voiceimage=[[UIImageView alloc]initWithFrame:CGRectMake(60, 25, 40, 63)];
        [self addSubview:_voiceimage];
        
        _cancelImage=[[UIImageView alloc]initWithFrame:CGRectMake(60, 43, 40, 63)];
        _cancelImage.image = [UIImage imageNamed:@"ic-audio-delete"];
        [self addSubview:_cancelImage];
        _cancelImage.hidden=YES;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 109, 160, 22)];
        _timeLabel.textColor=[UIColor whiteColor];
        _timeLabel.font=[UIFont systemFontOfSize:16];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
        
        _label=[[UILabel alloc]initWithFrame:CGRectMake(0, 135, 160, 22)];
        _label.text=@"上滑取消";
        _label.textColor=[UIColor whiteColor];
        _label.font=[UIFont systemFontOfSize:12];
        _label.textAlignment=NSTextAlignmentCenter;
        _label.backgroundColor=[UIColor clearColor];
        [self addSubview:_label];
        
        _progressLeftImage=[[UIImageView alloc]initWithFrame:CGRectMake(15, 25, 40, 63)];
        _progressLeftImage.animationDuration = 1.0;
        _progressLeftImage.animationRepeatCount = 0;
        [self addSubview:_progressLeftImage];
        
        _progressRightImage=[[UIImageView alloc]initWithFrame:CGRectMake(105, 25, 40, 63)];
        _progressRightImage.animationDuration = 1.0;
        _progressRightImage.animationRepeatCount = 0;
        [self addSubview:_progressRightImage];
    }
    return self;
}

- (void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if (_timer != nil) {
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

- (void)updateTimer:(NSTimer *)timer{
    NSInteger deltaTime = [timer.fireDate timeIntervalSinceDate:_firstFireDate]+1;
    
    NSString *time;
    if (deltaTime < 10) {
        time = [NSString stringWithFormat:@"0:0%ld",(long)deltaTime];
    }
    else if (deltaTime < 60){
        time = [NSString stringWithFormat:@"0:%ld",(long)deltaTime];
    }
    else{
        NSInteger minute = deltaTime/60;
        NSInteger second = deltaTime - minute*60;
        if (second < 10) {
            time = [NSString stringWithFormat:@"%ld:0%ld",(long)minute,(long)second];
        } else {
            time = [NSString stringWithFormat:@"%ld:%ld",(long)minute,(long)second];
        }
    }
    _timeLabel.text = time;
}

-(void)setVoiceRecord
{
    self.backgroundColor = VoiceRecordBackgroundColor;
    _voiceimage.image=[UIImage imageNamed:@"ic-audio-record"];
    NSMutableArray *leftImages = [NSMutableArray arrayWithCapacity:4];
    NSMutableArray *rightImages = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger i = 0; i < 4; i++) {
        NSString *fileLeftName= [NSString stringWithFormat:@"ic-audio-animation-left-%ld",(long)i];
        NSString *fileRightName= [NSString stringWithFormat:@"ic-audio-animation-right-%ld",(long)i];
        UIImage *leftImage = [UIImage imageNamed:fileLeftName];
        UIImage *rightImage = [UIImage imageNamed:fileRightName];
        [leftImages addObject:leftImage];
        [rightImages addObject:rightImage];
    }
    _progressLeftImage.image = [UIImage imageNamed:@"ic-audio-animation-left-3"];
    _progressLeftImage.animationImages = leftImages;
    _progressRightImage.image = [UIImage imageNamed:@"ic-audio-animation-right-3"];
    _progressRightImage.animationImages = rightImages;
}

@end
