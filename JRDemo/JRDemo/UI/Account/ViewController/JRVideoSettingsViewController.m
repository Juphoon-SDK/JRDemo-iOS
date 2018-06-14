//
//  JRVideoSettingsViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/11.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRVideoSettingsViewController.h"
#import "JREditCell.h"
#import "JRSwitchCell.h"
#import "JRAdvancedCodecViewController.h"
#import "JRAdvancedChooseViewController.h"

typedef NS_ENUM(NSInteger, VideoSettingSection) {
    VideoSettingSectionCodec,
    VideoSettingSectionBitrate,
    VideoSettingSectionResolution,
    VideoSettingSectionFramerate,
    VideoSettingSectionQos,
    VideoSettingSectionCount,
};

typedef NS_ENUM(NSInteger, CodecSettingsRow) {
    CodecSettingsRowCodec,
    CodecSettingsRowH264PacketMode,
    CodecSettingsRowPayload,
    CodecSettingsRowCount,
};

typedef NS_ENUM(NSInteger, BitrateSettingsRow) {
    BitrateSettingsRowBitrate,
    BitrateSettingsRowArs,
    BitrateSettingsRowCount,
};

typedef NS_ENUM(NSInteger, ResolutionSettingsRow) {
    ResolutionSettingsRowResolution,
    ResolutionSettingsRowAutoResolution,
    ResolutionSettingsRowCount,
};

typedef NS_ENUM(NSInteger, FramerateSettingsRow) {
    FramerateSettingsRowFramerate,
    FramerateSettingsRowAutoFramerate,
    FramerateSettingsRowCount,
};

typedef NS_ENUM(NSInteger, QosSettingsRow) {
    QosSettingsRowFrameratePeriod,
    QosSettingsRowFramerateByInfo,
    QosSettingsRowRpsi,
    QosSettingsRowFec,
    QosSettingsRowNack,
    QosSettingsRowRtx,
    QosSettingsRowBem,
    QosSettingsRowOrient,
    QosSettingsRowCount,
};

static NSString * const EditCellId = @"EditCellId";
static NSString * const SwitchCellId = @"SwitchCellId";
static NSString * const NormalCellId = @"NormalCellId";

@interface JRVideoSettingsViewController () <JREditCellDelegate>

// 视频编解码
@property (nonatomic, strong) UITableViewCell *mVideoCodecCell;
@property (nonatomic, strong) UITableViewCell *mVideoH264PacketModeCell;
@property (nonatomic, strong) JREditCell *mVideoH264PayloadCell;
// 视频码率
@property (nonatomic, strong) JREditCell *mVideoBitrateCell;
@property (nonatomic, strong) JRSwitchCell *mVideoArsCell;
// 视频分辨率
@property (nonatomic, strong) UITableViewCell *mVideoResolutionCell;
@property (nonatomic, strong) JRSwitchCell *mVideoAutoResolutionCell;
// 视频帧率
@property (nonatomic, strong) JREditCell *mVideoFramerateCell;
@property (nonatomic, strong) JRSwitchCell *mVideoAutoFramerateCell;
// Qos
@property (nonatomic, strong) JREditCell *mVideoKeyFrameratePeriodCell;
@property (nonatomic, strong) UITableViewCell *mVideoKeyFramerateByInfoCell;
@property (nonatomic, strong) JRSwitchCell *mVideoRpsiCell;
@property (nonatomic, strong) JRSwitchCell *mVideoFecCell;
@property (nonatomic, strong) JRSwitchCell *mVideoNackCell;
@property (nonatomic, strong) JRSwitchCell *mVideoRtxCell;
@property (nonatomic, strong) JRSwitchCell *mVideoBemCell;
@property (nonatomic, strong) JRSwitchCell *mVideoOrientCell;

@end

@implementation JRVideoSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"VIDEO_SETTING", nil);
    [self.tableView registerNib:[UINib nibWithNibName:@"JREditCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:EditCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"JRSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SwitchCellId];
    [self initCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    self.mVideoCodecCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mVideoCodecCell.textLabel.text = NSLocalizedString(@"VIDEO_CODEC", nil);
    self.mVideoCodecCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mVideoCodecCell.detailTextLabel.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoCodec].stringParam;
    
    self.mVideoH264PacketModeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mVideoH264PacketModeCell.textLabel.text = NSLocalizedString(@"VIDEO_H264_PACKET_MODE", nil);
    self.mVideoH264PacketModeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger packetMode = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoH264PacketMode].enumParam;
    switch (packetMode) {
        case 0:
            self.mVideoH264PacketModeCell.detailTextLabel.text = @"0-SINGLE-NALU";
            break;
        case 1:
            self.mVideoH264PacketModeCell.detailTextLabel.text = @"1-FU-A";
            break;
        default:
            self.mVideoH264PacketModeCell.detailTextLabel.text = nil;
            break;
    }
    
    self.mVideoH264PayloadCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mVideoH264PayloadCell.titleLabel.text = NSLocalizedString(@"VIDEO_H264_PAYLOAD", nil);
    self.mVideoH264PayloadCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoH264Payload].intParam];
    self.mVideoH264PayloadCell.mOnlyNumber = YES;
    self.mVideoH264PayloadCell.mMaxNumber = 127;
    self.mVideoH264PayloadCell.mMinNumber = 118;
    [self.mVideoH264PayloadCell setDelegate:self tableView:self.tableView];
    
    self.mVideoBitrateCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mVideoBitrateCell.titleLabel.text = NSLocalizedString(@"VIDEO_BITRATE", nil);
    self.mVideoBitrateCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoBitrate].intParam];
    self.mVideoBitrateCell.mOnlyNumber = YES;
    [self.mVideoBitrateCell setDelegate:self tableView:self.tableView];
    
    self.mVideoArsCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoArsCell.titleLabel.text = NSLocalizedString(@"VIDEO_ARS", nil);
    self.mVideoArsCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoArs].boolParam;
    
    self.mVideoResolutionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mVideoResolutionCell.textLabel.text = NSLocalizedString(@"VIDEO_RESOLUTION", nil);
    self.mVideoResolutionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.mVideoResolutionCell.detailTextLabel.text = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoResolution].stringParam;
    
    self.mVideoAutoResolutionCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoAutoResolutionCell.titleLabel.text = NSLocalizedString(@"VIDEO_AUTO_RESOLUTION", nil);
    self.mVideoAutoResolutionCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoAutoResolution].boolParam;
    
    self.mVideoFramerateCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mVideoFramerateCell.titleLabel.text = NSLocalizedString(@"VIDEO_FRAMERATE", nil);
    self.mVideoFramerateCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoFramerate].intParam];
    self.mVideoFramerateCell.mOnlyNumber = YES;
    self.mVideoFramerateCell.mMaxNumber = 30;
    self.mVideoFramerateCell.mMinNumber = 0;
    [self.mVideoFramerateCell setDelegate:self tableView:self.tableView];
    
    self.mVideoAutoFramerateCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoAutoFramerateCell.titleLabel.text = NSLocalizedString(@"VIDEO_AUTO_FRAMERATE", nil);
    self.mVideoAutoFramerateCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoAutoFramerate].boolParam;
    
    self.mVideoKeyFrameratePeriodCell = [self.tableView dequeueReusableCellWithIdentifier:EditCellId];
    self.mVideoKeyFrameratePeriodCell.titleLabel.text = NSLocalizedString(@"VIDEO_KEY_FRAMERATE_PERIOD", nil);
    self.mVideoKeyFrameratePeriodCell.textField.text = [NSString stringWithFormat:@"%ld", (long)[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoKeyFrameratePeriod].intParam];
    self.mVideoKeyFrameratePeriodCell.mOnlyNumber = YES;
    self.mVideoKeyFrameratePeriodCell.mMaxNumber = 600000;
    self.mVideoKeyFrameratePeriodCell.mMinNumber = 0;
    [self.mVideoKeyFrameratePeriodCell setDelegate:self tableView:self.tableView];
    
    self.mVideoKeyFramerateByInfoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellId];
    self.mVideoKeyFramerateByInfoCell.textLabel.text = NSLocalizedString(@"VIDEO_KEY_FRAMERATE_BY_INFO", nil);
    self.mVideoKeyFramerateByInfoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger framerateByInfo = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoKeyFramerateByInfo].enumParam;
    switch (framerateByInfo) {
        case 0:
            self.mVideoKeyFramerateByInfoCell.detailTextLabel.text = @"Off";
            break;
        case 1:
            self.mVideoKeyFramerateByInfoCell.detailTextLabel.text = @"Info";
            break;
        case 2:
            self.mVideoKeyFramerateByInfoCell.detailTextLabel.text = @"RTCP";
            break;
        default:
            self.mVideoKeyFramerateByInfoCell.detailTextLabel.text = nil;
            break;
    }
    
    self.mVideoRpsiCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoRpsiCell.titleLabel.text = NSLocalizedString(@"VIDEO_RPSI", nil);
    self.mVideoRpsiCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoRpsi].boolParam;
    
    self.mVideoFecCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoFecCell.titleLabel.text = NSLocalizedString(@"VIDEO_FEC", nil);
    self.mVideoFecCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoFec].boolParam;
    
    self.mVideoNackCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoNackCell.titleLabel.text = NSLocalizedString(@"VIDEO_NACK", nil);
    self.mVideoNackCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoNack].boolParam;
    
    self.mVideoRtxCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoRtxCell.titleLabel.text = NSLocalizedString(@"VIDEO_RTX", nil);
    self.mVideoRtxCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoRtx].boolParam;
    
    self.mVideoBemCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoBemCell.titleLabel.text = NSLocalizedString(@"VIDEO_BEM", nil);
    self.mVideoBemCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoBem].boolParam;
    
    self.mVideoOrientCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mVideoOrientCell.titleLabel.text = NSLocalizedString(@"VIDEO_ORIENT", nil);
    self.mVideoOrientCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoOrient].boolParam;
}

- (void)save {
    JRAccountConfigParam *videoH264PayloadParam = [[JRAccountConfigParam alloc] init];
    videoH264PayloadParam.intParam = [self.mVideoH264PayloadCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:videoH264PayloadParam forKey:JRAccountConfigKeyVideoH264Payload];
    
    JRAccountConfigParam *videoBitrateParam = [[JRAccountConfigParam alloc] init];
    videoBitrateParam.intParam = [self.mVideoBitrateCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:videoBitrateParam forKey:JRAccountConfigKeyVideoBitrate];
    
    JRAccountConfigParam *videoArsParam = [[JRAccountConfigParam alloc] init];
    videoArsParam.boolParam = self.mVideoArsCell.switchView.on;
    [JRAccount setAccount:self.account config:videoArsParam forKey:JRAccountConfigKeyVideoArs];
    
    JRAccountConfigParam *videoAutoResolutionParam = [[JRAccountConfigParam alloc] init];
    videoAutoResolutionParam.boolParam = self.mVideoAutoResolutionCell.switchView.on;
    [JRAccount setAccount:self.account config:videoAutoResolutionParam forKey:JRAccountConfigKeyVideoAutoResolution];
    
    JRAccountConfigParam *videoFramerateParam = [[JRAccountConfigParam alloc] init];
    videoFramerateParam.intParam = [self.mVideoFramerateCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:videoFramerateParam forKey:JRAccountConfigKeyVideoFramerate];
    
    JRAccountConfigParam *videoAutoFramerateParam = [[JRAccountConfigParam alloc] init];
    videoAutoFramerateParam.boolParam = self.mVideoAutoFramerateCell.switchView.on;
    [JRAccount setAccount:self.account config:videoAutoFramerateParam forKey:JRAccountConfigKeyVideoAutoFramerate];
    
    JRAccountConfigParam *videoFrameratePeriodParam = [[JRAccountConfigParam alloc] init];
    videoFrameratePeriodParam.intParam = [self.mVideoKeyFrameratePeriodCell.textField.text integerValue];
    [JRAccount setAccount:self.account config:videoFrameratePeriodParam forKey:JRAccountConfigKeyVideoKeyFrameratePeriod];
    
    JRAccountConfigParam *videoRpsiParam = [[JRAccountConfigParam alloc] init];
    videoRpsiParam.boolParam = self.mVideoRpsiCell.switchView.on;
    [JRAccount setAccount:self.account config:videoRpsiParam forKey:JRAccountConfigKeyVideoRpsi];
    
    JRAccountConfigParam *videoFecParam = [[JRAccountConfigParam alloc] init];
    videoFecParam.boolParam = self.mVideoFecCell.switchView.on;
    [JRAccount setAccount:self.account config:videoFecParam forKey:JRAccountConfigKeyVideoFec];
    
    JRAccountConfigParam *videoNackParam = [[JRAccountConfigParam alloc] init];
    videoNackParam.boolParam = self.mVideoNackCell.switchView.on;
    [JRAccount setAccount:self.account config:videoNackParam forKey:JRAccountConfigKeyVideoNack];
    
    JRAccountConfigParam *videoRtxParam = [[JRAccountConfigParam alloc] init];
    videoRtxParam.boolParam = self.mVideoRtxCell.switchView.on;
    [JRAccount setAccount:self.account config:videoRtxParam forKey:JRAccountConfigKeyVideoRtx];
    
    JRAccountConfigParam *videoBemParam = [[JRAccountConfigParam alloc] init];
    videoBemParam.boolParam = self.mVideoBemCell.switchView.on;
    [JRAccount setAccount:self.account config:videoBemParam forKey:JRAccountConfigKeyVideoBem];
    
    JRAccountConfigParam *videoOrientParam = [[JRAccountConfigParam alloc] init];
    videoOrientParam.boolParam = self.mVideoOrientCell.switchView.on;
    [JRAccount setAccount:self.account config:videoOrientParam forKey:JRAccountConfigKeyVideoOrient];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return VideoSettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == VideoSettingSectionCodec) {
        return CodecSettingsRowCount;
    } else if (section == VideoSettingSectionBitrate) {
        return BitrateSettingsRowCount;
    } else if (section == VideoSettingSectionResolution) {
        return ResolutionSettingsRowCount;
    } else if (section == VideoSettingSectionFramerate) {
        return FramerateSettingsRowCount;
    } else if (section == VideoSettingSectionQos) {
        return QosSettingsRowCount;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == VideoSettingSectionCodec) {
        return NSLocalizedString(@"VIDEO_CODEC", nil);
    } else if (section == VideoSettingSectionBitrate) {
        return NSLocalizedString(@"VIDEO_BITRATE_SETTINGS", nil);
    } else if (section == VideoSettingSectionResolution) {
        return NSLocalizedString(@"VIDEO_RESOLUTION_SETTINGS", nil);
    } else if (section == VideoSettingSectionFramerate) {
        return NSLocalizedString(@"VIDEO_FRAMERATE_SETTINGS", nil);
    } else if (section == VideoSettingSectionQos) {
        return NSLocalizedString(@"VIDEO_QOS_SETTINGS", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VideoSettingSectionCodec) {
        switch (indexPath.row) {
            case CodecSettingsRowCodec:
                return self.mVideoCodecCell;
            case CodecSettingsRowH264PacketMode:
                return self.mVideoH264PacketModeCell;
            case CodecSettingsRowPayload:
                return self.mVideoH264PayloadCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == VideoSettingSectionBitrate) {
        switch (indexPath.row) {
            case BitrateSettingsRowBitrate:
                return self.mVideoBitrateCell;
            case BitrateSettingsRowArs:
                return self.mVideoArsCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == VideoSettingSectionResolution) {
        switch (indexPath.row) {
            case ResolutionSettingsRowResolution:
                return self.mVideoResolutionCell;
            case ResolutionSettingsRowAutoResolution:
                return self.mVideoAutoResolutionCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == VideoSettingSectionFramerate) {
        switch (indexPath.row) {
            case FramerateSettingsRowFramerate:
                return self.mVideoFramerateCell;
            case FramerateSettingsRowAutoFramerate:
                return self.mVideoAutoFramerateCell;
            default:
                return [[UITableViewCell alloc] init];
        }
    } else if (indexPath.section == VideoSettingSectionQos) {
        switch (indexPath.row) {
            case QosSettingsRowFrameratePeriod:
                return self.mVideoKeyFrameratePeriodCell;
            case QosSettingsRowFramerateByInfo:
                return self.mVideoKeyFramerateByInfoCell;
            case QosSettingsRowRpsi:
                return self.mVideoRpsiCell;
            case QosSettingsRowFec:
                return self.mVideoFecCell;
            case QosSettingsRowNack:
                return self.mVideoNackCell;
            case QosSettingsRowRtx:
                return self.mVideoRtxCell;
            case QosSettingsRowBem:
                return self.mVideoBemCell;
            case QosSettingsRowOrient:
                return self.mVideoOrientCell;
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
    if (indexPath.section == VideoSettingSectionCodec) {
        if (indexPath.row == CodecSettingsRowCodec) {
            JRAdvancedCodecViewController *view = [[JRAdvancedCodecViewController alloc] initWithStyle:UITableViewStyleGrouped];
            view.codecType = JRAccountConfigKeyVideoCodec;
            view.account = self.account;
            [self.navigationController pushViewController:view animated:YES];
        } else if (indexPath.row == CodecSettingsRowH264PacketMode) {
            view.key = JRAccountConfigKeyVideoH264PacketMode;
            shouldPush = YES;
        }
    } else if (indexPath.section == VideoSettingSectionResolution) {
        if (indexPath.row == ResolutionSettingsRowResolution) {
            view.key = JRAccountConfigKeyVideoResolution;
            shouldPush = YES;
        }
    } else if (indexPath.section == VideoSettingSectionQos) {
        if (indexPath.row == QosSettingsRowFramerateByInfo) {
            view.key = JRAccountConfigKeyVideoKeyFramerateByInfo;
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
