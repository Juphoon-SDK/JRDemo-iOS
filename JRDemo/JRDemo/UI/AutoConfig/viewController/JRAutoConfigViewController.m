//
//  JRAutoConfigViewController.m
//  JRDemo
//
//  Created by Home on 16/04/2018.
//  Copyright © 2018 Ginger. All rights reserved.
//

#import "JRAutoConfigViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "JRAutoConfigManager.h"

@interface JRAutoConfigViewController () <JRAutoConfigManagerDelegate, JRAutoConfigCallback>

@end

@implementation JRAutoConfigViewController

- (instancetype)init
{
    if ([super init]) {
        [JRAutoConfigManager sharedInstance].delegate = self;
        [JRAutoConfig sharedInstance].delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[JRAutoConfigManager sharedInstance] requestLoginAuthInPs];
    self.view.backgroundColor = [UIColor whiteColor];
    [SVProgressHUD showWithStatus:@"自动配置中.."];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

#pragma mark - JRAutoConfigManagerDelegate

- (void)cmccCpGetAuthInformationSucceed:(NSString *)userName password:(NSString *)password token:(NSString *)token {
    [[JRAutoConfig sharedInstance] startAutoConfig:userName password:password token:token];
}

- (void)cmccCpGetAuthInformationFailed:(NSUInteger)resultCode {
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:@"自动配置失败"];
}

#pragma mark - JRAutoConfigCallback

- (void)onAutoConfigResult:(BOOL)result code:(JRAutoConfigError)code {
    [SVProgressHUD dismiss];
    if (!result) {
        [SVProgressHUD showErrorWithStatus:@"自动配置失败"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"自动配置成功"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)onAutoConfigExpire {
    [[JRAutoConfigManager sharedInstance] requestLoginAuthInPs];
}

- (NSString *)onAutoConfigAuthInd {
    // 应缓存token在此
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
