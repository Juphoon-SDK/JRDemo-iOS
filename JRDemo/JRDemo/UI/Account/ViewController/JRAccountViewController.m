//
//  JRAccountViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAccountViewController.h"
#import "JRClientManager.h"
#import "JRSwitchCell.h"
#import "JRAccountInfoViewController.h"
#import "JRAddAccountViewController.h"
#import "JRAboutViewController.h"

typedef NS_ENUM(NSInteger, SettingSection) {
    SettingSectionAccount,
//    SettingSectionSettings,
    SettingSectionAbout,
    SettingSectionCount,
};

typedef NS_ENUM(NSInteger, OtherSettingsRow) {
    OtherSettingsRowVibrate,
    OtherSettingsRowRing,
    OtherSettingsRowCount,
};

typedef NS_ENUM(NSInteger, AboutRow) {
    AboutRowAbout,
    AboutRowCount,
};

@interface JRAccountViewController () <UITableViewDelegate, UITableViewDataSource, JRAddAccountViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation JRAccountViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"TAB_SETTING", nil);
    [self.view addSubview:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChanged:) name:kClientStateChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:kClientLoginFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:kClientLogoutNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)loginFailed:(NSNotification *)notification {
    JRClientReason reason = [(NSNumber *)[notification.userInfo objectForKey:kClientReasonKey] intValue];
    if (reason == JRClientReasonAuthenticationFailed) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"AUTH_FAILED", nil)];
    } else if (reason == JRClientReasonTimeout) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"TIMEOUT", nil)];
    } else if (reason == JRClientReasonServerForbidden) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SERVE_FORBIDDEN", nil)];
    } else if (reason == JRClientReasonNetworkError) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROE", nil)];
    }
}

- (void)stateChanged:(NSNotification *)notification {
    JRClientState state = [(NSNumber *)[notification.userInfo objectForKey:kClientStateKey] intValue];
    switch (state) {
        case JRClientStateUnknow:
        case JRClientStateIdle:
            self.title = NSLocalizedString(@"TAB_SETTING", nil);
            break;
        case JRClientStateLogining:
            self.title = NSLocalizedString(@"LOGINING", nil);
            break;
        case JRClientStateLogined:
            self.title = NSLocalizedString(@"LOGINED", nil);
            break;
        case JRClientStateLogouting:
            self.title = NSLocalizedString(@"LOGOUTING", nil);
            break;
        default:
            self.title = NSLocalizedString(@"TAB_SETTING", nil);
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SettingSectionAccount: {
            if ([JRClient sharedInstance].state <= JRClientStateIdle) {
                return [JRAccount getAccountsList].count + 1;
            } else {
                return 2;
            }
        }
//        case SettingSectionSettings:
//            return OtherSettingsRowCount;
        case SettingSectionAbout:
            return AboutRowCount;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SettingSectionAccount:
            return NSLocalizedString(@"SETTING_ACCOUNT", nil);
//        case SettingSectionSettings:
        case SettingSectionAbout:
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SettingSectionAccount: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
            }
            if ([JRClient sharedInstance].state <= JRClientStateIdle) {
                NSString *account;
                if (indexPath.row < [JRAccount getAccountsList].count) {
                    account = [JRAccount getAccountsList][indexPath.row];
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                } else {
                    account = NSLocalizedString(@"SETTING_ADD_ACCOUNT", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                cell.textLabel.text = account;
                cell.textLabel.textColor = [UIColor blackColor];
            } else {
                if (indexPath.row == 0) {
                    cell.textLabel.text = [JRClient sharedInstance].currentUser;
                    cell.textLabel.textColor = [UIColor blueColor];
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                } else {
                    cell.textLabel.text = NSLocalizedString(@"SETTING_LOGOUT", nil);
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            return cell;
        }
//        case SettingSectionSettings:
//            switch (indexPath.row) {
//                case OtherSettingsRowVibrate: {
//                    JRSwitchCell *cell = [[JRSwitchCell alloc] init];
//                    cell.titleLabel.text = NSLocalizedString(@"SETTING_VIBRATE_WHEN_ACCEPT", nil);
//                    cell.switchView.enabled = YES;
//                    return cell;
//                }
//                case OtherSettingsRowRing: {
//                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
//                    if (!cell) {
//                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
//                    }
//                    cell.textLabel.text = NSLocalizedString(@"SETTING_RINGTONE", nil);
//                    cell.textLabel.textColor = [UIColor blackColor];
//                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                    return cell;
//                }
//            }
        case SettingSectionAbout: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
            }
            cell.textLabel.text = NSLocalizedString(@"SETTING_ABOUT", nil);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case SettingSectionAccount: {
            if ([JRClient sharedInstance].state <= JRClientStateIdle) {
                if (indexPath.row < [JRAccount getAccountsList].count) {
                    [[JRClient sharedInstance] login:[JRAccount getAccountsList][indexPath.row]];
                } else {
                    [JRAddAccountViewController presentWithNavigationController:^(JRAddAccountViewController *addAccountViewController) {
                        addAccountViewController.accountDelegate = self;
                        addAccountViewController.navigationItem.title = NSLocalizedString(@"SETTING_ADD_ACCOUNT", nil);
                    } presentingViewController:self];
                }
            } else {
                if (indexPath.row != 0) {
                    [[JRClient sharedInstance] logout];
                } else {
                    JRAccountInfoViewController *view = [[JRAccountInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    view.account = [JRClient sharedInstance].currentUser;
                    [self.navigationController pushViewController:view animated:YES];
                }
            }
            break;
        }
//        case SettingSectionSettings: {
//            if (indexPath.row == OtherSettingsRowRing) {
//                // 设置铃声
//            }
//            break;
//        }
        case SettingSectionAbout: {
            // 关于页
            JRAboutViewController *about = [[JRAboutViewController alloc] init];
            [self.navigationController pushViewController:about animated:YES];
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *account;
    if ([JRClient sharedInstance].state != JRClientStateIdle && [JRClient sharedInstance].state != JRClientStateUnknow) {
        account = [JRClient sharedInstance].currentUser;
    } else {
        account = [JRAccount getAccountsList][indexPath.row];
    }
    JRAccountInfoViewController *vc = [[JRAccountInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.hidesBottomBarWhenPushed = YES;
    vc.account = account;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - JRAddAccountViewControllerDelegate

- (void)addAccountFinish:(JRAddAccountViewController *)addAccountViewController account:(NSString *)account {
    [self.tableView reloadData];
}

- (void)addAccountCancel:(JRAddAccountViewController *)addAccountViewController {
    [self.tableView reloadData];
}

@end
