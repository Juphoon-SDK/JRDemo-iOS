//
//  XHBVoiceRecordButton.m
//  webox
//
//  Created by weqia on 14-2-24.
//  Copyright (c) 2014年 xhb. All rights reserved.
//

#import "XHBVoiceRecordButton.h"

@interface XHBVoiceRecordButton ()

@property (nonatomic,strong) UILabel *styleView;
@property (nonatomic,assign) CGRect viewFrame;

@end

@implementation XHBVoiceRecordButton

#pragma -mark 接口

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.viewFrame = frame;
    _styleView.frame = CGRectMake(0, 0, self.viewFrame.size.width, self.viewFrame.size.height);
    [self initView];
}

- (id)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame])
    {
        self.viewFrame = frame;
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.styleView.text = NSLocalizedString(@"RECORD_TIPS", nil);
    self.styleView.textColor = [JRSettings skinColor];
    self.styleView.font = [UIFont systemFontOfSize:16];
    self.styleView.backgroundColor = [UIColor clearColor];
    self.styleView.layer.cornerRadius = 7;
    self.styleView.layer.borderWidth = 0.3;
    self.styleView.layer.masksToBounds = YES;
    self.styleView.userInteractionEnabled = NO;
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    self.normalBorderColor = [UIColor grayColor];
}


- (UILabel *)styleView
{
    if (!_styleView) {
        _styleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewFrame.size.width, self.viewFrame.size.height)];
        _styleView.userInteractionEnabled = NO;
        _styleView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_styleView];
    }
    return _styleView;
}

#pragma mark - 手势处理

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isRecord) {
        _second=0;
        _time = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
        _isRecord=YES;
        _cancel=NO;
        self.styleView.text = NSLocalizedString(@"RECORD_COMPLETE", nil);
        self.styleView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:0.9];
        self.styleView.layer.borderColor = self.normalBorderColor.CGColor;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordBeginRecord:)])
        {
            [self.delegate voiceRecordBeginRecord:self];
        }
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isRecord)
        return;
    
    _isRecord=NO;
    if (_cancel) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordCancelRecord:)]) {
            [self.delegate voiceRecordCancelRecord:self];
        }
        self.styleView.text = NSLocalizedString(@"RECORD_TIPS", nil);
        self.styleView.backgroundColor = [UIColor clearColor];
        self.styleView.layer.borderColor = self.normalBorderColor.CGColor;
    }else{
        if (_second<=1) {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordRecordTimeSmall:)])
            {
                [self.delegate voiceRecordRecordTimeSmall:self];
            }
            double delayInSeconds = 2.0;
            self.userInteractionEnabled=NO;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.userInteractionEnabled=YES;
                self.styleView.text = NSLocalizedString(@"RECORD_TIPS", nil);
                self.styleView.backgroundColor=[UIColor clearColor];
                self.styleView.layer.borderColor = self.normalBorderColor.CGColor;
            });
        }
        else
        {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordEndRecord:timeDuration:)])
            {
                [self.delegate voiceRecordEndRecord:self timeDuration:_second];
            }
            self.styleView.text = NSLocalizedString(@"RECORD_TIPS", nil);
            self.styleView.backgroundColor=[UIColor clearColor];
            self.styleView.layer.borderColor = self.normalBorderColor.CGColor;
        }
    }
    [_time invalidate];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouch];
}

- (void)endTouch
{
    if (!_isRecord)
        return;
    
    _isRecord=NO;
    if (_cancel) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordCancelRecord:)]) {
            [self.delegate voiceRecordCancelRecord:self];
        }
        self.styleView.text = NSLocalizedString(@"RECORD_TIPS", nil);
        self.styleView.backgroundColor=[UIColor clearColor];
        self.styleView.layer.borderColor = self.normalBorderColor.CGColor;
    }else{
        if (_second<=1) {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordRecordTimeSmall:)]) {
                [self.delegate voiceRecordRecordTimeSmall:self];
            }
            double delayInSeconds = 2.0;
            self.userInteractionEnabled=NO;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.userInteractionEnabled=YES;
                self.styleView.text = NSLocalizedString(@"RECORD_TIPS", nil);
                self.styleView.backgroundColor=[UIColor clearColor];
                self.styleView.layer.borderColor = self.normalBorderColor.CGColor;
            });
        }
        else if (_second >=60)
        {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordRecordTimeBig:)])
            {
                [self.delegate voiceRecordRecordTimeBig:self];
            }
            double delayInSeconds = 2.0;
            self.userInteractionEnabled = NO;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.userInteractionEnabled=YES;
                self.styleView.text = NSLocalizedString(@"RECORD_TIPS", nil);
                self.styleView.backgroundColor=[UIColor clearColor];
                self.styleView.layer.borderColor = self.normalBorderColor.CGColor;
            });
            [_time invalidate];
        }
        else{
            if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordEndRecord:timeDuration:)])
            {
                [self.delegate voiceRecordEndRecord:self timeDuration:_second];
            }
            self.styleView.text = NSLocalizedString(@"RECORD_TIPS", nil);
            self.styleView.backgroundColor=[UIColor clearColor];
            self.styleView.layer.borderColor = self.normalBorderColor.CGColor;
        }
    }
    [_time invalidate];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.x<0||point.y<0||point.x>self.frame.size.width||point.y>self.frame.size.height) {
        if (_cancel==NO) {
            _cancel=YES;
            if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordWillCancelRecord:)])
            {
                [self.delegate voiceRecordWillCancelRecord:self];
            }
        }
    }else{
        if (_cancel) {
            _cancel=NO;
            if (self.delegate&&[self.delegate respondsToSelector:@selector(voiceRecordContinueRecord:)])
            {
                [self.delegate voiceRecordContinueRecord:self];
            }
        }
    }
}

-(void)timeAction
{
    _second++;
    
    if (_second > 59)
    {
        [self endTouch];
    }
}

@end
