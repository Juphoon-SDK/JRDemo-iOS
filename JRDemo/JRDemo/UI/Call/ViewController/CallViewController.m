//
//  CallViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/1/25.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "CallViewController.h"
#import "JRRecentCallViewController.h"
#import "JRClientManager.h"
#import "JRAutoConfigManager.h"

@interface CallViewController ()

@property (weak, nonatomic) IBOutlet UITextField *numberField;

@end

@implementation CallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdite)]];
}

- (void)endEdite {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)audioCall:(id)sender {
    [[JRCall sharedInstance] call:self.numberField.text video:false];
}

- (IBAction)videoCall:(id)sender {
    [[JRCall sharedInstance] call:self.numberField.text video:true];
}

- (IBAction)multiCall:(id)sender {
    NSArray *numbers = [self.numberField.text componentsSeparatedByString:@"#"];
    [[JRCall sharedInstance] createMultiCall:numbers video:NO token:nil];
}

- (IBAction)recent:(id)sender {
    JRRecentCallViewController *recent = [[JRRecentCallViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:recent];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)multiVideo:(id)sender {
    NSArray *numbers = [self.numberField.text componentsSeparatedByString:@"#"];
    [[JRAutoConfigManager sharedInstance] requestAccessTokenFinishBlock:^(NSString *token) {
        if (token.length) {
            [[JRCall sharedInstance] createMultiCall:numbers video:YES token:token];
        }
    }];
}

@end
