//
//  JRBaseBubbleMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleMessageCell.h"

@implementation JRBaseBubbleMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = nil;
        self.layer.shouldRasterize = true;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configWithLayout:(JRBaseBubbleLayout *)layout
{
    self.layout = layout;
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_timeLabel];
    }
    if (!_avatorImage) {
        _avatorImage = [[UIImageView alloc] init];
        _avatorImage.layer.masksToBounds = YES;
        _avatorImage.layer.cornerRadius = AvatorSize/2;
        _avatorImage.userInteractionEnabled = YES;
        [_avatorImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvator)]];
        [self.contentView addSubview:_avatorImage];
    }
    if (!_bubbleView) {
        _bubbleView = [[UIView alloc] init];
        _bubbleView.layer.cornerRadius = 15.0f;
        _bubbleView.layer.masksToBounds = YES;
        [self.contentView addSubview:_bubbleView];
    }
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_nameLabel];
    }
    if (!_stateView) {
        _stateView = [[UIImageView alloc] init];
        [_stateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapState)]];
        _stateView.userInteractionEnabled = YES;
        [self.contentView addSubview:_stateView];
    }
    if (!_msgContentView) {
        _msgContentView = [[UIView alloc] init];
        [_msgContentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContent)]];
        [_msgContentView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setupNormalMenuController:)]];
        _msgContentView.userInteractionEnabled = YES;
        [_bubbleView addSubview:_msgContentView];
    }
    
    _timeLabel.hidden = !layout.showTime;
    _timeLabel.text = layout.timeLabelText;
    
    _avatorImage.image = layout.avatorViewImage;
   
    _nameLabel.hidden = !layout.showName;
    _nameLabel.textAlignment = layout.nameLabelTextAlignment;
    _nameLabel.text = layout.nameLabelText;
    _stateView.image = layout.stateViewImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.timeLabel.frame = self.layout.timeLabelFrame;
    self.nameLabel.frame = self.layout.nameLabelFrame;
    self.avatorImage.frame = self.layout.avatorViewFrame;
    self.stateView.frame = self.layout.stateViewFrame;
    self.bubbleView.frame = self.layout.bubbleViewFrame;
    self.bubbleView.backgroundColor = self.layout.bubbleViewBackgroupColor;
    self.msgContentView.frame = self.layout.contentViewFrame;
}

- (void)setupNormalMenuController:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [super becomeFirstResponder];
        CGRect selectedCellMessageBubbleFrame = [self convertRect:self.bubbleView.frame toView:self.bubbleView];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *revoke = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(revoke:)];
        if (self.layout.message.state == JRMessageItemStateSendOK || self.layout.message.state == JRMessageItemStateDelivered || self.layout.message.state == JRMessageItemStateRead) {
            [menu setMenuItems:@[revoke]];
        }
        [menu setTargetRect:selectedCellMessageBubbleFrame inView:self.bubbleView];
        [menu setMenuVisible:YES animated:YES];
    }
}

#pragma mark - Menu

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.layout.message.type == JRMessageItemTypeText) {
        if (self.layout.message.state == JRMessageItemStateSendOK || self.layout.message.state == JRMessageItemStateDelivered || self.layout.message.state == JRMessageItemStateRead) {
            return action == @selector(copy:) || action == @selector(revoke:);
        } else if (self.layout.message.state == JRMessageItemStateReceiveOK) {
            return action == @selector(copy:);
        }
    } else if (self.layout.message.type == JRMessageItemTypeGeo) {
        if (self.layout.message.state == JRMessageItemStateSendOK || self.layout.message.state == JRMessageItemStateDelivered || self.layout.message.state == JRMessageItemStateRead) {
            return action == @selector(revoke:);
        }
    } else {
        if (self.layout.message.state == JRMessageItemStateSendOK || self.layout.message.state == JRMessageItemStateDelivered || self.layout.message.state == JRMessageItemStateRead) {
            return action == @selector(revoke:);
        }
    }
    return NO;
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.layout.message.content];
}

- (void)revoke:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:revokeMessage:)]) {
        [self.delegate tableView:self.wTableView revokeMessage:self.layout.message];
    }
}

#pragma mark - Tap Delegate

- (void)setDelegate:(id<JRMessageCellDelegate>)delegate tableView:(UITableView *)tableView {
    _delegate = delegate;
    _wTableView = tableView;
}

- (void)tapContent {
    if (_delegate && [_delegate respondsToSelector:@selector(tableView:tapMessageCellContent:)]) {
        if (_wTableView) {
            [_delegate tableView:_wTableView tapMessageCellContent:self.layout.message];
        }
    }
}

- (void)tapState {
    if (_delegate && [_delegate respondsToSelector:@selector(tableView:tapMessageCellState:)]) {
        if (_wTableView) {
            [_delegate tableView:_wTableView tapMessageCellState:self.layout.message];
        }
    }
}

- (void)tapAvator {
    if (_delegate && [_delegate respondsToSelector:@selector(tableView:tapMessageCellAvator:)]) {
        if (_wTableView) {
            [_delegate tableView:_wTableView tapMessageCellAvator:self.layout.message];
        }
    }
}

@end
