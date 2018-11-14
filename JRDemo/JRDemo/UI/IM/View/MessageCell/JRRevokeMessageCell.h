//
//  JRRevokeMessageCell.h
//  JRDemo
//
//  Created by Ginger on 2018/7/20.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRRevokeLayout.h"

@interface JRRevokeMessageCell : UITableViewCell

@property (nonatomic, strong) JRRevokeLayout *layout;

@property (nonatomic, strong) UILabel *revokeHintLabel;

@property (nonatomic, strong) JRMessageObject *message;

- (void)configWithLayout:(JRRevokeLayout *)layout;

@end
