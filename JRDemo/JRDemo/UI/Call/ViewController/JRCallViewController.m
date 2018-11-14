//
//  JRCallViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/1/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRCallViewController.h"
#import "JRCallManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JRCallMemberCell.h"
#import "JRMultiVideoCell.h"
#import "JRClientManager.h"
#import "JRNumberUtil.h"
#import "JRMultiVideoCollectionViewCell.h"
#import "JRAutoConfigManager.h"

#define MemberCell @"JRCallMemberCell"
#define MultiVideoCell @"JRMultiVideoCell"

@interface JRCallViewController () <JRMediaDeviceCallback, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSTimer *_timer;
    BOOL _videoActionHidden;
}

@property (weak, nonatomic) IBOutlet UIView *callView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UIView *audioIncomingView;
@property (weak, nonatomic) IBOutlet UIView *declineView;
@property (weak, nonatomic) IBOutlet UIView *audioActionView;

@property (weak, nonatomic) IBOutlet UIView *videoIncomingView;
@property (weak, nonatomic) IBOutlet UIView *videoActionView;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *holdBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *confHoldBtn;
@property (weak, nonatomic) IBOutlet UIButton *confAddBtn;
@property (weak, nonatomic) IBOutlet UIButton *confSwitchCameraBtn;

@property (weak, nonatomic) IBOutlet UIView *statisticsView;
@property (weak, nonatomic) IBOutlet UITextView *statisticsContentTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statisticsSegment;

@property (weak, nonatomic) IBOutlet UIView *dtmfView;
@property (weak, nonatomic) IBOutlet UILabel *dtmfLabel;

@property (weak, nonatomic) IBOutlet UIButton *dtmfBtn;
@property (weak, nonatomic) IBOutlet UIButton *callListBtn;

@property (weak, nonatomic) IBOutlet UIView *multiCallView;
@property (weak, nonatomic) IBOutlet UITableView *multiCallTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *multiCallCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *multiCallCollectionLayout;

@property (nonatomic, strong) JRMediaDeviceVideoCanvas *remote;
@property (nonatomic, strong) JRMediaDeviceVideoCanvas *preview;

@property (nonatomic, strong) NSMutableArray<JRMediaDeviceVideoCanvas *> *canvsArray;

@property (nonatomic, strong) UIAlertController *videoReqAlert;
@property (nonatomic, assign) BOOL videoAlertShow;

@end

static void VibrateCompletionProc(SystemSoundID ssID, void *clientData)
{
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
}

static void vibrate()
{
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, VibrateCompletionProc, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@implementation JRCallViewController

- (instancetype)init {
    if ([super init]) {
        [JRMediaDevice sharedInstance].delegate = self;
        
        self.canvsArray = [[NSMutableArray alloc] init];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(callUpdate:) name:kCallUpdateNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(callAdd:) name:kCallAddNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(callRemove:) name:kCallRemoveNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.multiCallTableView.delegate = self;
    self.multiCallTableView.dataSource = self;
    self.multiCallTableView.tableFooterView = [UIView new];
    [self.multiCallTableView registerNib:[UINib nibWithNibName:@"JRCallMemberCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MemberCell];
    
    self.videoReqAlert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"REQUEST_VIDEO", nil) preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self)
    [self.videoReqAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [[JRCall sharedInstance] answerUpdate:YES];
        self.videoAlertShow = NO;
    }]];
    [self.videoReqAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [[JRCall sharedInstance] answerUpdate:NO];
        self.videoAlertShow = NO;
    }]];
    
    self.multiCallCollectionLayout.minimumInteritemSpacing = 5;
    self.multiCallCollectionLayout.minimumLineSpacing = 5;
    self.multiCallCollectionView.delegate = self;
    self.multiCallCollectionView.dataSource = self;
    [self.multiCallCollectionView registerNib:[UINib nibWithNibName:@"JRMultiVideoCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:MultiVideoCell];

    [self timerProc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startTimer];
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 保证frame
    [self updateVideoView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)updateUI {
    if ([JRCall sharedInstance].currentCall.type == JRCallTypeMultiVideo || [JRCall sharedInstance].currentCall.type == JRCallTypeMultiAudio) {
        self.headerView.hidden = [JRCall sharedInstance].currentCall.state == JRCallStateTalking;
        self.videoActionView.hidden = YES;
        self.audioActionView.hidden = YES;
        self.videoIncomingView.hidden = YES;
        self.dtmfBtn.hidden = YES;
        self.dtmfView.hidden = YES;
        self.confHoldBtn.selected = [JRCall sharedInstance].currentCall.hold;
        self.confSwitchCameraBtn.hidden = [JRCall sharedInstance].currentCall.type == JRCallTypeMultiAudio;
        self.multiCallView.hidden = [JRCall sharedInstance].currentCall.state != JRCallStateTalking;
        self.multiCallCollectionView.hidden = [JRCall sharedInstance].currentCall.type == JRCallTypeMultiAudio;
        self.multiCallTableView.hidden = [JRCall sharedInstance].currentCall.type == JRCallTypeMultiVideo;
        self.callListBtn.hidden = YES;
        self.confAddBtn.enabled = [JRCall sharedInstance].currentCall.direction == JRCallDirectionOut;
        if ([JRCall sharedInstance].currentCall.direction == JRCallDirectionIn) {
            self.audioIncomingView.hidden = [JRCall sharedInstance].currentCall.state >= JRCallStateTalking;
            self.declineView.hidden = [JRCall sharedInstance].currentCall.state < JRCallStateTalking;
        } else {
            self.audioIncomingView.hidden = YES;
            self.declineView.hidden = NO;
        }
    } else if ([JRCall sharedInstance].currentCall.type == JRCallTypeOneOnOneAudio) {
        // 一对一语音
        if (self.preview) {
            [self.preview.videoView removeFromSuperview];
            [[JRMediaDevice sharedInstance] stopVideo:self.preview];
            self.preview = nil;
        }
        if (self.remote) {
            [self.remote.videoView removeFromSuperview];
            [[JRMediaDevice sharedInstance] stopVideo:self.remote];
            self.remote = nil;
        }
        self.headerView.hidden = NO;
        self.videoActionView.hidden = YES;
        self.videoIncomingView.hidden = YES;
        self.multiCallView.hidden = YES;
        if ([JRCall sharedInstance].currentCall.state != JRCallStateTalking) {
            self.dtmfView.hidden = YES;
        }
        self.audioActionView.hidden = [JRCall sharedInstance].currentCall.state != JRCallStateTalking;
        self.dtmfBtn.hidden = [JRCall sharedInstance].currentCall.state != JRCallStateTalking;
        self.holdBtn.selected = [JRCall sharedInstance].currentCall.hold;
        self.holdBtn.enabled = ![JRCall sharedInstance].currentCall.held;
        self.videoBtn.enabled = ![JRCall sharedInstance].currentCall.held;
        if ([JRCall sharedInstance].currentCall.direction == JRCallDirectionIn) {
            self.audioIncomingView.hidden = [JRCall sharedInstance].currentCall.state >= JRCallStateTalking;
            self.declineView.hidden = [JRCall sharedInstance].currentCall.state < JRCallStateTalking;
        } else {
            self.audioIncomingView.hidden = YES;
            self.declineView.hidden = NO;
        }
    } else if ([JRCall sharedInstance].currentCall.type == JRCallTypeOneOnOneVideo) {
        // 一对一视频
        self.audioActionView.hidden = YES;
        self.audioIncomingView.hidden = YES;
        self.multiCallView.hidden = YES;
        self.callListBtn.hidden = YES;
        if ([JRCall sharedInstance].currentCall.direction == JRCallDirectionIn) {
            self.videoIncomingView.hidden = [JRCall sharedInstance].currentCall.state >= JRCallStateTalking;
            self.declineView.hidden = [JRCall sharedInstance].currentCall.state < JRCallStateTalking;
        } else {
            self.videoIncomingView.hidden = YES;
            self.declineView.hidden = NO;
        }
        if (_videoActionHidden) {
            self.videoActionView.hidden = YES;
            self.headerView.hidden = YES;
            self.dtmfBtn.hidden = YES;
            self.dtmfView.hidden = YES;
            self.declineView.hidden = YES;
        } else {
            self.videoActionView.hidden = [JRCall sharedInstance].currentCall.state != JRCallStateTalking;
            self.headerView.hidden = NO;
            self.dtmfBtn.hidden = [JRCall sharedInstance].currentCall.state != JRCallStateTalking;
            if ([JRCall sharedInstance].currentCall.state != JRCallStateTalking) {
                self.dtmfView.hidden = YES;
            }
        }
    }
    
    self.muteBtn.selected = [JRCall sharedInstance].currentCall.mute;
    self.speakerBtn.selected = [JRMediaDevice sharedInstance].speakerOn;
}

- (void)updateVideoView {
    if (!self.preview && ([JRCall sharedInstance].currentCall.type == JRCallTypeOneOnOneVideo || [JRCall sharedInstance].currentCall.type == JRCallTypeMultiVideo)) {
        self.preview = [[JRMediaDevice sharedInstance] startCameraVideo:JRMediaDeviceRenderFullScreen];
        self.preview.videoView.frame = self.view.bounds;
        self.preview.videoView.userInteractionEnabled = YES;
        [self.preview.videoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideOrShowCallView)]];
        [self.callView insertSubview:self.preview.videoView belowSubview:self.headerView];
    }
    if (!self.remote && [JRCall sharedInstance].currentCall.type == JRCallTypeOneOnOneVideo) {
        self.remote = [[JRMediaDevice sharedInstance] startVideo:[JRCall sharedInstance].currentCall.callMembers.firstObject.videoSource renderType:JRMediaDeviceRenderFullScreen];
        self.remote.videoView.frame = self.view.bounds;
        self.remote.videoView.userInteractionEnabled = YES;
        [self.remote.videoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideOrShowCallView)]];
        [self.callView insertSubview:self.remote.videoView belowSubview:self.preview.videoView];
    }
}

- (void)callUpdate:(NSNotification *)notification {
    JRCallUpdateType type = [[notification.userInfo objectForKey:kCallUpdateTypeKey] integerValue];
    JRCallItem *item = [notification.userInfo objectForKey:kCallItemKey];
    if (type == JRCallUpdateTypeOutgoing) {
        if ([item isEqual:[JRCall sharedInstance].currentCall]) {
            if (item.type == JRCallTypeOneOnOneAudio || item.type == JRCallTypeMultiAudio) {
                [[JRMediaDevice sharedInstance] enableSpeaker:NO];
            } else if (item.type == JRCallTypeOneOnOneVideo || item.type == JRCallTypeMultiVideo) {
                [[JRMediaDevice sharedInstance] enableSpeaker:YES];
            }
        }
    }
    if (type == JRCallUpdateTypeTalking) {
        // 震动，扬声器
        if (item.direction == JRCallDirectionOut) {
            vibrate();
        } else {
            if ([item isEqual:[JRCall sharedInstance].currentCall]) {
                if (item.type == JRCallTypeOneOnOneAudio || item.type == JRCallTypeMultiAudio) {
                    [[JRMediaDevice sharedInstance] enableSpeaker:NO];
                } else if (item.type == JRCallTypeOneOnOneVideo || item.type == JRCallTypeMultiVideo) {
                    [[JRMediaDevice sharedInstance] enableSpeaker:YES];
                }
            }
        }
    } else if (type == JRCallUpdateTypeReqVideo) {
        // 收到视频通话请求，切换当前通话，弹出提示框
        self.videoAlertShow = YES;
        [self presentViewController:self.videoReqAlert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.videoAlertShow) {
                @weakify(self)
                [self.videoReqAlert dismissViewControllerAnimated:YES completion:^{
                    @strongify(self)
                    self.videoAlertShow = NO;
                    [SVProgressHUD showErrorWithStatus:@"长时间未响应，已自动拒绝转视频请求"];
                    [[JRCall sharedInstance] answerUpdate:NO];
                }];
            }
        });
    } else if (type == JRCallUpdateTypeToVideoOk) {
        // 音频转视频成功，布局渲染视图
        [self updateVideoView];
        [[JRMediaDevice sharedInstance] enableSpeaker:YES];
    } else if (type == JRCallUpdateTypeToAudioOk) {
        // 视频转音频成功，移除渲染视图
        if (self.preview) {
            [self.preview.videoView removeFromSuperview];
            [[JRMediaDevice sharedInstance] stopVideo:self.preview];
            self.preview = nil;
        }
        if (self.remote) {
            [self.remote.videoView removeFromSuperview];
            [[JRMediaDevice sharedInstance] stopVideo:self.remote];
            self.remote = nil;
        }
        [[JRMediaDevice sharedInstance] enableSpeaker:NO];
    } else if (type == JRCallUpdateConfMemberUpdate) {
        // 多方通话成员更新，刷新界面
        [self.multiCallTableView reloadData];
        [self.multiCallCollectionView reloadData];
    } else if (type == JRCallUpdateTypeToAudioFailed) {
        // 视频转音频失败，提示
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"TO_AUDIO_FAILED", nil)];
    } else if (type == JRCallUpdateTypeToVideoFailed) {
        // 音频转视频失败，提示
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"TO_VIDEO_FAILED", nil)];
    }
    
    if ([item isEqual:[JRCall sharedInstance].currentCall]) {
        // 当前通话状态更新，更新UI
        [self updateUI];
        // 红外线
        if (type == JRCallUpdateTypeTermed) {
            [UIDevice currentDevice].proximityMonitoringEnabled = false;
        }
    }
}

- (void)callAdd:(NSNotification *)notification {
    // 红外线
    [UIDevice currentDevice].proximityMonitoringEnabled = ([JRCall sharedInstance].currentCall.type == JRCallTypeMultiAudio || [JRCall sharedInstance].currentCall.type == JRCallTypeOneOnOneAudio);
}

- (void)callRemove:(NSNotification *)notification {
    JRCallItem *item = [notification.userInfo objectForKey:kCallItemKey];
    JRCallTermReason reason = [[notification.userInfo objectForKey:kCallTermReasonKey] integerValue];
    if (item.type == JRCallTypeMultiVideo || item.type == JRCallTypeOneOnOneVideo) {
        if (self.preview) {
            [self.preview.videoView removeFromSuperview];
            [[JRMediaDevice sharedInstance] stopVideo:self.preview];
            self.preview = nil;
        }
        if (self.remote) {
            [self.remote.videoView removeFromSuperview];
            [[JRMediaDevice sharedInstance] stopVideo:self.remote];
            self.remote = nil;
        }
        for (JRMediaDeviceVideoCanvas *canvas in [self.canvsArray copy]) {
            [[JRMediaDevice sharedInstance] stopVideo:canvas];
            [self.canvsArray removeObject:canvas];
        }
    }
    [self stopTimer];
    [self updateUI];
}

#pragma mark - Button Action

- (IBAction)audioAnswer:(id)sender {
    if ([JRCall sharedInstance].currentCall.type == JRCallTypeMultiVideo) {
        [[JRAutoConfigManager sharedInstance] requestAccessTokenFinishBlock:^(NSString *token) {
            if (token.length) {
                [[JRCall sharedInstance] answer:YES token:token];
            }
        }];
    } else {
        [[JRCall sharedInstance] answer:NO token:nil];
    }
}

- (IBAction)videoAnswer:(id)sender {
    [[JRCall sharedInstance] answer:YES token:nil];
}

- (IBAction)end:(id)sender {
    [[JRCall sharedInstance] end];
}

- (IBAction)mute:(id)sender {
    [[JRCall sharedInstance] mute];
}

- (IBAction)speaker:(id)sender {
    [[JRMediaDevice sharedInstance] enableSpeaker:![JRMediaDevice sharedInstance].speakerOn];
}

- (IBAction)hold:(id)sender {
    [[JRCall sharedInstance] hold];
}

- (IBAction)addCall:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NEW_CALL", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"INPUT_PEER_NUMBER", nil);
        textField.text = nil;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *number = alert.textFields.firstObject.text;
        if (number.length) {
            [[JRCall sharedInstance] call:number video:NO];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)turnVideo:(id)sender {
    [[JRCall sharedInstance] updateCall:YES];
}

- (IBAction)turnAudio:(id)sender {
    [[JRCall sharedInstance] updateCall:NO];
}

- (IBAction)switchCamera:(id)sender {
    [[JRCall sharedInstance] switchCamera];
}

- (IBAction)addMember:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ADD_MEMBER", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"INPUT_PEER_NUMBER", nil);
        textField.text = nil;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *number = alert.textFields.firstObject.text;
        if (number.length) {
            [[JRCall sharedInstance] addMultiCallMember:number];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)hideOrShowCallView {
    _videoActionHidden = !_videoActionHidden;
    [self updateUI];
}

#pragma mark - Statistics

- (IBAction)getStatistics:(id)sender {
    self.statisticsView.hidden = false;
    self.statisticsContentTextView.text = [[JRCall sharedInstance] getStatistics:NO member:nil];
}

- (IBAction)changeStatsticsType:(UISegmentedControl *)sender {
    self.statisticsContentTextView.text = [[JRCall sharedInstance] getStatistics:sender.selectedSegmentIndex == 1 member:nil];
}

- (IBAction)hiddenStatstics:(id)sender {
    self.statisticsView.hidden = true;
}

#pragma mark - DTMF

- (IBAction)showOrHiddenDtmf:(id)sender {
    BOOL show = !self.dtmfView.hidden;
    UIViewAnimationOptions options = show ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft;
    [UIView transitionWithView:self.dtmfView duration:1.5 options:options animations:^{
        self.dtmfView.hidden = show;
        self.headerView.hidden = !show;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)sendDtmf:(UIButton *)sender {
    JRCallDtmfType type;
    NSString *content;
    switch (sender.tag) {
        case 0:
            type = JRCallDtmfType0;
            content = @"0";
            break;
        case 1:
            type = JRCallDtmfType1;
            content = @"1";
            break;
        case 2:
            type = JRCallDtmfType2;
            content = @"2";
            break;
        case 3:
            type = JRCallDtmfType3;
            content = @"3";
            break;
        case 4:
            type = JRCallDtmfType4;
            content = @"4";
            break;
        case 5:
            type = JRCallDtmfType5;
            content = @"5";
            break;
        case 6:
            type = JRCallDtmfType6;
            content = @"6";
            break;
        case 7:
            type = JRCallDtmfType7;
            content = @"7";
            break;
        case 8:
            type = JRCallDtmfType8;
            content = @"8";
            break;
        case 9:
            type = JRCallDtmfType9;
            content = @"9";
            break;
        case 10:
            type = JRCallDtmfTypeSTAR;
            content = @"*";
            break;
        case 11:
            type = JRCallDtmfTypePOUND;
            content = @"#";
            break;
        default:
            type = JRCallDtmfTypePOUND;
            break;
    }
    [[JRCall sharedInstance] sendDtmf:type];
    self.dtmfLabel.text = [NSString stringWithFormat:@"%@%@", self.dtmfLabel.text, content];
}

#pragma mark - Timer

- (void)startTimer {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerProc) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

- (void)timerProc {
    if ([JRCall sharedInstance].currentCall.type == JRCallTypeOneOnOneAudio || [JRCall sharedInstance].currentCall.type == JRCallTypeOneOnOneVideo || [JRCall sharedInstance].currentCall.direction == JRCallDirectionIn) {
        //        self.nameLabel.text = [JRCall sharedInstance].currentCall.callMembers.firstObject.displayName.length ? [JRCall sharedInstance].currentCall.callMembers.firstObject.displayName : [JRCall sharedInstance].currentCall.callMembers.firstObject.number;
        self.headerView.hidden = !self.dtmfView.hidden;
        if (_videoActionHidden) {
            self.headerView.hidden = YES;
        }
        self.nameLabel.text = [JRCall sharedInstance].currentCall.callMembers.firstObject.number;
        self.infoLabel.text = [self getCallInfo:[JRCall sharedInstance].currentCall];
    }
    if (([JRCall sharedInstance].currentCall.type == JRCallTypeMultiVideo || [JRCall sharedInstance].currentCall.type == JRCallTypeMultiAudio) && [JRCall sharedInstance].currentCall.state == JRCallStateTalking) {
        self.headerView.hidden = YES;
    }
    if (!self.statisticsView.hidden) {
        self.statisticsContentTextView.text = [[JRCall sharedInstance] getStatistics:self.statisticsSegment.selectedSegmentIndex == 1 member:nil];
    }
}

#pragma mark - Private Funciton

- (NSString *)getCallInfo:(JRCallItem *)item {
    switch (item.state) {
        case JRCallStateInit:
            return NSLocalizedString(@"CALLING", nil);
        case JRCallStatePending:
            if (item.direction == JRCallDirectionIn) {
                return NSLocalizedString(@"INCOMING_CALL", nil);
            } else {
                return NSLocalizedString(@"CALLING", nil);
            }
        case JRCallStateAlerting:
            return NSLocalizedString(@"RINGING", nil);
        case JRCallStateTalking:
            if (item.hold) {
                return NSLocalizedString(@"HOLDING", nil);
            } else if (item.held) {
                return NSLocalizedString(@"HELDING", nil);
            } else {
                return [self formatTalkingTime:((long)[[NSDate date] timeIntervalSince1970] - item.talkingBeginTime)];
            }
        case JRCallStateOk:
            return NSLocalizedString(@"END", nil);
        case JRCallStateCancel:
            return NSLocalizedString(@"END", nil);
        case JRCallStateCanceled:
            return NSLocalizedString(@"DECLINED", nil);
        case JRCallStateMissed:
            return NSLocalizedString(@"MISSED", nil);
        default:
            return NSLocalizedString(@"ERROR", nil);
    }
}

- (NSString *)formatTalkingTime:(long)time {
    return [NSString stringWithFormat:@"%02ld:%02ld", time/60, time%60];
}

- (JRMediaDeviceVideoCanvas *)getCanvasWithVideoSource:(NSString *)videoSource {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"videoSource", videoSource];
    NSArray *canvas = [self.canvsArray filteredArrayUsingPredicate:pred];
    if (canvas.count > 0) {
        return canvas.firstObject;
    } else {
        return nil;
    }
}

#pragma mark - Device Delegate

- (void)onAudioOutputTypeChange {
    self.speakerBtn.selected = [JRMediaDevice sharedInstance].speakerOn;
}

- (void)onRenderStart:(JRMediaDeviceVideoCanvas *)canva {
    if (canva == self.remote) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.preview.videoView.frame = CGRectMake(10, 30, 90, 160);
                         }
                         completion:^(BOOL finished) {
                             self.preview.videoView.layer.masksToBounds = YES;
                             self.preview.videoView.layer.borderColor = [[UIColor whiteColor] CGColor];
                             self.preview.videoView.layer.borderWidth = 1.0f;
                         }
         ];
    }
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([JRCall sharedInstance].currentCall.type == JRCallTypeMultiAudio) {
        return [JRCall sharedInstance].currentCall.callMembers.count;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRCallMember *member = [JRCall sharedInstance].currentCall.callMembers[indexPath.row];
    NSString *state;
    switch (member.status) {
        case JRCallMemberStatusPending:
            state = NSLocalizedString(@"PENDING", nil);
            break;
        case JRCallMemberStatusInitial:
            state = NSLocalizedString(@"CALL_INIT", nil);
            break;
        case JRCallMemberStatusConnecting:
            state = NSLocalizedString(@"CALL_CONNECTING", nil);
            break;
        case JRCallMemberStatusRinging:
            state = NSLocalizedString(@"RINGING", nil);
            break;
        case JRCallMemberStatusDialingin:
            state = NSLocalizedString(@"INCOMING_CALL", nil);
            break;
        case JRCallMemberStatusDialingout:
            state = NSLocalizedString(@"CALLING", nil);
            break;
        case JRCallMemberStatusAlerting:
            state = NSLocalizedString(@"RINGING", nil);
            break;
        case JRCallMemberStatusConned:
            state = NSLocalizedString(@"CONNED", nil);
            break;
        case JRCallMemberStatusOnhold:
            state = NSLocalizedString(@"HOLDING", nil);
            break;
        case JRCallMemberStatusMuted:
            state = NSLocalizedString(@"MUTED", nil);
            break;
        case JRCallMemberStatusUserNotAvailable:
            state = NSLocalizedString(@"USER_NOT_AVAILABLE", nil);
            break;
        case JRCallMemberStatusNoAnswer:
            state = NSLocalizedString(@"NO_ANSWER", nil);
            break;
        case JRCallMemberStatusBusy:
            state = NSLocalizedString(@"BUSY", nil);
            break;
        case JRCallMemberStatusNotReachable:
            state = NSLocalizedString(@"NOT_REACHABLE", nil);
            break;
        case JRCallMemberStatusRouteFailed:
            state = NSLocalizedString(@"ROUTE_FAILED", nil);
            break;
        case JRCallMemberStatusUnavailable:
            state = NSLocalizedString(@"UNAVAILABLE", nil);
            break;
        case JRCallMemberStatusGeneralFailure:
        case JRCallMemberStatusUnknow:
            state = NSLocalizedString(@"GENERAL_FAILURE", nil);
            break;
        case JRCallMemberStatusTimerExpired:
            state = NSLocalizedString(@"TIMER_EXPIRED", nil);
            break;
        case JRCallMemberStatusDeleted:
            state = NSLocalizedString(@"DELETED", nil);
            break;
        case JRCallMemberStatusForbidden:
            state = NSLocalizedString(@"FORBIDDEN", nil);
            break;
        case JRCallMemberStatusHangUp:
        case JRCallMemberStatusDiscing:
        case JRCallMemberStatusDisced:
            state = NSLocalizedString(@"DECLINED", nil);
            break;
        default:
            state = nil;
            break;
    }
    JRCallMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:MemberCell];
    cell.iconImage.image = [UIImage imageNamed:@"img_greenman_nor"];
    //    cell.nameLabel.text = member.displayName.length ? member.displayName : member.number;
    cell.nameLabel.text = member.number;
    cell.timeLabel.text = state;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JRCallMember *member = [JRCall sharedInstance].currentCall.callMembers[indexPath.row];
    if ([JRCall sharedInstance].currentCall.direction == JRCallDirectionOut && ![JRNumberUtil isNumberEqual:member.number secondNumber:[JRClient sharedInstance].currentNumber]) {
        if (member.status == JRCallMemberStatusDisced || member.status == JRCallMemberStatusDiscing || member.status == JRCallMemberStatusHangUp) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"ADD_MEMBER", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[JRCall sharedInstance] addMultiCallMember:member.number];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"REMOVE_MEMBER", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[JRCall sharedInstance] removeMultiCallMember:member];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - Collection View Delegate
#warning 代码冗余严重，之后应将多方语音也改为Collection布局

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([JRCall sharedInstance].currentCall.type != JRCallTypeMultiVideo) {
        return 0;
    }
    return [JRCall sharedInstance].currentCall.callMembers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JRMultiVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MultiVideoCell forIndexPath:indexPath];
    JRCallMember *member = [JRCall sharedInstance].currentCall.callMembers[indexPath.row];
    NSString *state;
    switch (member.status) {
        case JRCallMemberStatusPending:
            state = NSLocalizedString(@"PENDING", nil);
            break;
        case JRCallMemberStatusInitial:
            state = NSLocalizedString(@"CALL_INIT", nil);
            break;
        case JRCallMemberStatusConnecting:
            state = NSLocalizedString(@"CALL_CONNECTING", nil);
            break;
        case JRCallMemberStatusRinging:
            state = NSLocalizedString(@"RINGING", nil);
            break;
        case JRCallMemberStatusDialingin:
            state = NSLocalizedString(@"INCOMING_CALL", nil);
            break;
        case JRCallMemberStatusDialingout:
            state = NSLocalizedString(@"CALLING", nil);
            break;
        case JRCallMemberStatusAlerting:
            state = NSLocalizedString(@"RINGING", nil);
            break;
        case JRCallMemberStatusConned:
            state = NSLocalizedString(@"CONNED", nil);
            break;
        case JRCallMemberStatusOnhold:
            state = NSLocalizedString(@"HOLDING", nil);
            break;
        case JRCallMemberStatusMuted:
            state = NSLocalizedString(@"MUTED", nil);
            break;
        case JRCallMemberStatusUserNotAvailable:
            state = NSLocalizedString(@"USER_NOT_AVAILABLE", nil);
            break;
        case JRCallMemberStatusNoAnswer:
            state = NSLocalizedString(@"NO_ANSWER", nil);
            break;
        case JRCallMemberStatusBusy:
            state = NSLocalizedString(@"BUSY", nil);
            break;
        case JRCallMemberStatusNotReachable:
            state = NSLocalizedString(@"NOT_REACHABLE", nil);
            break;
        case JRCallMemberStatusRouteFailed:
            state = NSLocalizedString(@"ROUTE_FAILED", nil);
            break;
        case JRCallMemberStatusUnavailable:
            state = NSLocalizedString(@"UNAVAILABLE", nil);
            break;
        case JRCallMemberStatusGeneralFailure:
        case JRCallMemberStatusUnknow:
            state = NSLocalizedString(@"GENERAL_FAILURE", nil);
            break;
        case JRCallMemberStatusTimerExpired:
            state = NSLocalizedString(@"TIMER_EXPIRED", nil);
            break;
        case JRCallMemberStatusDeleted:
            state = NSLocalizedString(@"DELETED", nil);
            break;
        case JRCallMemberStatusForbidden:
            state = NSLocalizedString(@"FORBIDDEN", nil);
            break;
        case JRCallMemberStatusHangUp:
        case JRCallMemberStatusDiscing:
        case JRCallMemberStatusDisced:
            state = NSLocalizedString(@"DECLINED", nil);
            break;
        default:
            state = nil;
            break;
    }
    cell.numberLabel.text = member.number;
    cell.stateLabel.text = state;
    JRMediaDeviceVideoCanvas *canv = [self getCanvasWithVideoSource:member.videoSource];
    if (!canv) {
        canv = [[JRMediaDevice sharedInstance] startVideo:member.videoSource renderType:JRMediaDeviceRenderFullScreen];
        [self.canvsArray addObject:canv];
    }
    canv.videoView.frame = CGRectMake(0, 0, cell.videoView.frame.size.width, cell.videoView.frame.size.height);
    [cell.videoView addSubview:canv.videoView];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = (collectionView.bounds.size.width - 20) / 3.0;
    CGFloat h = w / WHRate;
    return CGSizeMake(w, h);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    JRCallMember *member = [JRCall sharedInstance].currentCall.callMembers[indexPath.row];
    if ([JRCall sharedInstance].currentCall.direction == JRCallDirectionOut && ![JRNumberUtil isNumberEqual:member.number secondNumber:[JRClient sharedInstance].currentNumber]) {
        if (member.status == JRCallMemberStatusDisced || member.status == JRCallMemberStatusDiscing || member.status == JRCallMemberStatusHangUp) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"ADD_MEMBER", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[JRCall sharedInstance] addMultiCallMember:member.number];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"REMOVE_MEMBER", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[JRCall sharedInstance] removeMultiCallMember:member];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

@end
