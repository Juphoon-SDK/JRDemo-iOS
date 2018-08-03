//
//  JRBaseBubbleLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleLayout.h"
#import "MHPrettyDate.h"
#import "UIImage+Tint.h"
#import "JRGroupDBManager.h"

@implementation JRBaseBubbleLayout

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName {
    self.message = message;
    self.showTime = showTime;
    self.showName = showName;
    self.imdnId = message.imdnId;
    
    CGFloat avatorY = 0;
    _timeLabelText = [MHPrettyDate prettyDateFromDate:[NSDate dateWithTimeIntervalSince1970:[self.message.timestamp longLongValue]/1000] withFormat:MHPrettyDateFormatWithTime];
    if (showTime) {
        _timeLabelFrame = CGRectMake(0, 0, CellWidth, TimeLabelHeight);
        avatorY+=TimeLabelHeight;
    } else {
        _timeLabelFrame = CGRectZero;
    }
    
    switch (message.state) {
        case JRMessageItemStateInit:
        case JRMessageItemStateSendInvite:
        case JRMessageItemStateSending:
            if (self.message.type != JRMessageItemTypeText) {
                _stateViewImage = [[UIImage imageNamed:@"im_sending"] imageWithColor:[UIColor grayColor]];
            }
            break;
        case JRMessageItemStateSendFailed:
        case JRMessageItemStateSendingPause:
            _stateViewImage = [[UIImage imageNamed:@"im_failed"] imageWithColor:[UIColor redColor]];
            break;
        case JRMessageItemStateSendOK:
        case JRMessageItemStateReceiveOK:
        case JRMessageItemStateReceiveInvite:
        case JRMessageItemStateReceiving:
        case JRMessageItemStateReceiveFailed:
        case JRMessageItemStateReceivingPause:
        case JRMessageItemStateRevoked:
            _stateViewImage = nil;
            break;
        case JRMessageItemStateDelivered:
            _stateViewImage = [[UIImage imageNamed:@"im_dli"] imageWithColor:[UIColor colorWithRed:120.0/255.0 green:210.0/255.0 blue:110.0/255.0 alpha:1]];
            break;
        case JRMessageItemStateRead:
            _stateViewImage = [[UIImage imageNamed:@"im_dispok"] imageWithColor:[UIColor colorWithRed:120.0/255.0 green:210.0/255.0 blue:110.0/255.0 alpha:1]];
            break;
    }
    
    _avatorViewImage = self.message.direction == JRMessageItemDirectionSend || self.message.isCarbonCopy ? [UIImage imageNamed:@"img_blueman_nor"] : [UIImage imageNamed:@"img_greenman_nor"];
    if (self.message.groupChatId.length) {
        _nameLabelText = [JRGroupDBManager getGroupMemberWithIdentity:self.message.peerNumber number:self.message.senderNumber].displayName;
    }
    if (!_nameLabelText.length) {
        _nameLabelText = self.message.senderNumber;
    }
    
    if (showName) {
        _nameLabelFrame = CGRectMake(AvatorSize+2*Margin, _timeLabelFrame.size.height, CellWidth-2*(AvatorSize+2*Margin), NameLabelHeight);
        avatorY+=NameLabelHeight;
    } else {
        _nameLabelFrame = CGRectZero;
    }
    
    CGSize bubbleSize = [self calculateBubbleViewSize];
    if (self.message.direction == JRMessageItemDirectionSend || self.message.isCarbonCopy) {
        _nameLabelTextAlignment = NSTextAlignmentRight;
        _avatorViewFrame = CGRectMake(CellWidth-(AvatorSize+Margin), avatorY+Margin, AvatorSize, AvatorSize);
        _bubbleViewFrame = CGRectMake(CellWidth-(CGRectGetWidth(_avatorViewFrame)+2*Margin)-bubbleSize.width, avatorY+Margin, bubbleSize.width, bubbleSize.height);
        _bubbleViewBackgroupColor = [JRSettings skinColor];
        _contentViewFrame = CGRectMake(BubbleViewMargin, BubbleViewMargin, bubbleSize.width-2*BubbleViewMargin, bubbleSize.height-2*BubbleViewMargin);
        _stateViewFrame = CGRectMake(_bubbleViewFrame.origin.x-StateViewMargin-StateViewSize, CGRectGetMidY(_bubbleViewFrame)-StateViewSize/2, StateViewSize, StateViewSize);
    } else {
        _nameLabelTextAlignment = NSTextAlignmentLeft;
        _avatorViewFrame = CGRectMake(Margin, avatorY+Margin, AvatorSize, AvatorSize);
        _bubbleViewFrame = CGRectMake(CGRectGetMaxX(_avatorViewFrame)+Margin, avatorY+Margin, bubbleSize.width, bubbleSize.height);
        _bubbleViewBackgroupColor = [UIColor whiteColor];
        _contentViewFrame = CGRectMake(BubbleViewMargin, BubbleViewMargin, bubbleSize.width-2*BubbleViewMargin, bubbleSize.height-2*BubbleViewMargin);
        _stateViewFrame = CGRectMake(BubbleViewMargin, BubbleViewMargin, bubbleSize.width-2*BubbleViewMargin, bubbleSize.height-2*BubbleViewMargin);
        _stateViewFrame = CGRectMake(CGRectGetMaxX(_bubbleViewFrame)+StateViewMargin, CGRectGetMidY(_bubbleViewFrame)-StateViewSize/2, StateViewSize, StateViewSize);
    }
}

- (CGFloat)calculateCellHeight {
    CGFloat height = 0;
    if (_showTime) {
        height += TimeLabelHeight;
    }
    if (_showName) {
        height += NameLabelHeight;
    }
    CGFloat bubbleHeight = [self calculateBubbleViewSize].height;
    if (bubbleHeight+2*BubbleViewMargin<AvatorSize) {
        height += AvatorSize;
    } else {
        height += (bubbleHeight+2*BubbleViewMargin);
    }
    height += Margin*2;
    return height;
}

- (CGSize)calculateBubbleViewSize {
    CGSize size = CGSizeZero;
    switch (self.message.type) {
        case JRMessageItemTypeUnknow:
            break;
        case JRMessageItemTypeText: {
            if (self.message.contentType == JRTextMessageContentTypeDefault) {
                NSDictionary *attributes = @{
                                             NSFontAttributeName : TextFont,
                                             };
                CGSize contetSize = [_message.content boundingRectWithSize:CGSizeMake(ContentLabelMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                size = CGSizeMake(contetSize.width+2*BubbleViewMargin, contetSize.height+2*BubbleViewMargin);
            } else {
                size = CGSizeMake(ExVCardSize.width+2*BubbleViewMargin, ExVCardSize.height+2*BubbleViewMargin);
                break;
            }
            break;
        }
        case JRMessageItemTypeVideo:
        case JRMessageItemTypeImage: {
            if (_message.fileThumbPath.length) {
                UIImage *image = [UIImage imageWithContentsOfFile:[JRFileUtil getAbsolutePathWithFileRelativePath: _message.fileThumbPath]];
                CGFloat height,width;
                if (image.size.height > image.size.width) {
                    height = ImgMaxLine;
                    width = ImgMaxLine*image.size.width/image.size.height;
                } else {
                    width = ImgMaxLine;
                    height = ImgMaxLine*image.size.height/image.size.width;
                }
                size = CGSizeMake(width+2*BubbleViewMargin, height+2*BubbleViewMargin);
            } else {
                size = CGSizeMake(100+2*BubbleViewMargin, 100+2*BubbleViewMargin);
            }
            break;
        }
        case JRMessageItemTypeAudio: {
            size = CGSizeMake(AudioSize.width+2*BubbleViewMargin, AudioSize.height+2*BubbleViewMargin);
            break;
        }
        case JRMessageItemTypeVcard: {
            size = CGSizeMake(VCardSize.width+2*BubbleViewMargin, VCardSize.height+2*BubbleViewMargin);
            break;
        }
        case JRMessageItemTypeGeo: {
            size = CGSizeMake(LocationSize.width+2*BubbleViewMargin, LocationSize.height+2*BubbleViewMargin);
            break;
        }
        case JRMessageItemTypeOtherFile: {
            size = CGSizeMake(OtherFileSize.width+2*BubbleViewMargin, OtherFileSize.height+2*BubbleViewMargin);
            break;
        }
        default:
            break;
    }
    return size;
}

@end
