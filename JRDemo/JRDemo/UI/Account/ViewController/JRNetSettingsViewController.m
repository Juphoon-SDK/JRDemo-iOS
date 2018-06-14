//
//  JRNetSettingsViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/11.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRNetSettingsViewController.h"
#import "JREditCell.h"
#import "JRSwitchCell.h"
#import "JRAdvancedChooseViewController.h"

typedef NS_ENUM(NSInteger, NetSettingSection) {
    NetSettingSectionMedia,
    NetSettingSectionNat,
    NetSettingSectionCount,
};

typedef NS_ENUM(NSInteger, MediaSettingRow) {
    MediaSettingRowSrtpEncryptionType,
    MediaSettingRowAudioRtpRtcpPortReuse,
    MediaSettingRowVideoRtpRtcpPortReuse,
    MediaSettingRowCount,
};

typedef NS_ENUM(NSInteger, NatSettingRow) {
    NatSettingRowType,
    NatSettingRowServer,
    NatSettingRowPort,
    NatSettingRowCount,
};

static NSString * const EditCellId = @"EditCellId";
static NSString * const SwitchCellId = @"SwitchCellId";
static NSString * const NormalCellId = @"NormalCellId";

@interface JRNetSettingsViewController ()

// 媒体传输配置
@property (nonatomic, strong) UITableViewCell *mSrtpEncryptionTypeCell;
@property (nonatomic, strong) JRSwitchCell *mAudioRtpRtcpPortReuseCell;
@property (nonatomic, strong) JRSwitchCell *mVideoRtpRtcpPortReuseCell;
// NAT 穿越配置
@property (nonatomic, strong) UITableViewCell *mNatTypeCell;
@property (nonatomic, strong) JREditCell *mNatServerCell;
@property (nonatomic, strong) JREditCell *mNatPortCell;

@end

@implementation JRNetSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"TRANSFER_SETTING", nil);
    [self.tableView registerNib:[UINib nibWithNibName:@"JREditCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:EditCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"JRSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SwitchCellId];
    [self initCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self save];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCell];
    [self.tableView reloadData];
}

- (void)initCell {
    self.mSrtpEncryptionTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mSrtpEncryptionTypeCell.textLabel.text = NSLocalizedString(@"SRTP_ENCRYPTION_TYPE", nil);
    self.mSrtpEncryptionTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger srtpEncryptionType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeySrtpEncryptionType].enumParam;
    switch (srtpEncryptionType) {
        case 0:
            self.mSrtpEncryptionTypeCell.detailTextLabel.text = @"OFF";
            break;
        case 1:
            self.mSrtpEncryptionTypeCell.detailTextLabel.text = @"AES128-HMAC80";
            break;
        case 2:
            self.mSrtpEncryptionTypeCell.detailTextLabel.text = @"AES128-HMAC32";
            break;
        default:
            self.mSrtpEncryptionTypeCell.detailTextLabel.text = nil;
            break;
    }
    
    self.mAudioRtpRtcpPortReuseCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mAudioRtpRtcpPortReuseCell.titleLabel.text = NSLocalizedString(@"AUDIO_RTP_RTCP_PORT_REUSE", nil);
    self.mAudioRtpRtcpPortReuseCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioRtpRtcpPort].boolParam;
    
    self.mVideoRtpRtcpPortReuseCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoRtpRtcpPortReuseCell.titleLabel.text = NSLocalizedString(@"VIDEO_RTP_RTCP_PORT_REUSE", nil);
    self.mVideoRtpRtcpPortReuseCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoRtpRtcpPort].boolParam;
    
    self.mNatTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mNatTypeCell.textLabel.text = NSLocalizedString(@"NAT_TRAVERSAL_TYPE", nil);
    self.mNatTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger natType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyNatType].enumParam;
    switch (natType) {
        case 0:
            self.mNatTypeCell.detailTextLabel.text = @"OFF";
            break;
        case 1:
            self.mNatTypeCell.detailTextLabel.text = @"STUN";
            break;
        case 2:
            self.mNatTypeCell.detailTextLabel.text = @"STUN/TURN";
            break;
        case 3:
            self.mNatTypeCell.detailTextLabel.text = @"STUN/TURN/ICE";
            break;
        default:
            self.mNatTypeCell.detailTextLabel.text = nil;
            break;
    }
    
    self.mNatServerCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mNatServerCell.titleLabel.text = NSLocalizedString(@"STUN_SERVER", nil);
    self.mNatServerCell.textField.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyNatServer].stringParam;
    
    self.mNatPortCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mNatPortCell.titleLabel.text = NSLocalizedString(@"STUN_PORT", nil);
    self.mNatPortCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyNatPort].intParam];
}

- (void)save {
    JRAccountConfigParam *audioParam = [[JRAccountConfigParam alloc] init];
    audioParam.boolParam = self.mAudioRtpRtcpPortReuseCell.switchView.isOn;
    [JRAccount setAccount:self.account config:audioParam forKey:JRAccountConfigKeyAudioRtpRtcpPort];
    
    JRAccountConfigParam *videoParam = [[JRAccountConfigParam alloc] init];
    videoParam.boolParam = self.mVideoRtpRtcpPortReuseCell.switchView.isOn;
    [JRAccount setAccount:self.account config:videoParam forKey:JRAccountConfigKeyVideoRtpRtcpPort];
    
    JRAccountConfigParam *natServeParam = [[JRAccountConfigParam alloc] init];
    natServeParam.stringParam = self.mNatServerCell.textField.text;
    [JRAccount setAccount:self.account config:natServeParam forKey:JRAccountConfigKeyNatServer];
    
    JRAccountConfigParam *natPortParam = [[JRAccountConfigParam alloc] init];
    natPortParam.intParam = [self.mNatPortCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:natPortParam forKey:JRAccountConfigKeyNatPort];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NetSettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == NetSettingSectionMedia) {
        return MediaSettingRowCount;
    } else if (section == NetSettingSectionNat) {
        return NatSettingRowCount;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == NetSettingSectionMedia) {
        return NSLocalizedString(@"MEDIA_TRANSFER_SETTINGS", nil);
    } else if (section == NetSettingSectionNat) {
        return NSLocalizedString(@"NAT_TRANVERSAL_SETTINGS", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == NetSettingSectionMedia) {
        switch (indexPath.row) {
            case MediaSettingRowSrtpEncryptionType:
                return self.mSrtpEncryptionTypeCell;
            case MediaSettingRowAudioRtpRtcpPortReuse:
                return self.mAudioRtpRtcpPortReuseCell;
            case MediaSettingRowVideoRtpRtcpPortReuse:
                return self.mVideoRtpRtcpPortReuseCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == NetSettingSectionNat) {
        switch (indexPath.row) {
            case NatSettingRowType:
                return self.mNatTypeCell;
            case NatSettingRowServer:
                return self.mNatServerCell;
            case NatSettingRowPort:
                return self.mNatPortCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == NetSettingSectionMedia) {
        if (indexPath.row == MediaSettingRowSrtpEncryptionType) {
            JRAdvancedChooseViewController *view = [[JRAdvancedChooseViewController alloc] init];
            view.account = self.account;
            view.key = JRAccountConfigKeySrtpEncryptionType;
            [self.navigationController pushViewController:view animated:YES];
        }
    } else if (indexPath.section == NetSettingSectionNat) {
        if (indexPath.row == NatSettingRowType) {
            JRAdvancedChooseViewController *view = [[JRAdvancedChooseViewController alloc] init];
            view.account = self.account;
            view.key = JRAccountConfigKeyNatType;
            [self.navigationController pushViewController:view animated:YES];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
