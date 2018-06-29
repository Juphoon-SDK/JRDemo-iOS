//
//  JRLoadIconViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/6/28.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRLoadIconViewController.h"

@interface JRLoadIconViewController () <JRProfileCallback>

@property (weak, nonatomic) IBOutlet UIImageView *selfIcon;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UITextField *numberField;

@end

@implementation JRLoadIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [JRProfile sharedInstance].delegate = self;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)endEdit {
    [self.view endEditing:YES];
}

- (IBAction)loadSelfIcon:(id)sender {
    [[JRProfile sharedInstance] loadSelfIcon:JRProfileIconSolution42];
}

- (IBAction)loadUserIcon:(id)sender {
    [[JRProfile sharedInstance] loadUserIcon:self.numberField.text solution:JRProfileIconSolution42];
}
- (IBAction)updateSelfIcon:(id)sender {
    [[JRProfile sharedInstance] updateSelfIcon:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"defaultIcon.jpg"]];
}

#pragma mark - JRProfileCallback

- (void)onLoadUserIconResult:(BOOL)result path:(NSString *)path number:(NSString *)number {
    [SVProgressHUD dismiss];
    if (result) {
        [SVProgressHUD showSuccessWithStatus:@"下载成功"];
        self.userIcon.image = [UIImage imageWithContentsOfFile:path];
        [SVProgressHUD dismissWithDelay:1.5];
    } else {
        [SVProgressHUD showErrorWithStatus:@"下载失败"];
        [SVProgressHUD dismissWithDelay:1.5];
    }
}

- (void)onLoadSelfIconResult:(BOOL)result path:(NSString *)path {
    [SVProgressHUD dismiss];
    if (result) {
        [SVProgressHUD showSuccessWithStatus:@"下载成功"];
        self.selfIcon.image = [UIImage imageWithContentsOfFile:path];
        [SVProgressHUD dismissWithDelay:1.5];
    } else {
        [SVProgressHUD showErrorWithStatus:@"下载失败"];
        [SVProgressHUD dismissWithDelay:1.5];
    }
}

- (void)onUpdateIconResult:(BOOL)result {
    [SVProgressHUD dismiss];
    if (result) {
        [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        [SVProgressHUD dismissWithDelay:1.5];
    } else {
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        [SVProgressHUD dismissWithDelay:1.5];
    }
}

@end
