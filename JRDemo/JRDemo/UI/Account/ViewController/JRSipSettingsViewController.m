//
//  JRSipSettingsViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRSipSettingsViewController.h"
#import "JREditCell.h"
#import "JRSwitchCell.h"
#import "JRAdvancedChooseViewController.h"

typedef NS_ENUM(NSInteger, SipSettingSection) {
    SipSettingSectionReg,
    SipSettingSectionHeartbeat,
    SipSettingSectionAdvanced,
    SipSettingSectionCount,
};

typedef NS_ENUM(NSInteger, RegSettingRow) {
    RegSettingRowNoDigest,
    RegSettingRowRefreshPeriod,
    RegSettingRowRegSubscribe,
    RegSettingRowRegSubscribePeriod,
    RegSettingRowCount,
};

typedef NS_ENUM(NSInteger, HeartbeatSettingRow) {
    HeartbeatSettingRowType,
    HeartbeatSettingRowPeriodData,
    HeartbeatSettingRowPeriodWifi,
    HeartbeatSettingRowCount,
};

typedef NS_ENUM(NSInteger, AdvancedSettingRow) {
    AdvancedSettingRowTimerType,
    AdvancedSettingRowTimerData,
    AdvancedSettingRowMinimumTimer,
    AdvancedSettingRowTelUri,
    AdvancedSettingRowCount,
};

static NSString * const EditCellId = @"EditCellId";
static NSString * const SwitchCellId = @"SwitchCellId";
static NSString * const NormalCellId = @"NormalCellId";

@interface JRSipSettingsViewController () <JREditCellDelegate>

// 注册
@property (nonatomic, strong) JRSwitchCell *mRegNoDigestCell;
@property (nonatomic, strong) JREditCell *mRegRefreshPeriodCell;
@property (nonatomic, strong) JRSwitchCell *mRegSubscribeCell;
@property (nonatomic, strong) JREditCell *mRegSubscribePeriodCell;
// 心跳
@property (nonatomic, strong) UITableViewCell *mHeartbeatTypeCell;
@property (nonatomic, strong) JREditCell *mHeartbeatPeriodDataCell;
@property (nonatomic, strong) JREditCell *mHeartbeatPeriodWifiCell;
// 高级
@property (nonatomic, strong) UITableViewCell *mTimerTypeCell;
@property (nonatomic, strong) JREditCell *mTimerDataCell;
@property (nonatomic, strong) JREditCell *mMinimumTimerCell;
@property (nonatomic, strong) JRSwitchCell *mTelUriCell;

@end

@implementation JRSipSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SIP_SETTING", nil);
    [self.tableView registerNib:[UINib nibWithNibName:@"JREditCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:EditCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"JRSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SwitchCellId];
    [self initCell];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self save];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCell];
    [self.tableView reloadData];
}

- (void)initCell {
    self.mRegNoDigestCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mRegNoDigestCell.titleLabel.text = NSLocalizedString(@"REG_NO_DIGEST", nil);
    self.mRegNoDigestCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyRegNoDigest].boolParam;
    
    self.mRegRefreshPeriodCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mRegRefreshPeriodCell.titleLabel.text = NSLocalizedString(@"REG_REFRESH_PERIOD", nil);
    self.mRegRefreshPeriodCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyRegRefreshPeriod].intParam];
    self.mRegRefreshPeriodCell.mOnlyNumber = YES;
    [self.mRegRefreshPeriodCell setDelegate:self tableView:self.tableView];
    
    self.mRegSubscribeCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mRegSubscribeCell.titleLabel.text = NSLocalizedString(@"REG_SUBSCRIBE", nil);
    self.mRegSubscribeCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyRegSubScribe].boolParam;
    
    self.mRegSubscribePeriodCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mRegSubscribePeriodCell.titleLabel.text = NSLocalizedString(@"REG_SUBSCRIBE_PERIOD", nil);
    self.mRegSubscribePeriodCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyRegSubscribePeriod].intParam];
    self.mRegSubscribePeriodCell.mOnlyNumber = YES;
    [self.mRegSubscribePeriodCell setDelegate:self tableView:self.tableView];
    
    self.mHeartbeatTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mHeartbeatTypeCell.textLabel.text = NSLocalizedString(@"HEART_BEAT_TYPE", nil);
    self.mHeartbeatTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger heartbeatType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyHeartBeatType].enumParam;
    switch (heartbeatType) {
        case 0:
            self.mHeartbeatTypeCell.detailTextLabel.text = @"DISABLE";
            break;
        case 1:
            self.mHeartbeatTypeCell.detailTextLabel.text = @"SIP";
            break;
        case 2:
            self.mHeartbeatTypeCell.detailTextLabel.text = @"OPTIONS";
            break;
        default:
            self.mHeartbeatTypeCell.detailTextLabel.text = nil;
            break;
    }
    
    self.mHeartbeatPeriodDataCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mHeartbeatPeriodDataCell.titleLabel.text = NSLocalizedString(@"HEART_BEAT_PERIOD_DATA", nil);
    self.mHeartbeatPeriodDataCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyHearBeatPeriodData].intParam];
    self.mHeartbeatPeriodDataCell.mOnlyNumber = YES;
    [self.mHeartbeatPeriodDataCell setDelegate:self tableView:self.tableView];
    
    self.mHeartbeatPeriodWifiCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mHeartbeatPeriodWifiCell.titleLabel.text = NSLocalizedString(@"HEART_BEAT_PERIOD_WIFI", nil);
    self.mHeartbeatPeriodWifiCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyHeartbeatPeriodWifi].intParam];
    self.mHeartbeatPeriodWifiCell.mOnlyNumber = YES;
    [self.mHeartbeatPeriodWifiCell setDelegate:self tableView:self.tableView];
    
    self.mTimerTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mTimerTypeCell.textLabel.text = NSLocalizedString(@"TIMER_TYPE", nil);
    self.mTimerTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger timerType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyTimerType].enumParam;
    switch (timerType) {
        case 0:
            self.mTimerTypeCell.detailTextLabel.text = @"OFF";
            break;
        case 1:
            self.mTimerTypeCell.detailTextLabel.text = @"NEGO";
            break;
        case 2:
            self.mTimerTypeCell.detailTextLabel.text = @"FORCE";
            break;
        default:
            self.mTimerTypeCell.detailTextLabel.text = nil;
            break;
    }
    
    self.mTimerDataCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mTimerDataCell.titleLabel.text = NSLocalizedString(@"TIMER_DATA", nil);
    self.mTimerDataCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyTimerData].intParam];
    self.mTimerDataCell.mOnlyNumber = YES;
    [self.mTimerDataCell setDelegate:self tableView:self.tableView];
    
    self.mMinimumTimerCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mMinimumTimerCell.titleLabel.text = NSLocalizedString(@"MINIMUM_TIMER", nil);
    self.mMinimumTimerCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyMinimumTimer].intParam];
    self.mMinimumTimerCell.mOnlyNumber = YES;
    [self.mMinimumTimerCell setDelegate:self tableView:self.tableView];
    
    self.mTelUriCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mTelUriCell.titleLabel.text = NSLocalizedString(@"TEL_URI", nil);
    self.mTelUriCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyTelUri].boolParam;
}

- (void)save {
    JRAccountConfigParam *regNoDigestParam = [[JRAccountConfigParam alloc] init];
    regNoDigestParam.boolParam = self.mRegNoDigestCell.switchView.isOn;
    [JRAccount setAccount:self.account config:regNoDigestParam forKey:JRAccountConfigKeyRegNoDigest];
    
    JRAccountConfigParam *regRefreshPeriodParam = [[JRAccountConfigParam alloc] init];
    regRefreshPeriodParam.intParam = [self.mRegRefreshPeriodCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:regRefreshPeriodParam forKey:JRAccountConfigKeyRegRefreshPeriod];
    
    JRAccountConfigParam *regSubscribeParam = [[JRAccountConfigParam alloc] init];
    regSubscribeParam.boolParam = self.mRegSubscribeCell.switchView.isOn;
    [JRAccount setAccount:self.account config:regSubscribeParam forKey:JRAccountConfigKeyRegSubScribe];
    
    JRAccountConfigParam *regSubscribePeriodParam = [[JRAccountConfigParam alloc] init];
    regSubscribePeriodParam.intParam = [self.mRegSubscribePeriodCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:regSubscribePeriodParam forKey:JRAccountConfigKeyRegSubscribePeriod];
    
    JRAccountConfigParam *heartbeatPeriodDataParam = [[JRAccountConfigParam alloc] init];
    heartbeatPeriodDataParam.intParam = [self.mHeartbeatPeriodDataCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:heartbeatPeriodDataParam forKey:JRAccountConfigKeyHearBeatPeriodData];
    
    JRAccountConfigParam *heartbeatPeriodWifiParam = [[JRAccountConfigParam alloc] init];
    heartbeatPeriodWifiParam.intParam = [self.mHeartbeatPeriodWifiCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:heartbeatPeriodWifiParam forKey:JRAccountConfigKeyHeartbeatPeriodWifi];
    
    JRAccountConfigParam *timerDataParam = [[JRAccountConfigParam alloc] init];
    timerDataParam.intParam = [self.mTimerDataCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:timerDataParam forKey:JRAccountConfigKeyTimerData];
    
    JRAccountConfigParam *minimumTimerParam = [[JRAccountConfigParam alloc] init];
    minimumTimerParam.intParam = [self.mMinimumTimerCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:minimumTimerParam forKey:JRAccountConfigKeyMinimumTimer];
    
    JRAccountConfigParam *telUriParam = [[JRAccountConfigParam alloc] init];
    telUriParam.boolParam = self.mTelUriCell.switchView.isOn;
    [JRAccount setAccount:self.account config:telUriParam forKey:JRAccountConfigKeyTelUri];
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SipSettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SipSettingSectionReg) {
        return RegSettingRowCount;
    } else if (section == SipSettingSectionHeartbeat) {
        return HeartbeatSettingRowCount;
    } else if (section == SipSettingSectionAdvanced) {
        return AdvancedSettingRowCount;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SipSettingSectionReg) {
        return NSLocalizedString(@"REG", nil);
    } else if (section == SipSettingSectionHeartbeat) {
        return NSLocalizedString(@"HEARTBEAT", nil);
    } else if (section == SipSettingSectionAdvanced) {
        return NSLocalizedString(@"ADVANCED_SETTINGS", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SipSettingSectionReg) {
        switch (indexPath.row) {
            case RegSettingRowNoDigest:
                return self.mRegNoDigestCell;
            case RegSettingRowRefreshPeriod:
                return self.mRegRefreshPeriodCell;
            case RegSettingRowRegSubscribe:
                return self.mRegSubscribeCell;
            case RegSettingRowRegSubscribePeriod:
                return self.mRegSubscribePeriodCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == SipSettingSectionHeartbeat) {
        switch (indexPath.row) {
            case HeartbeatSettingRowType:
                return self.mHeartbeatTypeCell;
            case HeartbeatSettingRowPeriodData:
                return self.mHeartbeatPeriodDataCell;
            case HeartbeatSettingRowPeriodWifi:
                return self.mHeartbeatPeriodWifiCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == SipSettingSectionAdvanced) {
        switch (indexPath.row) {
            case AdvancedSettingRowTimerType:
                return self.mTimerTypeCell;
            case AdvancedSettingRowTimerData:
                return self.mTimerDataCell;
            case AdvancedSettingRowMinimumTimer:
                return self.mMinimumTimerCell;
            case AdvancedSettingRowTelUri:
                return self.mTelUriCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SipSettingSectionHeartbeat) {
        if (indexPath.row == HeartbeatSettingRowType) {
            JRAdvancedChooseViewController *view = [[JRAdvancedChooseViewController alloc] init];
            view.account = self.account;
            view.key = JRAccountConfigKeyHeartBeatType;
            [self.navigationController pushViewController:view animated:YES];
        }
    } else if (indexPath.section == SipSettingSectionAdvanced) {
        if (indexPath.row == AdvancedSettingRowTimerType) {
            JRAdvancedChooseViewController *view = [[JRAdvancedChooseViewController alloc] init];
            view.account = self.account;
            view.key = JRAccountConfigKeyTimerType;
            [self.navigationController pushViewController:view animated:YES];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView outMax:(int)max cell:(JREditCell *)cell {
    [SVProgressHUD showErrorWithStatus:@"超出最大值"];
}

- (void)tableView:(UITableView *)tableView outMin:(int)min cell:(JREditCell *)cell {
    [SVProgressHUD showErrorWithStatus:@"低于最小值"];
}

- (void)tableView:(UITableView *)tableView invalididValue:(JREditCell *)cell {
    [SVProgressHUD showErrorWithStatus:@"不合法的值"];
}

@end
