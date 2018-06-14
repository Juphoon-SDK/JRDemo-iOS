//
//  JRFileCell.h
//  JRDemo
//
//  Created by Ginger on 2018/2/27.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JRFileCellDelegate <NSObject>

@optional

- (void)tableView:(UITableView *)tableView sendMessage:(NSIndexPath *)index;

@end

@interface JRFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

- (void)setDelegate:(id<JRFileCellDelegate>)delegate tableView:(UITableView *)tableView;

@end
