//
//  JRMultiVideoCollectionViewCell.h
//  JRDemo
//
//  Created by Ginger on 2018/6/4.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WHRate 0.5

@interface JRMultiVideoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end
