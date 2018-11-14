//
//  JRExVCardMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/7/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRExVCardMessageCell.h"
#import "JRExVCardLayout.h"

@implementation JRExVCardMessageCell

- (void)configWithLayout:(JRBaseBubbleLayout *)layout {
    [super configWithLayout:layout];
    if (!_vTextView) {
        _vTextView = [[UITextView alloc] init];
        _vTextView.font = [UIFont systemFontOfSize:17];
        _vTextView.editable = false;
        [self.msgContentView addSubview:_vTextView];
    }
    if (!_vAcceptButton) {
        _vAcceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_vAcceptButton setTitleColor:[JRSettings skinColor] forState:UIControlStateNormal];
        [_vAcceptButton addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
        [_vAcceptButton setTitle:@"同意交换" forState:UIControlStateNormal];
        _vAcceptButton.layer.borderColor = [JRSettings skinColor].CGColor;
        _vAcceptButton.layer.borderWidth = 1.0;
        [self.msgContentView addSubview:_vAcceptButton];
    }
    
    self.msgContentView.layer.borderColor = [JRSettings skinColor].CGColor;
    self.msgContentView.layer.borderWidth = 1.0;
    
    JRExVCardLayout *tempLayout = (JRExVCardLayout *)layout;
    _vTextView.text = tempLayout.vContent;
    _vAcceptButton.hidden = !tempLayout.vShowAccept;
}

- (void)accept {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:acceptExchangeVCard:)]) {
        [self.delegate tableView:self.wTableView acceptExchangeVCard:self.layout.message];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    JRExVCardLayout *tempLayout = (JRExVCardLayout *)self.layout;
    _vTextView.frame = tempLayout.vContentFrame;
    _vAcceptButton.frame = tempLayout.vAcceptFrame;
}

@end
