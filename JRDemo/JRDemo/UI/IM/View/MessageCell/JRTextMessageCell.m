//
//  JRTextMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRTextMessageCell.h"
#import "JRTextLayout.h"

@implementation JRTextMessageCell

#pragma mark - Copying Method

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.layout.message.type == JRMessageItemTypeText) {
        return action == @selector(copy:);
    }
    return NO;
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.layout.message.content];
}

- (void)configWithLayout:(JRBaseBubbleLayout *)layout
{
    [super configWithLayout:layout];
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = TextFont;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.userInteractionEnabled = YES;
        [_contentLabel addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setupNormalMenuController:)]];
        [self.msgContentView addSubview:_contentLabel];
    }
    _contentLabel.text = ((JRTextLayout *)layout).contentLabelText;
}

- (void)setupNormalMenuController:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [super becomeFirstResponder];
        CGRect selectedCellMessageBubbleFrame = [self convertRect:self.bubbleView.frame toView:self.bubbleView];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:selectedCellMessageBubbleFrame inView:self.bubbleView];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _contentLabel.textColor = ((JRTextLayout *)self.layout).contentLabelTextColor;
    _contentLabel.frame = ((JRTextLayout *)self.layout).contentLabelFrame;
}

@end
