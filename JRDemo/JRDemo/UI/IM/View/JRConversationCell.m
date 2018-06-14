//
//  JRConversationCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRConversationCell.h"
#import "MHPrettyDate.h"
#import "JRGroupDBManager.h"

@implementation JRConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configWithConversation:(JRConversationObject *)conversation {
    if (conversation.isGroup) {
        self.iconView.image = [UIImage imageNamed:@"avatar_group"];
        self.titleLabel.text = [JRGroupDBManager getGroupWithIdentity:conversation.peerNumber].name;
    } else {
        self.iconView.image = [UIImage imageNamed:@"img_greenman_nor"];
        self.titleLabel.text = conversation.peerNumber;
    }

    self.contentLabel.text = [self contentWithMessage:[conversation getLastMessage]];
    self.unreadLabel.text = [NSString stringWithFormat:@"%ld", (long)[conversation getUnreadCount]];
    self.unreadLabel.hidden = ![conversation getUnreadCount];
    self.timeLabel.text = [MHPrettyDate prettyDateFromDate:[NSDate dateWithTimeIntervalSince1970:[conversation.updateTime longLongValue]/1000] withFormat:MHPrettyDateFormatTodayTimeOnly];
    
    self.unreadLabel.layer.cornerRadius = 10;
    self.unreadLabel.clipsToBounds = YES;
}

- (NSString *)contentWithMessage:(JRMessageObject *)message {
    NSString *pre = @"";
    if (message.channelType == JRMessageChannelTypeGroup) {
        JRGroupMemberObject *member = [JRGroupDBManager getGroupMemberWithIdentity:message.peerNumber number:message.senderNumber];
        if (member.displayName.length) {
            pre = [NSString stringWithFormat:@"%@:", member.displayName];
        } else {
            pre = [NSString stringWithFormat:@"%@:", message.senderNumber];
        }
    }
    switch (message.type) {
        case JRMessageItemTypeUnknow:
            return [NSString stringWithFormat:@"%@%@", pre, NSLocalizedString(@"MESSAGE_UNKNOW", nil)];
        case JRMessageItemTypeGeo:
            return [NSString stringWithFormat:@"%@%@", pre, NSLocalizedString(@"MESSAGE_LOCATION", nil)];
        case JRMessageItemTypeAudio:
            return [NSString stringWithFormat:@"%@%@", pre, NSLocalizedString(@"MESSAGE_AUDIO", nil)];
        case JRMessageItemTypeImage:
            return [NSString stringWithFormat:@"%@%@", pre, NSLocalizedString(@"MESSAGE_IMAGE", nil)];
        case JRMessageItemTypeVcard:
            return [NSString stringWithFormat:@"%@%@", pre, NSLocalizedString(@"MESSAGE_VCARD", nil)];
        case JRMessageItemTypeVideo:
            return [NSString stringWithFormat:@"%@%@", pre, NSLocalizedString(@"MESSAGE_VIDEO", nil)];
        case JRMessageItemTypeText:
            return [NSString stringWithFormat:@"%@%@", pre, message.content];
        case JRMessageItemTypeNotify:
            return message.content;
        case JRMessageItemTypeOtherFile:
            return [NSString stringWithFormat:@"%@%@", pre, NSLocalizedString(@"MESSAGE_FILE", nil)];
        default:
            break;
    }
    return nil;
}

@end
