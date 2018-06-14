//
//  JRAboutViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/3/14.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAboutViewController.h"

@interface JRAboutViewController () <UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildLabel;

@end

@implementation JRAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [dict objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [dict objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"version:%@", version];
    self.buildLabel.text = [NSString stringWithFormat:@"build:%@", build];
    
    self.navigationController.delegate = self;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pop)]];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:[viewController isKindOfClass:[self class]] animated:YES];
}

@end
