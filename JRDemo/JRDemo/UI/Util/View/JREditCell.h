//
//  JREditCell.h
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JREditCell;

@protocol JREditCellDelegate <NSObject>

@optional

- (void)tableView:(UITableView *)tableView outMin:(int)min cell:(JREditCell *)cell;
- (void)tableView:(UITableView *)tableView outMax:(int)max cell:(JREditCell *)cell;
- (void)tableView:(UITableView *)tableView invalididValue:(JREditCell *)cell;

@end

@interface JREditCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, assign) int mMaxNumber;
@property (nonatomic, assign) int mMinNumber;
@property (nonatomic, assign) BOOL mOnlyNumber;

- (void)setEnabled:(BOOL)enabled;
- (void)setDelegate:(id<JREditCellDelegate>)delegate tableView:(UITableView *)tableView;

@end
