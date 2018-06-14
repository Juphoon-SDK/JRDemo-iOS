//
//  JRGroupCell.h
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JRGroupCellDelegate <NSObject>

@optional

- (void)tableView:(UITableView *)tableView reject:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView accept:(NSIndexPath *)indexPath;

@end

@interface JRGroupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupTypeLabel;

- (void)setDelegate:(id<JRGroupCellDelegate>)delegate tableView:(UITableView *)tableView pending:(BOOL)pending;

@end
