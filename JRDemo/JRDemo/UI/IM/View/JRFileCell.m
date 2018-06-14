//
//  JRFileCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/27.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRFileCell.h"

@interface JRFileCell ()

@property (nonatomic, weak) id <JRFileCellDelegate> delegate;
@property (nonatomic, weak) UITableView *wTableView;

@end

@implementation JRFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setDelegate:(id<JRFileCellDelegate>)delegate tableView:(UITableView *)tableView {
    self.delegate = delegate;
    self.wTableView = tableView;
}

- (IBAction)send:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:sendMessage:)] && self.wTableView) {
        [self.delegate tableView:self.wTableView sendMessage:[self.wTableView indexPathForCell:self]];
    }
}

@end
