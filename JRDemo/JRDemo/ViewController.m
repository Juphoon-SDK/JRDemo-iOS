//
//  ViewController.m
//  JRDemo
//
//  Created by Ginger on 2017/11/29.
//  Copyright © 2017年 Ginger. All rights reserved.
//

#import "ViewController.h"
#import "JRAccountViewController.h"
#import "JRConversationsViewController.h"
#import "JRAutoConfigViewController.h"
#import "JRGroupsListViewController.h"
#import "JRCapacityViewController.h"
#import "JRLoadIconViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)accountView:(id)sender {
    JRAccountViewController *view = [[JRAccountViewController alloc] init];
    [self.navigationController pushViewController:view animated:true];
}

- (IBAction)conversation:(id)sender {
    JRConversationsViewController *view = [[JRConversationsViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)autoConfig:(UIButton *)sender {
    JRAutoConfigViewController *view = [[JRAutoConfigViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)groupManager:(id)sender {
    JRGroupsListViewController *view = [[JRGroupsListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)queryCapacity:(id)sender {
    JRCapacityViewController *view = [[JRCapacityViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)icon:(id)sender {
    JRLoadIconViewController *view = [[JRLoadIconViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

@end
