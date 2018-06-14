//
//  JRAccountInfoViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAccountInfoViewController.h"
#import "JREditCell.h"
#import "JRSwitchCell.h"
#import "JRSipSettingsViewController.h"
#import "JRNetSettingsViewController.h"
#import "JRAudioSettingsViewController.h"
#import "JRVideoSettingsViewController.h"
#import "JRAdvancedChooseViewController.h"

typedef NS_ENUM(NSInteger, AccountSettingSection) {
    AccountSettingSectionNormal,
    AccountSettingSectionAdvanced,
    AccountSettingSectionCount,
};

typedef NS_ENUM(NSInteger, NormalSettingRow) {
    NormalSettingRowName,
    NormalSettingRowPassword,
    NormalSettingRowAuthName,
    NormalSettingRowServer,
    NormalSettingRowRealm,
    NormalSettingRowPort,
    NormalSettingRowTransport,
    NormalSettingRowCount,
};

typedef NS_ENUM(NSInteger, AdvancedSettingRow) {
    AdvancedSettingRowSip,
    AdvancedSettingRowAudio,
    AdvancedSettingRowVideo,
    AdvancedSettingRowNet,
    AdvancedSettingRowDelete,
    AdvancedSettingRowCount,
};

static NSString * const EditCellId = @"EditCellId";
static NSString * const NormalCellId = @"NormalCellId";

@interface JRAccountInfoViewController ()

// 常规设置
@property (nonatomic, strong) JREditCell *mUsernameCell;
@property (nonatomic, strong) JREditCell *mPasswordCell;
@property (nonatomic, strong) JREditCell *mAuthNameCell;
@property (nonatomic, strong) JREditCell *mServerCell;
@property (nonatomic, strong) JREditCell *mServerRealmCell;
@property (nonatomic, strong) JREditCell *mPortCell;
@property (nonatomic, strong) UITableViewCell *mTransportCell;
// 其他
@property (nonatomic, strong) UITableViewCell *mSipCell;
@property (nonatomic, strong) UITableViewCell *mAudioCell;
@property (nonatomic, strong) UITableViewCell *mVideoCell;
@property (nonatomic, strong) UITableViewCell *mNetworkCell;
@property (nonatomic, strong) UITableViewCell *mDeleteCell;

@property (nonatomic, assign) BOOL isDelete;

@end

@implementation JRAccountInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SETTING_ACCOUNT", nil);
    [self.tableView registerNib:[UINib nibWithNibName:@"JREditCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:EditCellId];
    [self initCell];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.isDelete) {
        [self save];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCell];
    [self.tableView reloadData];
}

- (void)initCell {
    self.mUsernameCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mUsernameCell.titleLabel.text = NSLocalizedString(@"ACCOUNT_INFO_USERNAME", nil);
    self.mUsernameCell.textField.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyName].stringParam;
    
    self.mPasswordCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mPasswordCell.titleLabel.text = NSLocalizedString(@"ACCOUNT_INFO_PASSWORD", nil);
    self.mPasswordCell.textField.secureTextEntry = YES;
    self.mPasswordCell.textField.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyPassword].stringParam;
    
    self.mAuthNameCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mAuthNameCell.titleLabel.text = NSLocalizedString(@"ACCOUNT_INFO_AUTHNAME", nil);
    self.mAuthNameCell.textField.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAuthName].stringParam;
    
    self.mServerCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mServerCell.titleLabel.text = NSLocalizedString(@"ACCOUNT_INFO_SERVER", nil);
    self.mServerCell.textField.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyServer].stringParam;
    
    self.mServerRealmCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mServerRealmCell.titleLabel.text = NSLocalizedString(@"ACCOUNT_INFO_SERVER_REALM", nil);
    self.mServerRealmCell.textField.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyServerRealm].stringParam;
    
    self.mPortCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mPortCell.titleLabel.text = NSLocalizedString(@"ACCOUNT_INFO_PORT", nil);
    self.mPortCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyPort].intParam];
    
    self.mTransportCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mTransportCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mTransportCell.textLabel.text = NSLocalizedString(@"ACCOUNT_INFO_TRANSPORT", nil);
    NSInteger transport = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyTransport].enumParam;
    switch (transport) {
        case 0:
            self.mTransportCell.detailTextLabel.text = @"UDP";
            break;
        case 1:
            self.mTransportCell.detailTextLabel.text = @"TCP";
            break;
        case 2:
            self.mTransportCell.detailTextLabel.text = @"TLS";
            break;
        default:
            self.mTransportCell.detailTextLabel.text = nil;
            break;
    }
    
    self.mSipCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mSipCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mSipCell.textLabel.text = NSLocalizedString(@"SIP_SETTING", nil);
    
    self.mAudioCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mAudioCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mAudioCell.textLabel.text = NSLocalizedString(@"AUDIO_SETTING", nil);
    
    self.mVideoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mVideoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mVideoCell.textLabel.text = NSLocalizedString(@"VIDEO_SETTING", nil);
    
    self.mNetworkCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mNetworkCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mNetworkCell.textLabel.text = NSLocalizedString(@"TRANSFER_SETTING", nil);
    
    self.mDeleteCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mDeleteCell.accessoryType = UITableViewCellAccessoryNone;
    self.mDeleteCell.textLabel.textColor = [UIColor redColor];
    self.mDeleteCell.textLabel.text = NSLocalizedString(@"DELETE_ACCOUNT", nil);
}

- (void)save {
    JRAccountConfigParam *nameParam = [[JRAccountConfigParam alloc] init];
    nameParam.stringParam = self.mUsernameCell.textField.text;
    [JRAccount setAccount:self.account config:nameParam forKey:JRAccountConfigKeyName];
    
    JRAccountConfigParam *passwordParam = [[JRAccountConfigParam alloc] init];
    passwordParam.stringParam = self.mPasswordCell.textField.text;
    [JRAccount setAccount:self.account config:passwordParam forKey:JRAccountConfigKeyPassword];
    
    JRAccountConfigParam *authParam = [[JRAccountConfigParam alloc] init];
    authParam.stringParam = self.mAuthNameCell.textField.text;
    [JRAccount setAccount:self.account config:authParam forKey:JRAccountConfigKeyAuthName];
    
    JRAccountConfigParam *ipParam = [[JRAccountConfigParam alloc] init];
    ipParam.stringParam = self.mServerCell.textField.text;
    [JRAccount setAccount:self.account config:ipParam forKey:JRAccountConfigKeyServer];
    
    JRAccountConfigParam *realmParam = [[JRAccountConfigParam alloc] init];
    realmParam.stringParam = self.mServerRealmCell.textField.text;
    [JRAccount setAccount:self.account config:realmParam forKey:JRAccountConfigKeyServerRealm];
    
    JRAccountConfigParam *portParam = [[JRAccountConfigParam alloc] init];
    portParam.intParam = [self.mPortCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:portParam forKey:JRAccountConfigKeyPort];
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return AccountSettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == AccountSettingSectionNormal) {
        return NormalSettingRowCount;
    } else if (section == AccountSettingSectionAdvanced) {
        return AdvancedSettingRowCount;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == AccountSettingSectionNormal) {
        return NSLocalizedString(@"ACCOUNT_INFO_SECTION_COMMON", nil);
    } else if (section == AccountSettingSectionAdvanced) {
        return NSLocalizedString(@"ACCOUNT_INFO_SECTION_ADVANCED", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == AccountSettingSectionNormal) {
        switch (indexPath.row) {
            case NormalSettingRowName:
                return self.mUsernameCell;
            case NormalSettingRowPassword:
                return self.mPasswordCell;
            case NormalSettingRowAuthName:
                return self.mAuthNameCell;
            case NormalSettingRowServer:
                return self.mServerCell;
            case NormalSettingRowRealm:
                return self.mServerRealmCell;
            case NormalSettingRowPort:
                return self.mPortCell;
            case NormalSettingRowTransport:
                return self.mTransportCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == AccountSettingSectionAdvanced) {
        switch (indexPath.row) {
            case AdvancedSettingRowSip:
                return self.mSipCell;
            case AdvancedSettingRowAudio:
                return self.mAudioCell;
            case AdvancedSettingRowVideo:
                return self.mVideoCell;
            case AdvancedSettingRowNet:
                return self.mNetworkCell;
            case AdvancedSettingRowDelete:
                return self.mDeleteCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == AccountSettingSectionNormal) {
        if (indexPath.row == NormalSettingRowTransport) {
            JRAdvancedChooseViewController *view = [[JRAdvancedChooseViewController alloc] init];
            view.account = self.account;
            view.key = JRAccountConfigKeyTransport;
            [self.navigationController pushViewController:view animated:YES];
        }
    } else if (indexPath.section == AccountSettingSectionAdvanced) {
        switch (indexPath.row) {
            case AdvancedSettingRowSip: {
                JRSipSettingsViewController *view =[[JRSipSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                view.account = self.account;
                [self.navigationController pushViewController:view animated:YES];
                break;
            }
            case AdvancedSettingRowAudio: {
                JRAudioSettingsViewController *view =[[JRAudioSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                view.account = self.account;
                [self.navigationController pushViewController:view animated:YES];
                break;
            }
            case AdvancedSettingRowVideo: {
                JRVideoSettingsViewController *view =[[JRVideoSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                view.account = self.account;
                [self.navigationController pushViewController:view animated:YES];
                break;
            }
            case AdvancedSettingRowNet: {
                JRNetSettingsViewController *view = [[JRNetSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                view.account = self.account;
                [self.navigationController pushViewController:view animated:YES];
                break;
            }
            case AdvancedSettingRowDelete:
                if ([JRAccount deleteAccount:self.account]) {
                    self.isDelete = YES;
                    [self.navigationController popViewControllerAnimated:YES];
                }
                break;
            default:
                break;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
