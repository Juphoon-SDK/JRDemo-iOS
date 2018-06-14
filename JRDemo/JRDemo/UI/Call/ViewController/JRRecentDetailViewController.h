//
//  JRRecentDetailViewController.h
//  JRDemo
//
//  Created by Ginger on 2018/4/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRCallObject.h"

@interface JRRecentDetailViewController : UIViewController

- (instancetype)initWithLog:(NSArray<JRCallObject *> *)calls;

@end
