//
//  JRRevokeLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/7/20.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRRevokeLayout.h"
#import "MHPrettyDate.h"
#import "JRGroupDBManager.h"

@implementation JRRevokeLayout

- (void)configWithMessage:(JRMessageObject *)message
{
    self.message = message;
    self.imdnId = message.imdnId;
    
    if (message.direction == JRMessageItemDirectionSend) {
        _revokeHintLabelText = @"消息已撤回";
    } else {
        if (message.groupChatId.length) {
            JRGroupMemberObject *member = [JRGroupDBManager getGroupMemberWithIdentity:message.peerNumber number:message.senderNumber];
            _revokeHintLabelText = [NSString stringWithFormat:@"%@ 撤回一条消息", member.displayName.length ? member.displayName : member.number];
        } else {
            _revokeHintLabelText = @"对方已撤回";
        }
    }
    _revokeHintLabelColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:0.3];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : RevokeTextFont,
                                 };
    CGSize contetSize = [_revokeHintLabelText boundingRectWithSize:CGSizeMake(RevokeContentLabelMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    CGFloat centerY = RevokeMargin + contetSize.height/2 + RevokeBubbleMargin;
    CGSize size = CGSizeMake(contetSize.width+2*RevokeBubbleMargin, contetSize.height+2*RevokeBubbleMargin);
    CGPoint center = CGPointMake(RevokeCellWidth/2, centerY);
    
    _revokeHintLabelFrame = CGRectMake(center.x-size.width/2, center.y-size.height/2, size.width, size.height);
}

- (CGFloat)calculateCellHeight
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : RevokeTextFont,
                                 };
    CGSize contetSize = [_revokeHintLabelText boundingRectWithSize:CGSizeMake(RevokeContentLabelMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return contetSize.height + 2*RevokeMargin + 2*RevokeBubbleMargin;
}

@end
