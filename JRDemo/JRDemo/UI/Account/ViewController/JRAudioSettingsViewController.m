//
//  JRAudioSettingsViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/11.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAudioSettingsViewController.h"
#import "JREditCell.h"
#import "JRSwitchCell.h"
#import "JRAdvancedCodecViewController.h"
#import "JRAdvancedChooseViewController.h"

typedef NS_ENUM(NSInteger, AudioSettingSection) {
    AudioSettingSectionCodec,
    AudioSettingSectionDtmf,
    AudioSettingSectionAgc,
    AudioSettingSectionAnr,
    AudioSettingSectionJitterBuffer,
    AudioSettingSectionQos,
    AudioSettingSectionCount,
};

typedef NS_ENUM(NSInteger, CodecSettingRow) {
    CodecSettingRowCodec,
    CodecSettingRowBitrate,
    CodecSettingRowPacketTime,
    CodecSettingRowCount,
};

typedef NS_ENUM(NSInteger, DtmfSettingRow) {
    DtmfSettingRowType,
    DtmfSettingRowpayload,
    DtmfSettingRowCount,
};

typedef NS_ENUM(NSInteger, AgcSettingRow) {
    AgcSettingRowSendAgcType,
    AgcSettingRowSendAgc,
    AgcSettingRowRecvAgcType,
    AgcSettingRowRecvAgc,
    AgcSettingRowCount,
};

typedef NS_ENUM(NSInteger, AnrSettingRow) {
    AnrSettingRowSendAnrLevel,
    AnrSettingRowRecvAnrLevel,
    AnrSettingRowCount,
};

typedef NS_ENUM(NSInteger, JitterBufferSettingRow) {
    JitterBufferSettingRowMinimumDelay,
    JitterBufferSettingRowMaximumPacketNumber,
    JitterBufferSettingRowCount,
};

typedef NS_ENUM(NSInteger, QosSettingRow) {
    QosSettingRowDtxType,
    QosSettingRowAecType,
    QosSettingRowAudioFec,
    QosSettingRowAudioCount,
};

static NSString * const EditCellId = @"EditCellId";
static NSString * const SwitchCellId = @"SwitchCellId";
static NSString * const NormalCellId = @"NormalCellId";

@interface JRAudioSettingsViewController () <JREditCellDelegate>

// 编解码
@property (nonatomic, strong) UITableViewCell *mAudioCodecCell;
@property (nonatomic, strong) UITableViewCell *mAudioBitrateCell;
@property (nonatomic, strong) JREditCell *mAudioPacketTimeCell;
// DTMF
@property (nonatomic, strong) UITableViewCell *mDtmfTypeCell;
@property (nonatomic, strong) JREditCell *mDtmfPayloadCell;
// AGC
@property (nonatomic, strong) UITableViewCell *mAudioSendAgcTypeCell;
@property (nonatomic, strong) JREditCell *mAudioSendAgcCell;
@property (nonatomic, strong) UITableViewCell *mAudioRecvAgcTypeCell;
@property (nonatomic, strong) JREditCell *mAudioRecvAgcCell;
// ANR
@property (nonatomic, strong) UITableViewCell *mAudioSendAnrLevelCell;
@property (nonatomic, strong) UITableViewCell *mAudioRecvAnrLevelCell;
// Jitter Buffer
@property (nonatomic, strong) JREditCell *mMinimumDelayCell;
@property (nonatomic, strong) JREditCell *mMaximumPacketNumerCell;
// Qos
@property (nonatomic, strong) UITableViewCell *mDtxTypeCell;
@property (nonatomic, strong) UITableViewCell *mAecTypeCell;
@property (nonatomic, strong) JRSwitchCell *mAudioFecCell;

@end

@implementation JRAudioSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"AUDIO_SETTING", nil);
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
    self.mAudioCodecCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mAudioCodecCell.textLabel.text = NSLocalizedString(@"AUDIO_CODEC", nil);
    self.mAudioCodecCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mAudioCodecCell.detailTextLabel.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioCodec].stringParam;
    
    self.mAudioBitrateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mAudioBitrateCell.textLabel.text = NSLocalizedString(@"AUDIO_BITRATE", nil);
    self.mAudioCodecCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mAudioBitrateCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioBitrate].intParam];
    
    self.mAudioPacketTimeCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mAudioPacketTimeCell.titleLabel.text = NSLocalizedString(@"AUDIO_PACKET_TIME", nil);
    self.mAudioPacketTimeCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioPacketTime].intParam];
    self.mAudioPacketTimeCell.mOnlyNumber = YES;
    [self.mAudioPacketTimeCell setDelegate:self tableView:self.tableView];
    
    self.mDtmfTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mDtmfTypeCell.textLabel.text = NSLocalizedString(@"DTMF_TYPE", nil);
    self.mDtmfTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger dtmfType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyDtmfType].enumParam;
    switch (dtmfType) {
        case 0:
            self.mDtmfTypeCell.detailTextLabel.text = @"AUTO";
            break;
        case 1:
            self.mDtmfTypeCell.detailTextLabel.text = @"INBAND";
            break;
        case 2:
            self.mDtmfTypeCell.detailTextLabel.text = @"OUTBAND";
            break;
        case 3:
            self.mDtmfTypeCell.detailTextLabel.text = @"INFO";
            break;
        default:
            self.mDtmfTypeCell.detailTextLabel.text = nil;
            break;
    }
    
    self.mDtmfPayloadCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mDtmfPayloadCell.titleLabel.text = NSLocalizedString(@"DTMF_PAYLOAD", nil);
    self.mDtmfPayloadCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyDtmfPayload].intParam];
    self.mDtmfPayloadCell.mOnlyNumber = YES;
    self.mDtmfPayloadCell.mMaxNumber = 127;
    self.mDtmfPayloadCell.mMinNumber = 96;
    [self.mDtmfPayloadCell setDelegate:self tableView:self.tableView];
    
    self.mAudioSendAgcTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mAudioSendAgcTypeCell.textLabel.text = NSLocalizedString(@"AUDIO_SEND_AGC_TYPE", nil);
    self.mAudioSendAgcTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger audioSendAgcType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioSendAgcType].enumParam;
    BOOL sendAgcEnable = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioSendAgcType].boolParam;
    if (sendAgcEnable) {
        switch (audioSendAgcType) {
            case 0:
                self.mAudioSendAgcTypeCell.detailTextLabel.text = @"Analog";
                break;
            case 1:
                self.mAudioSendAgcTypeCell.detailTextLabel.text = @"OS";
                break;
            case 2:
                self.mAudioSendAgcTypeCell.detailTextLabel.text = @"Digital";
                break;
            case 3:
                self.mAudioSendAgcTypeCell.detailTextLabel.text = @"Fixed";
                break;
            default:
                self.mAudioSendAgcTypeCell.detailTextLabel.text = nil;
                break;
        }
    } else {
        self.mAudioSendAgcTypeCell.detailTextLabel.text = @"Off";
    }
    
    self.mAudioSendAgcCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mAudioSendAgcCell.titleLabel.text = NSLocalizedString(@"AUDIO_SEND_AGC", nil);
    self.mAudioSendAgcCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioSendAgc].intParam];
    self.mAudioSendAgcCell.mOnlyNumber = YES;
    self.mAudioSendAgcCell.mMaxNumber = 30;
    self.mAudioSendAgcCell.mMinNumber = 0;
    [self.mAudioSendAgcCell setDelegate:self tableView:self.tableView];
    
    self.mAudioRecvAgcTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mAudioRecvAgcTypeCell.textLabel.text = NSLocalizedString(@"AUDIO_RECV_AGC_TYPE", nil);
    self.mAudioRecvAgcTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger audioRecvAgcType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioRecvAgcType].enumParam;
    BOOL recvAgcEnable = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioRecvAgcType].boolParam;
    if (recvAgcEnable) {
        switch (audioRecvAgcType) {
            case 0:
                self.mAudioRecvAgcTypeCell.detailTextLabel.text = @"Fixed";
                break;
            case 1:
                self.mAudioRecvAgcTypeCell.detailTextLabel.text = @"Adaptive";
                break;
            default:
                self.mAudioRecvAgcTypeCell.detailTextLabel.text = nil;
                break;
        }
    } else {
        self.mAudioRecvAgcTypeCell.detailTextLabel.text = @"Off";
    }
    
    self.mAudioRecvAgcCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mAudioRecvAgcCell.titleLabel.text = NSLocalizedString(@"AUDIO_RECV_AGC", nil);
    self.mAudioRecvAgcCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioRecvAgc].intParam];
    self.mAudioRecvAgcCell.mOnlyNumber = YES;
    self.mAudioRecvAgcCell.mMaxNumber = 30;
    self.mAudioRecvAgcCell.mMinNumber = 0;
    [self.mAudioRecvAgcCell setDelegate:self tableView:self.tableView];
    
    self.mAudioSendAnrLevelCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mAudioSendAnrLevelCell.textLabel.text = NSLocalizedString(@"AUDIO_SEND_ANR", nil);
    self.mAudioSendAnrLevelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger audioSendAnrLv = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioSendAnrLevel].enumParam;
    BOOL sendAnrEnable = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioSendAnrLevel].boolParam;
    if (sendAnrEnable) {
        switch (audioSendAnrLv) {
            case 0:
                self.mAudioSendAnrLevelCell.detailTextLabel.text = @"Low";
                break;
            case 1:
                self.mAudioSendAnrLevelCell.detailTextLabel.text = @"Mid";
                break;
            case 2:
                self.mAudioSendAnrLevelCell.detailTextLabel.text = @"High";
                break;
            case 3:
                self.mAudioSendAnrLevelCell.detailTextLabel.text = @"Very High";
                break;
            default:
                self.mAudioSendAnrLevelCell.detailTextLabel.text = nil;
                break;
        }
    } else {
        self.mAudioSendAnrLevelCell.detailTextLabel.text = @"Off";
    }
    
    self.mAudioRecvAnrLevelCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mAudioRecvAnrLevelCell.textLabel.text = NSLocalizedString(@"AUDIO_RECV_ANR", nil);
    self.mAudioRecvAnrLevelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger audioRecvAnrLv = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioRecvAnrLevel].enumParam;
    BOOL recvAnrEnable = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioRecvAnrLevel].boolParam;
    if (recvAnrEnable) {
        switch (audioRecvAnrLv) {
            case 0:
                self.mAudioRecvAnrLevelCell.detailTextLabel.text = @"Low";
                break;
            case 1:
                self.mAudioRecvAnrLevelCell.detailTextLabel.text = @"Mid";
                break;
            case 2:
                self.mAudioRecvAnrLevelCell.detailTextLabel.text = @"High";
                break;
            case 3:
                self.mAudioRecvAnrLevelCell.detailTextLabel.text = @"Very High";
                break;
            default:
                self.mAudioRecvAnrLevelCell.detailTextLabel.text = nil;
                break;
        }
    } else {
        self.mAudioRecvAnrLevelCell.detailTextLabel.text = @"Off";
    }
    
    self.mMinimumDelayCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mMinimumDelayCell.titleLabel.text = NSLocalizedString(@"MINIMUM_DELAY", nil);
    self.mMinimumDelayCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyMinimumDelay].intParam];
    self.mMinimumDelayCell.mOnlyNumber = YES;
    [self.mMinimumDelayCell setDelegate:self tableView:self.tableView];
    
    self.mMaximumPacketNumerCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mMaximumPacketNumerCell.titleLabel.text = NSLocalizedString(@"MAXIMUM_PACKET_NUMBER", nil);
    self.mMaximumPacketNumerCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyMaximumPacketNumer].intParam];
    self.mMaximumPacketNumerCell.mOnlyNumber = YES;
    [self.mMaximumPacketNumerCell setDelegate:self tableView:self.tableView];
    
    self.mDtxTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mDtxTypeCell.textLabel.text = NSLocalizedString(@"DTX_TYPE", nil);
    self.mDtxTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger dtxType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyDtxType].enumParam;
    BOOL dtxEnable = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyDtxType].boolParam;
    if (dtxEnable) {
        switch (dtxType) {
            case 0:
                self.mDtxTypeCell.detailTextLabel.text = @"Normal";
                break;
            case 1:
                self.mDtxTypeCell.detailTextLabel.text = @"Low";
                break;
            case 2:
                self.mDtxTypeCell.detailTextLabel.text = @"Mid";
                break;
            case 3:
                self.mDtxTypeCell.detailTextLabel.text = @"High";
                break;
            default:
                self.mDtxTypeCell.detailTextLabel.text = nil;
                break;
        }
    } else {
        self.mDtxTypeCell.detailTextLabel.text = @"Off";
    }
    
    self.mAecTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mAecTypeCell.textLabel.text = NSLocalizedString(@"AEC_TYPE", nil);
    self.mAecTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger aecType = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAecType].enumParam;
    BOOL aecEnable = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAecType].boolParam;
    if (aecEnable) {
        switch (aecType) {
            case 0:
                self.mAecTypeCell.detailTextLabel.text = @"AEC";
                break;
            case 1:
                self.mAecTypeCell.detailTextLabel.text = @"OS";
                break;
            case 2:
                self.mAecTypeCell.detailTextLabel.text = @"AES";
                break;
            case 3:
                self.mAecTypeCell.detailTextLabel.text = @"AEC-FDE";
                break;
            case 4:
                self.mAecTypeCell.detailTextLabel.text = @"AEC-SDE";
                break;
            default:
                self.mAecTypeCell.detailTextLabel.text = nil;
                break;
        }
    } else {
        self.mAecTypeCell.detailTextLabel.text = @"Off";
    }
    
    self.mAudioFecCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mAudioFecCell.titleLabel.text = NSLocalizedString(@"AUDIO_FEC", nil);
    self.mAudioFecCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioFec].boolParam;
}

- (void)save {
    JRAccountConfigParam *packetTimeParam = [[JRAccountConfigParam alloc] init];
    packetTimeParam.intParam = [self.mAudioPacketTimeCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:packetTimeParam forKey:JRAccountConfigKeyAudioPacketTime];
    
    JRAccountConfigParam *dtmfPayloadParam = [[JRAccountConfigParam alloc] init];
    dtmfPayloadParam.intParam = [self.mDtmfPayloadCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:dtmfPayloadParam forKey:JRAccountConfigKeyDtmfPayload];
    
    JRAccountConfigParam *sendAgcParam = [[JRAccountConfigParam alloc] init];
    sendAgcParam.intParam = [self.mAudioSendAgcCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:sendAgcParam forKey:JRAccountConfigKeyAudioSendAgc];
    
    JRAccountConfigParam *recvAgcParam = [[JRAccountConfigParam alloc] init];
    recvAgcParam.intParam = [self.mAudioRecvAgcCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:recvAgcParam forKey:JRAccountConfigKeyAudioRecvAgc];
    
    JRAccountConfigParam *minimumDelayParam = [[JRAccountConfigParam alloc] init];
    minimumDelayParam.intParam = [self.mMinimumDelayCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:minimumDelayParam forKey:JRAccountConfigKeyMinimumDelay];
    
    JRAccountConfigParam *maximumPacketNumerParam = [[JRAccountConfigParam alloc] init];
    maximumPacketNumerParam.intParam = [self.mMaximumPacketNumerCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:maximumPacketNumerParam forKey:JRAccountConfigKeyMaximumPacketNumer];
    
    JRAccountConfigParam *audioFecParam = [[JRAccountConfigParam alloc] init];
    audioFecParam.boolParam = self.mAudioFecCell.switchView.isOn;
    [JRAccount setAccount:self.account config:audioFecParam forKey:JRAccountConfigKeyAudioFec];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return AudioSettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == AudioSettingSectionCodec) {
        return CodecSettingRowCount;
    } else if (section == AudioSettingSectionDtmf) {
        return DtmfSettingRowCount;
    } else if (section == AudioSettingSectionAgc) {
        return AgcSettingRowCount;
    } else if (section == AudioSettingSectionAnr) {
        return AnrSettingRowCount;
    } else if (section == AudioSettingSectionJitterBuffer) {
        return JitterBufferSettingRowCount;
    } else if (section == AudioSettingSectionQos) {
        return QosSettingRowAudioCount;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == AudioSettingSectionCodec) {
        return NSLocalizedString(@"AUDIO_CODEC", nil);
    } else if (section == AudioSettingSectionDtmf) {
        return NSLocalizedString(@"DTMF", nil);
    } else if (section == AudioSettingSectionAgc) {
        return NSLocalizedString(@"AGC", nil);
    } else if (section == AudioSettingSectionAnr) {
        return NSLocalizedString(@"ANR", nil);
    } else if (section == AudioSettingSectionJitterBuffer) {
        return NSLocalizedString(@"JITTER_BUFFER", nil);
    } else if (section == AudioSettingSectionQos) {
        return NSLocalizedString(@"AUDIO_QOS_SETTINGS", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == AudioSettingSectionCodec) {
        switch (indexPath.row) {
            case CodecSettingRowCodec:
                return self.mAudioCodecCell;
            case CodecSettingRowBitrate:
                return self.mAudioBitrateCell;
            case CodecSettingRowPacketTime:
                return self.mAudioPacketTimeCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == AudioSettingSectionDtmf) {
        switch (indexPath.row) {
            case DtmfSettingRowType:
                return self.mDtmfTypeCell;
            case DtmfSettingRowpayload:
                return self.mDtmfPayloadCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == AudioSettingSectionAgc) {
        switch (indexPath.row) {
            case AgcSettingRowSendAgcType:
                return self.mAudioSendAgcTypeCell;
            case AgcSettingRowSendAgc:
                return self.mAudioSendAgcCell;
            case AgcSettingRowRecvAgcType:
                return self.mAudioRecvAgcTypeCell;
            case AgcSettingRowRecvAgc:
                return self.mAudioRecvAgcCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == AudioSettingSectionAnr) {
        switch (indexPath.row) {
            case AnrSettingRowSendAnrLevel:
                return self.mAudioSendAnrLevelCell;
            case AnrSettingRowRecvAnrLevel:
                return self.mAudioRecvAnrLevelCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == AudioSettingSectionJitterBuffer) {
        switch (indexPath.row) {
            case JitterBufferSettingRowMinimumDelay:
                return self.mMinimumDelayCell;
            case JitterBufferSettingRowMaximumPacketNumber:
                return self.mMaximumPacketNumerCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == AudioSettingSectionQos) {
        switch (indexPath.row) {
            case QosSettingRowDtxType:
                return self.mDtxTypeCell;
            case QosSettingRowAecType:
                return self.mAecTypeCell;
            case QosSettingRowAudioFec:
                return self.mAudioFecCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JRAdvancedChooseViewController *view = [[JRAdvancedChooseViewController alloc] init];
    view.account = self.account;
    BOOL shouldPush = NO;
    if (indexPath.section == AudioSettingSectionCodec) {
        if (indexPath.row == CodecSettingRowCodec) {
            JRAdvancedCodecViewController *view = [[JRAdvancedCodecViewController alloc] initWithStyle:UITableViewStyleGrouped];
            view.codecType = JRAccountConfigKeyAudioCodec;
            view.account = self.account;
            [self.navigationController pushViewController:view animated:YES];
        } else if (indexPath.row == CodecSettingRowBitrate) {
            view.key = JRAccountConfigKeyAudioBitrate;
            shouldPush = YES;
        }
    } else if (indexPath.section == AudioSettingSectionDtmf) {
        if (indexPath.row == DtmfSettingRowType) {
            view.key = JRAccountConfigKeyDtmfType;
            shouldPush = YES;
        }
    } else if (indexPath.section == AudioSettingSectionAgc) {
        if (indexPath.row == AgcSettingRowSendAgcType) {
            view.key = JRAccountConfigKeyAudioSendAgcType;
            shouldPush = YES;
        } else if (indexPath.row == AgcSettingRowRecvAgcType) {
            view.key = JRAccountConfigKeyAudioRecvAgcType;
            shouldPush = YES;
        }
    } else if (indexPath.section == AudioSettingSectionAnr) {
        if (indexPath.row == AnrSettingRowSendAnrLevel) {
            view.key = JRAccountConfigKeyAudioSendAnrLevel;
            shouldPush = YES;
        } else if (indexPath.row == AnrSettingRowRecvAnrLevel) {
            view.key = JRAccountConfigKeyAudioRecvAnrLevel;
            shouldPush = YES;
        }
    } else if (indexPath.section == AudioSettingSectionQos) {
        if (indexPath.row == QosSettingRowDtxType) {
            view.key = JRAccountConfigKeyDtxType;
            shouldPush = YES;
        } else if (indexPath.row == QosSettingRowAecType) {
            view.key = JRAccountConfigKeyAecType;
            shouldPush = YES;
        }
    }
    if (shouldPush) {
        [self.navigationController pushViewController:view animated:YES];
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
