//
//  JRGroupDetailViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupDetailViewController.h"
#import "JRGroupMembersViewController.h"
#import "JREditViewController.h"
#import "JRGroupDBManager.h"
#import "JRGroupManager.h"
#import "JRNumberUtil.h"

@interface JRGroupDetailViewController () <JREditViewControllerDelegate>

@property (nonatomic, strong) JRGroupObject *group;
@property (strong, nonatomic) RLMNotificationToken *groupToken;

@end

@implementation JRGroupDetailViewController

- (instancetype)initWithGroup:(JRGroupObject *)group {
    if ([super initWithStyle:UITableViewStyleGrouped]) {
        self.group = group;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self)
    self.groupToken = [self.group addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
        @strongify(self)
        if (!deleted) {
            [self.tableView reloadData];
        }
    }];

    self.tableView.rowHeight = 50.0f;
    self.tableView.sectionFooterHeight = 50.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.groupToken invalidate];
}

- (BOOL)isChairman {
    return [JRNumberUtil isNumberEqual:[JRClient sharedInstance].currentNumber secondNumber:self.group.chairMan];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = @"群聊名称";
        cell.detailTextLabel.text = self.group.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else if (indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = @"修改群名片";
        JRGroupMemberObject *selfMember = [JRGroupDBManager getGroupMemberWithIdentity:self.group.identity number:[JRClient sharedInstance].currentNumber];
        cell.detailTextLabel.text = selfMember.displayName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"所有成员";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    footer.backgroundColor = [JRSettings skinColor];
    footer.textColor = [UIColor whiteColor];
    if ([self isChairman]) {
        footer.text = @"解散群聊";
    } else {
         footer.text = @"退出群聊";
    }
    footer.textAlignment = NSTextAlignmentCenter;
    footer.userInteractionEnabled = YES;
    [footer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerClick)]];
    return footer;
}

- (void)footerClick {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[self isChairman] ? NSLocalizedString(@"DISSOLVE_GROUP_TIP", nil) : NSLocalizedString(@"LEAVE_GROUP_TIP", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![self isChairman]) {
            [[JRGroupManager sharedInstance] leave:self.group];
        } else {
            [[JRGroupManager sharedInstance] dissolve:self.group];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        if ([self isChairman]) {
            [JREditViewController presentWithNavigationController:^(JREditViewController *viewController) {
                viewController.title = @"修改群名称";
                viewController.tip = @"修改群名称";
                viewController.type = EditTypeGroupName;
                viewController.defaultContent = self.group.name;
                viewController.delegate = self;
            } presentingViewController:self];
        }
    } else if (indexPath.row == 1) {
        [JREditViewController presentWithNavigationController:^(JREditViewController *viewController) {
            viewController.title = @"我的群昵称";
            viewController.tip = @"修改群昵称";
            viewController.type = EditTypeDisplayName;
            viewController.defaultContent = [JRGroupDBManager getGroupMemberWithIdentity:self.group.identity number:[JRClient sharedInstance].currentNumber].displayName;
            viewController.delegate = self;
        } presentingViewController:self];
    } else {
        JRGroupMembersViewController *view = [[JRGroupMembersViewController alloc] initWithGroup:self.group];
        [self.navigationController pushViewController:view animated:YES];
    }
}

#pragma mark - JREditViewControllerDelegate

- (void)editComplete:(JREditViewController *)viewController content:(NSString *)content {
    if (viewController.type == EditTypeDisplayName) {
        [[JRGroupManager sharedInstance] modifyNickName:self.group newName:content];
    } else if (viewController.type == EditTypeGroupName) {
        [[JRGroupManager sharedInstance] modifyGroupName:self.group newName:content];
    }
}

- (void)cancelComplete:(JREditViewController *)viewController {
    
    
}

@end
