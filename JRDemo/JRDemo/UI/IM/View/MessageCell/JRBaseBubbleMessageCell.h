//
//  JRBaseBubbleMessageCell.h
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRBaseBubbleLayout.h"

@protocol JRMessageCellDelegate <NSObject>

@optional

- (void)tableView:(UITableView *)tableView tapMessageCellContent:(JRMessageObject *)message;
- (void)tableView:(UITableView *)tableView tapMessageCellState:(JRMessageObject *)message;
- (void)tableView:(UITableView *)tableView tapMessageCellAvator:(JRMessageObject *)message;

@end

@interface JRBaseBubbleMessageCell : UITableViewCell

@property (nonatomic, strong) JRBaseBubbleLayout *layout;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *avatorImage;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *stateView;

@property (nonatomic, strong) UIView *msgContentView;

- (void)configWithLayout:(JRBaseBubbleLayout *)layout;

- (void)setDelegate:(id<JRMessageCellDelegate>)delegate tableView:(UITableView *)tableView;

@end
