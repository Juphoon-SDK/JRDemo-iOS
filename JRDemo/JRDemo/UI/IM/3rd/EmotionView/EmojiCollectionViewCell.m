//
//  EmojiCollectionViewCell.m
//  JusRcs
//
//  Created by 杨明月 on 14-7-17.
//  Copyright (c) 2014年 juphoon. All rights reserved.
//

#import "EmojiCollectionViewCell.h"

@implementation EmojiCollectionViewCell

//- (id)init
//{
//    if (self = [super init]) {
//        
//        _emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        _emojiLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:29.0];
//        [self.contentView addSubview:_emojiLabel];
//    }
//    return self;
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization cod
        float rate = [UIScreen mainScreen].bounds.size.width / 320;
        _emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rate*40, rate*40)];
        _emojiLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:rate*29.0];
        [self.contentView addSubview:_emojiLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
