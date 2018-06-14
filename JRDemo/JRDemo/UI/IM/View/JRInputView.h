//
//  JRInputView.h
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHBVoiceRecordButton.h"

#define InputHeadViewHeight 90
#define InputMenuViewHeight 216

#define placeHolderLableColor [[UIColor alloc] initWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1]
#define kInputViewMaxHeight 60
#define kKeyboardX 5

@protocol JRInputViewDelegate <NSObject>
@optional

- (void)didBeginEditing;

- (void)sendMessage:(NSString *)message;

- (void)menuViewShow;
- (void)menuViewHide;

- (void)photoBtnClicked;
- (void)cameraBtnClicked;
- (void)locationBtnClicked;
- (void)cardBtnClicked;
- (void)otherFilesBtnClicked;

- (void)didVoiceRecordBeginRecord:(XHBVoiceRecordButton*)button;
- (void)didVoiceRecordEndRecord:(XHBVoiceRecordButton *)button timeDuration:(int)duration;
- (void)didVoiceRecordCancelRecord:(XHBVoiceRecordButton *)button;
- (void)didVoiceRecordContinueRecord:(XHBVoiceRecordButton *)button;
- (void)didVoiceRecordWillCancelRecord:(XHBVoiceRecordButton *)button;
- (void)didVoiceRecordRecordTimeSmall:(XHBVoiceRecordButton *)button;
- (void)didVoiceRecordRecordTimeBig:(XHBVoiceRecordButton *)button;

@end

@interface JRInputView : UIView

@property (nonatomic, weak) id<JRInputViewDelegate> delegate;
@property (nonatomic, assign) CGFloat headHeight;
@property (nonatomic, assign) BOOL isMenuViewShow;

@end
