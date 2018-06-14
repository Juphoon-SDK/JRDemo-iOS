//
//  JRGroupNotifyCell.h
//  JRDemo
//
//  Created by Ginger on 2018/5/9.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRGroupNotifyLayout.h"

@interface JRGroupNotifyCell : UITableViewCell

@property (nonatomic, strong) JRGroupNotifyLayout *layout;

@property (nonatomic, strong) UILabel *groupHintLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) JRMessageObject *message;

- (void)configWithLayout:(JRGroupNotifyLayout *)layout;

@end
