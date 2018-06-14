//
//  JRGroupCell.m
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupCell.h"

@interface JRGroupCell ()

@property (nonatomic, weak) id<JRGroupCellDelegate> delegate;
@property (nonatomic, weak) UITableView *wTableView;
@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;

@end

@implementation JRGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDelegate:(id<JRGroupCellDelegate>)delegate tableView:(UITableView *)tableView pending:(BOOL)pending {
    self.delegate = delegate;
    self.wTableView = tableView;
    
    self.acceptBtn.hidden = !pending;
    self.rejectBtn.hidden = !pending;
    self.groupTypeLabel.hidden = pending;
}

- (IBAction)reject:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:reject:)] && self.wTableView) {
        [self.delegate tableView:self.wTableView reject:[self.wTableView indexPathForCell:self]];
    }
}

- (IBAction)accept:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:accept:)] && self.wTableView) {
        [self.delegate tableView:self.wTableView accept:[self.wTableView indexPathForCell:self]];
    }
}

@end
