//
//  JRCapacityViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/6/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRCapacityViewController.h"

@interface JRCapacityViewController () <JRCapacityCallback>

@property (weak, nonatomic) IBOutlet UITextField *numberField;

@end

@implementation JRCapacityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [JRCapacity sharedInstance].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cap:(id)sender {
    [[JRCapacity sharedInstance] queryRcsCapacity:self.numberField.text];
}

- (void)onQueryRcsCapacityResult:(BOOL)result isRcsUser:(BOOL)isRcsUser isOnline:(BOOL)isOnline number:(NSString *)number cookie:(int)cookie {
    if (!result) {
        [SVProgressHUD showErrorWithStatus:@"查询失败"];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    if (isRcsUser) {
        if (isOnline) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ 是RCS用户，并且在线", number]];
        } else {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ 是RCS用户，但是不在线", number]];
        }
        [SVProgressHUD dismissWithDelay:1.5];
    } else {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ 非RCS用户", number]];
        [SVProgressHUD dismissWithDelay:1.5];
    }
}

@end
