//
//  JRExVCardLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/7/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRExVCardLayout.h"

@implementation JRExVCardLayout

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName {
    [super configWithMessage:message shouldShowTime:showTime shouldShowName:showName];
    NSMutableString *content = [[NSMutableString alloc] init];;
    NSString *name = JRGetVCardName(message.content);
    NSString *email = JRGetVCardEmail(message.content);
    NSString *company = JRGetVCardCompany(message.content);
    NSString *number = JRGetVCardNumber(message.content);
    NSString *note = JRGetVCardNote(message.content);
    if (name.length) {
        [content appendString:[NSString stringWithFormat:@"姓名:%@\n", name]];
    }
    if (email.length) {
        [content appendString:[NSString stringWithFormat:@"邮箱:%@\n", email]];
    }
    if (company.length) {
        [content appendString:[NSString stringWithFormat:@"公司:%@\n", company]];
    }
    if (number.length) {
        [content appendString:[NSString stringWithFormat:@"号码:%@\n", number]];
    }
    if (note.length) {
        [content appendString:note];
    }
    _vContent = content;
    if (message.contentType == JRTextMessageContentTypeExchangeVCard) {
        if (message.direction == JRMessageItemDirectionSend) {
            _vContentFrame = CGRectMake(0, 0, 200, 200);
            _vShowAccept = NO;
        } else {
            _vContentFrame = CGRectMake(0, 0, 200, 150);
            _vAcceptFrame = CGRectMake(0, 155, 200, 45);
            _vShowAccept = YES;
        }
    } else {
        _vContentFrame = CGRectMake(0, 0, 200, 200);
        _vShowAccept = NO;
    }
}

@end
