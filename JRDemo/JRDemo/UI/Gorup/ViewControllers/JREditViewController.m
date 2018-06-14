//
//  JREditViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JREditViewController.h"

@interface JREditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *tipTextView;

@end

@implementation JREditViewController

+ (void)presentWithNavigationController:(void (^)(JREditViewController *viewController))configBlock presentingViewController:(UIViewController *)viewController {
    JREditViewController *vc = [[JREditViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    if (configBlock) {
        configBlock(vc);
    }
    [viewController presentViewController:navigationController animated:YES completion:^{
        [vc.textField becomeFirstResponder];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.text = self.defaultContent;
    self.tipTextView.text = self.tip;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftBarItemAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"OK", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemAction)];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)endEdit {
    [self.view endEditing:YES];
}

- (void)leftBarItemAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelComplete:)]) {
        [self.delegate cancelComplete:self];
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBarItemAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editComplete:content:)]) {
        [self.delegate editComplete:self content:self.textField.text];
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
