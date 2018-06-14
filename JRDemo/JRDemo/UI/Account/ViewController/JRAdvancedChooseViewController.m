//
//  JRAdvancedChooseViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/12.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAdvancedChooseViewController.h"

@interface JRAdvancedChooseViewController ()

@property (nonatomic, strong) NSArray *mDataSource;
@property (nonatomic, assign) NSInteger mSelectRow;
@property (nonatomic, assign) BOOL isForbidden;
@property (nonatomic, assign) BOOL isValueChanged;

@end

@implementation JRAdvancedChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configArray];
    JRAccountConfigParam *param = [JRAccount getAccountConfig:self.account forKey:self.key];
    if (self.key == JRAccountConfigKeyVideoResolution) {
        // 分辨率
        if ([param.stringParam isEqualToString:@"176X144"]) {
            self.mSelectRow = 0;
        } else if ([param.stringParam isEqualToString:@"240X160"]) {
            self.mSelectRow = 1;
        } else if ([param.stringParam isEqualToString:@"312X208"]) {
            self.mSelectRow = 2;
        } else if ([param.stringParam isEqualToString:@"320X240"]) {
            self.mSelectRow = 3;
        } else if ([param.stringParam isEqualToString:@"352X288"]) {
            self.mSelectRow = 4;
        } else if ([param.stringParam isEqualToString:@"480X320"]) {
            self.mSelectRow = 5;
        } else if ([param.stringParam isEqualToString:@"640X480"]) {
            self.mSelectRow = 6;
        } else if ([param.stringParam isEqualToString:@"704X576"]) {
            self.mSelectRow = 7;
        } else if ([param.stringParam isEqualToString:@"1280X720"]) {
            self.mSelectRow = 8;
        }
    } else if (self.key == JRAccountConfigKeyAudioBitrate) {
        switch (param.intParam) {
            case 4750:
                self.mSelectRow = 0;
                break;
            case 5150:
                self.mSelectRow = 1;
                break;
            case 5900:
                self.mSelectRow = 2;
                break;
            case 6700:
                self.mSelectRow = 3;
                break;
            case 7400:
                self.mSelectRow = 4;
                break;
            case 7950:
                self.mSelectRow = 5;
                break;
            case 10200:
                self.mSelectRow = 6;
                break;
            case 12200:
                self.mSelectRow = 7;
                break;
            default:
                break;
        }
    } else {
        if (!param.boolParam) {
            // 禁用
            self.isForbidden = YES;
            self.title = NSLocalizedString(@"ALREADY_FORBIDDEN", nil);
            self.navigationItem.rightBarButtonItem = nil;
        } else {
            self.mSelectRow = param.enumParam;
        }
    }
}

- (void)configArray {
    if (self.key == JRAccountConfigKeyTransport) {
        self.mDataSource = @[@"UDP", @"TCP", @"TLS"];
    } else if (self.key == JRAccountConfigKeyHeartBeatType) {
        self.mDataSource = @[@"DISABLE", @"SIP", @"OPTIONS"];
    } else if (self.key == JRAccountConfigKeyTimerType) {
        self.mDataSource = @[@"OFF", @"NEGO", @"FORCE"];
    } else if (self.key == JRAccountConfigKeyDtmfType) {
        self.mDataSource = @[@"AUTO", @"INBAND", @"OUTBAND", @"INFO"];
    } else if (self.key == JRAccountConfigKeyAudioSendAgcType) {
        self.mDataSource = @[@"ANALOG", @"OS", @"DIGITAL", @"FIXED"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FORBIDDEN", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeCofing)];
    } else if (self.key == JRAccountConfigKeyAudioRecvAgcType) {
        self.mDataSource = @[@"FIXED", @"ADAPTIVE"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FORBIDDEN", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeCofing)];
    } else if (self.key == JRAccountConfigKeyAudioSendAnrLevel) {
        self.mDataSource = @[@"LOW", @"MID", @"HIGH", @"VERY HIGH"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FORBIDDEN", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeCofing)];
    } else if (self.key == JRAccountConfigKeyAudioRecvAnrLevel) {
        self.mDataSource = @[@"LOW", @"MID", @"HIGH", @"VERY HIGH"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FORBIDDEN", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeCofing)];
    } else if (self.key == JRAccountConfigKeyDtxType) {
        self.mDataSource = @[@"NORMAL", @"LOW", @"MID", @"HIGH"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FORBIDDEN", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeCofing)];
    } else if (self.key == JRAccountConfigKeyAecType) {
        self.mDataSource = @[@"AEC", @"OS", @"AES", @"AEC-FDE", @"AEC-SDE"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FORBIDDEN", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeCofing)];
    } else if (self.key == JRAccountConfigKeyVideoH264PacketMode) {
        self.mDataSource = @[@"0-SINGLE-NALU", @"1-FU-A"];
    } else if (self.key == JRAccountConfigKeyVideoResolution) {
        self.mDataSource = @[@"176X144", @"240X160", @"312X208", @"320X240", @"352X288", @"480X320", @"640X480", @"704X576", @"1280X720"];
    } else if (self.key == JRAccountConfigKeyVideoKeyFramerateByInfo) {
        self.mDataSource = @[@"OFF", @"INFO", @"RTCP"];
    } else if (self.key == JRAccountConfigKeySrtpEncryptionType) {
        self.mDataSource = @[@"OFF", @"AES128-HMAC80", @"AES128-HMAC32"];
    } else if (self.key == JRAccountConfigKeyNatType) {
        self.mDataSource = @[@"OFF", @"STUN", @"STUN/TURN", @"STUN/TURN/ICE"];
    } else if (self.key == JRAccountConfigKeyAudioBitrate) {
        self.mDataSource = @[@"4750", @"5150", @"5900", @"6700", @"7400", @"7950", @"10200", @"12200"];
    }
}

- (void)closeCofing {
    JRAccountConfigParam *param = [[JRAccountConfigParam alloc] init];
    param.boolParam = NO;
    if ([JRAccount setAccount:self.account config:param forKey:self.key]) {
        self.isForbidden = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)save {
    JRAccountConfigParam *param = [[JRAccountConfigParam alloc] init];
    param.boolParam = YES;
    
    if (self.isValueChanged && !self.isForbidden) {
        if (self.key == JRAccountConfigKeyVideoResolution) {
            param.stringParam = [self.mDataSource objectAtIndex:self.mSelectRow];
        } else if (self.key == JRAccountConfigKeyAudioBitrate) {
            param.intParam = [[self.mDataSource objectAtIndex:self.mSelectRow] integerValue];
        } else {
            param.boolParam = YES;
            param.enumParam = self.mSelectRow;
        }
        [JRAccount setAccount:self.account config:param forKey:self.key];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self save];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.mDataSource objectAtIndex:indexPath.row];
    if (self.isForbidden) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        if (self.mSelectRow == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.row;
    self.isForbidden = NO;
    self.mSelectRow = index;
    self.isValueChanged = YES;
    [self.tableView reloadData];
}

@end
