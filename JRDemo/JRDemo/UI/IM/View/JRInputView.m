//
//  JRInputView.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRInputView.h"
#import "HBEmojiPageView.h"

@interface JRInputView () <UITextViewDelegate, XHBVoiceRecordButtonDelegate, HBEmojiPageViewDelegate>

@property (nonatomic, strong) UITextView *inputView;
@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) UIButton *audioBtn;
@property (nonatomic, strong) UIButton *emojiBtn;
@property (nonatomic, strong) XHBVoiceRecordButton *recordBtn;

@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *cardBtn;
@property (nonatomic, strong) UIButton *otherFileBtn;

@property (nonatomic, assign) BOOL isFirstLayout;
@property (nonatomic, assign) CGFloat inputViewHeight;

@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) HBEmojiPageView *emojiPageView;

@end

@implementation JRInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepareLayout];
        self.isFirstLayout = YES;
        self.isMenuViewShow = NO;
        self.headHeight = InputHeadViewHeight;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)prepareLayout {
    if (!_inputView) {
        _inputView = [[UITextView alloc] init];
        _inputView.returnKeyType = UIReturnKeySend;
        _inputView.showsVerticalScrollIndicator = NO;
        _inputView.scrollEnabled = NO;
        _inputView.delegate = self;
        _inputView.font = [UIFont systemFontOfSize:16];
        _inputView.backgroundColor = [UIColor whiteColor];
        _inputView.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1];
        _inputView.layer.masksToBounds = YES;
        _inputView.layer.cornerRadius = 7;
        [self addSubview:_inputView];
    }
    if (!_placeHolderLabel) {
        _placeHolderLabel = [[UILabel alloc] init];
        _placeHolderLabel.adjustsFontSizeToFitWidth = YES;
        _placeHolderLabel.font = [UIFont systemFontOfSize:16];
        _placeHolderLabel.minimumScaleFactor = 0.9;
        _placeHolderLabel.textColor = placeHolderLableColor;
        _placeHolderLabel.userInteractionEnabled = NO;
        _placeHolderLabel.text = NSLocalizedString(@"INPUT_SOMETHING", nil);
        [self addSubview:self.placeHolderLabel];
    }
    if (!_audioBtn) {
        _audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioBtn setImage:[UIImage imageNamed:@"btn_voice_nor"] forState:UIControlStateNormal];
        [_audioBtn setImage:[UIImage imageNamed:@"btn_voice_pre"] forState:UIControlStateHighlighted];
        [_audioBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_audioBtn];
    }
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiBtn setImage:[UIImage imageNamed:@"btn_smile_nor"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"btn_smile_pre"] forState:UIControlStateHighlighted];
        [_emojiBtn addTarget:self action:@selector(showEmoji) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_emojiBtn];
    }
    if (!_recordBtn) {
        _recordBtn = [[XHBVoiceRecordButton alloc] initWithFrame:CGRectZero];
        _recordBtn.delegate = self;
        _recordBtn.hidden = YES;
        [self addSubview:_recordBtn];
    }
    if (!_locationBtn) {
        _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationBtn setImage:[UIImage imageNamed:@"message_location"] forState:UIControlStateNormal];
        [_locationBtn addTarget:self action:@selector(showLacation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_locationBtn];
    }
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoBtn setImage:[UIImage imageNamed:@"message_photo"] forState:UIControlStateNormal];
        [_photoBtn addTarget:self action:@selector(showPhotos) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_photoBtn];
    }
    if (!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraBtn setImage:[UIImage imageNamed:@"message_camera"] forState:UIControlStateNormal];
        [_cameraBtn addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cameraBtn];
    }
    if (!_cardBtn) {
        _cardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cardBtn setImage:[UIImage imageNamed:@"message_card"] forState:UIControlStateNormal];
        [_cardBtn addTarget:self action:@selector(showContacts) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cardBtn];
    }
    if (!_otherFileBtn) {
        _otherFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherFileBtn setImage:[UIImage imageNamed:@"message_file"] forState:UIControlStateNormal];
        [_otherFileBtn addTarget:self action:@selector(showOtherFiles) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_otherFileBtn];
    }
    if (!_menuView) {
        _menuView = [[UIView alloc] init];
        _menuView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_menuView];
    }
    if (!_emojiPageView) {
        _emojiPageView = [[HBEmojiPageView alloc] initWithFrame:CGRectZero];
        _emojiPageView.hidden = YES;
        _emojiPageView.delegate = self;
        _emojiPageView.frame = CGRectZero;
        [_menuView addSubview:_emojiPageView];
    }
}

#pragma mark - Button Action

- (void)startRecord {
    _recordBtn.hidden = !_recordBtn.hidden;
    _inputView.hidden = !_recordBtn.hidden;
    _placeHolderLabel.hidden = !(_recordBtn.hidden && _inputView.text.length == 0);
    if (!_recordBtn.hidden) {
        [_audioBtn setImage:[UIImage imageNamed:@"textNor"] forState:UIControlStateNormal];
        [_audioBtn setImage:[UIImage imageNamed:@"textPre"] forState:UIControlStateHighlighted];
        if ([_inputView isFirstResponder]) {
            [_inputView resignFirstResponder];
        }
        if (_isMenuViewShow) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(menuViewHide)]) {
                [self.delegate menuViewHide];
            }
        }
    } else {
        [_audioBtn setImage:[UIImage imageNamed:@"btn_voice_nor"] forState:UIControlStateNormal];
        [_audioBtn setImage:[UIImage imageNamed:@"btn_voice_pre"] forState:UIControlStateHighlighted];
    }
}

- (void)showEmoji {
    if ([_inputView isFirstResponder]) {
        [_inputView resignFirstResponder];
    }
    if (_isMenuViewShow) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(menuViewHide)]) {
            [self.delegate menuViewHide];
            _emojiPageView.hidden = YES;
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(menuViewShow)]) {
            [self.delegate menuViewShow];
            _emojiPageView.hidden = NO;
            if (!_recordBtn.hidden) {
                _recordBtn.hidden = YES;
                _inputView.hidden = NO;
                _placeHolderLabel.hidden = _inputView.text.length>0;
                [_audioBtn setImage:[UIImage imageNamed:@"btn_voice_nor"] forState:UIControlStateNormal];
                [_audioBtn setImage:[UIImage imageNamed:@"btn_voice_pre"] forState:UIControlStateHighlighted];
            }
        }
    }
}

- (void)showLacation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationBtnClicked)]) {
        [self.delegate locationBtnClicked];
    }
}

- (void)showPhotos {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBtnClicked)]) {
        [self.delegate photoBtnClicked];
    }
}

- (void)showCamera {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraBtnClicked)]) {
        [self.delegate cameraBtnClicked];
    }
}

- (void)showContacts {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardBtnClicked)]) {
        [self.delegate cardBtnClicked];
    }
}

- (void)showOtherFiles {
    if (self.delegate && [self.delegate respondsToSelector:@selector(otherFilesBtnClicked)]) {
        [self.delegate otherFilesBtnClicked];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_isFirstLayout) {
        _inputViewHeight = InputHeadViewHeight-9-46;
        _isFirstLayout = NO;
    }
    
    _audioBtn.frame = CGRectMake(4, self.frame.size.height-InputMenuViewHeight-48-30, 30, 30);
    _inputView.frame = CGRectMake(CGRectGetMaxX(_audioBtn.frame)+8, 9, self.frame.size.width-(CGRectGetMaxX(_audioBtn.frame)+8+6+11+30), self.frame.size.height-InputMenuViewHeight-9-46);
    _placeHolderLabel.frame = CGRectMake(CGRectGetMinX(_inputView.frame)+kKeyboardX, 9, CGRectGetWidth(_inputView.frame), CGRectGetHeight(_inputView.frame));
    _recordBtn.frame = _inputView.frame;
    _emojiBtn.frame = CGRectMake(CGRectGetMaxX(_inputView.frame)+11, _audioBtn.frame.origin.y, 30, 30);
    _menuView.frame = CGRectMake(0, self.frame.size.height-InputMenuViewHeight, self.frame.size.width, InputMenuViewHeight);
    _emojiPageView.frame = CGRectMake(0, 0, self.frame.size.width, InputMenuViewHeight);
    
    CGFloat margin = (self.frame.size.width-40*5)/6.0f;
    _photoBtn.frame = CGRectMake(margin, CGRectGetMaxY(_inputView.frame)+3, 40, 40);
    _cameraBtn.frame = CGRectMake(CGRectGetMaxX(_photoBtn.frame)+margin, CGRectGetMinY(_photoBtn.frame), 40, 40);
    _locationBtn.frame = CGRectMake(CGRectGetMaxX(_cameraBtn.frame)+margin, CGRectGetMinY(_cameraBtn.frame), 40, 40);
    _cardBtn.frame = CGRectMake(CGRectGetMaxX(_locationBtn.frame)+margin, CGRectGetMinY(_locationBtn.frame), 40, 40);
    _otherFileBtn.frame = CGRectMake(CGRectGetMaxX(_cardBtn.frame)+margin, CGRectGetMinY(_cardBtn.frame), 40, 40);
}

- (void)layout {
    _placeHolderLabel.hidden = _inputView.text.length > 0 ? YES : NO;
    CGSize textSize = [_inputView sizeThatFits:CGSizeMake(CGRectGetWidth(_inputView.frame), MAXFLOAT)];
    CGFloat offset = 10;
    _inputView.scrollEnabled = (textSize.height > kInputViewMaxHeight - offset);
    
    CGRect inputFrame = _inputView.frame;
    inputFrame.size.height = MAX(_inputViewHeight, MIN(kInputViewMaxHeight, textSize.height));
    _inputView.frame = inputFrame;
    
    CGFloat maxY = CGRectGetMaxY(self.frame);
    
    CGRect frame = self.frame;
    frame.size.height = CGRectGetHeight(_inputView.frame)+9+46+InputMenuViewHeight;
    frame.origin.y = maxY-CGRectGetHeight(frame);
    self.frame = frame;
    
    _headHeight = self.frame.size.height - InputMenuViewHeight;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBStrokeColor(context, 244.0f/255.0f, 74.0f/255.0f, 79.0f/255.0f, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 5, 0);
    CGContextAddLineToPoint(context, self.frame.size.width-10, 0);
    CGContextStrokePath(context);
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self layout];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _isMenuViewShow = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didBeginEditing)]) {
        [self.delegate didBeginEditing];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        // 点击系统键盘上的发送
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendMessage:)]) {
            [self.delegate sendMessage:textView.text];
            textView.text = nil;
            [self layout];
        }
        return NO;
    }
    return YES;
}

#pragma mark - XHBRecordButtonDelegate

- (void)voiceRecordBeginRecord:(XHBVoiceRecordButton*)button {
    [self.delegate didVoiceRecordBeginRecord:button];
}

- (void)voiceRecordEndRecord:(XHBVoiceRecordButton *)button timeDuration:(int)duration {
    [self.delegate didVoiceRecordEndRecord:button timeDuration:duration];
}

- (void)voiceRecordCancelRecord:(XHBVoiceRecordButton *)button {
    [self.delegate didVoiceRecordCancelRecord:button];
}

- (void)voiceRecordContinueRecord:(XHBVoiceRecordButton *)button {
    [self.delegate didVoiceRecordContinueRecord:button];
}

- (void)voiceRecordWillCancelRecord:(XHBVoiceRecordButton *)button {
    [self.delegate didVoiceRecordWillCancelRecord:button];
}

- (void)voiceRecordRecordTimeSmall:(XHBVoiceRecordButton *)button {
    [self.delegate didVoiceRecordRecordTimeSmall:button];
}

- (void)voiceRecordRecordTimeBig:(XHBVoiceRecordButton *)button {
    [self.delegate didVoiceRecordRecordTimeBig:button];
}

#pragma mark - HBEmotion Delegate

- (void)emojiPageView:(HBEmojiPageView*)emojiPageView  iconClick:(NSString*)iconString {
    NSMutableString *faceString = [[NSMutableString alloc]initWithString:_inputView.text];
    [faceString appendString:iconString];
    _inputView.text = faceString;
    [self layout];
    [_inputView scrollRangeToVisible:NSMakeRange(_inputView.text.length - 1, 1)];
}

- (void)emojiPageViewDeleteClick:(HBEmojiPageView*)emojiPageView actionBlock:(NSString*(^)(NSString* string))block {
    _inputView.text = block(_inputView.text);
    [self layout];
}

- (void)emojiPageViewSendClick:(HBEmojiPageView *)emojiPageView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendMessage:)]) {
        [self.delegate sendMessage:_inputView.text];
        _inputView.text = nil;
        [self layout];
    }
}

@end
