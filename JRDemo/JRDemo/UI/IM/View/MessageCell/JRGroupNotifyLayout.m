//
//  JRGroupNotifyLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/5/9.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupNotifyLayout.h"
#import "MHPrettyDate.h"

@implementation JRGroupNotifyLayout

- (void)configWithMessage:(JRMessageObject *)message
{
    self.message = message;
    self.imdnId = message.imdnId;
    
    _groupHintLabelText = self.message.content;
    _groupHintLabelColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:0.3];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : InfoTextFont,
                                 };
    CGSize contetSize = [self.message.content boundingRectWithSize:CGSizeMake(InfoContentLabelMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    CGFloat centerY = InfoMargin + contetSize.height/2 + InfoTimeLabelHeight + InfoBubbleMargin;
    CGSize size = CGSizeMake(contetSize.width+2*InfoBubbleMargin, contetSize.height+2*InfoBubbleMargin);
    CGPoint center = CGPointMake(InfoCellWidth/2, centerY);
    
    _groupHintLabelFrame = CGRectMake(center.x-size.width/2, center.y-size.height/2, size.width, size.height);
    
    _timeLabelText = [MHPrettyDate prettyDateFromDate:[NSDate dateWithTimeIntervalSince1970:[self.message.timestamp longLongValue]/1000] withFormat:MHPrettyDateFormatWithTime];
    _timeLabelFrame = CGRectMake(0, 0, InfoCellWidth, InfoTimeLabelHeight);
}

- (CGFloat)calculateCellHeight
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : InfoTextFont,
                                 };
    CGSize contetSize = [self.message.content boundingRectWithSize:CGSizeMake(InfoContentLabelMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return InfoTimeLabelHeight + contetSize.height + 2*InfoMargin + 2*InfoBubbleMargin;
}

@end
