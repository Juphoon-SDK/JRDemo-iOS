//
//  JRChatViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/6.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRChatViewController.h"
#import "JRMessageDBHelper.h"
#import "JRMessageLayoutManager.h"
#import "JRMessageManager.h"
#import "JRInputView.h"
#import "JRAlbumViewController.h"
#import "JRDisplayLocationViewController.h"
#import "JRCameraHelper.h"
#import "JRRecordHelper.h"
#import "MJRefresh.h"
#import "XHBVoiceRecordProgressView.h"
#import "JRMediaPlayViewController.h"
#import "JRFilesViewController.h"
#import "JRGroupManager.h"
#import "JRBaseBubbleMessageCell.h"
#import "JRTextMessageCell.h"
#import "JRThumbImageMessageCell.h"
#import "JRLocationMessageCell.h"
#import "JRAudioMessageCell.h"
#import "JRVCardMessageCell.h"
#import "JROtherFileMessageCell.h"
#import "JRGroupNotifyCell.h"
#import "JRRevokeMessageCell.h"
#import "JRExVCardMessageCell.h"
#import "JRGroupDetailViewController.h"
#import "JRAtMemberViewController.h"
#import "JRGroupDBManager.h"

#import <AddressBookUI/AddressBookUI.h>

#define TextCell @"TextCell"
#define AudioCell @"AudioCell"
#define ThumbImgCell @"ThumbImgCell"
#define VCardCell @"VCardCell"
#define LocationCell @"LocationCell"
#define OtherFileCell @"OtherFileCell"
#define NotifyCell @"NotifyCell"
#define RevokeCell @"RevokeCell"
#define ExchangeCell @"ExchangeCell"

@interface JRChatViewController () <UITableViewDataSource, UITableViewDelegate, JRInputViewDelegate, ABPeoplePickerNavigationControllerDelegate, JRCameraHelperDelegate, JRAlbumViewControllerDelegate, JRFilesViewControllerDelegate, JRMessageCellDelegate, JRAtMemberViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JRInputView *commentView;

@property (nonatomic, strong) RLMResults<JRMessageObject *> *messageList;
@property (nonatomic, strong) RLMNotificationToken *messageListToken;

@property (nonatomic, strong) JRGroupObject *group;
@property (nonatomic, strong) RLMNotificationToken *groupToken;

@property (nonatomic, copy) NSString *peerNumber;
@property (nonatomic, assign) NSInteger currentCount;

@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation JRChatViewController

- (instancetype)initWithPhone:(NSString *)number {
    if ([super init]) {
        self.peerNumber = number;
        self.title = number;
    }
    return self;
}

- (instancetype)initWithGroup:(JRGroupObject *)group {
    if ([super init]) {
        self.group = group;
        self.peerNumber = group.identity;
        self.title = group.name;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isFirstLoad = YES;
    
    [self.view addSubview:self.commentView];
    [self.view addSubview:self.tableView];
    
    [JRMessageManager shareInstance].currentNumber = self.peerNumber;
    if (self.group) {
        [[JRGroupManager sharedInstance] subscribeGroupInfo:self.peerNumber];
    }
    
    [self getMessages];
    [self setMJRefresh];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keypadChanged:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keypadChanged:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.group) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_group"] style:UIBarButtonItemStylePlain target:self action:@selector(detail)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [JRMessageDBHelper readAllMessagesWithNumber:self.peerNumber group:self.group];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[JRAudioPlayHelper shareInstance] stopAudio];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.isFirstLoad) {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-InputHeadViewHeight);
        self.commentView.frame = CGRectMake(0, CGRectGetMaxY(_tableView.frame), self.view.frame.size.width, InputHeadViewHeight+InputMenuViewHeight);
        self.isFirstLoad = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [JRMessageManager shareInstance].currentNumber = nil;
    [[JRMessageLayoutManager shareInstance].layoutDic removeAllObjects];
    
    [self.commentView removeObserver:self forKeyPath:@"frame"];
    [self.commentView removeObserver:self forKeyPath:@"center"];
    
    [self.messageListToken invalidate];
    [self.groupToken invalidate];
}

- (void)detail {
    JRGroupDetailViewController *view = [[JRGroupDetailViewController alloc] initWithGroup:self.group];
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - Init Function

- (void)getMessages {
    self.messageList = [JRMessageDBHelper getMessagesWithNumber:self.peerNumber group:self.group];
    @weakify(self)
    self.messageListToken = [self.messageList addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        @strongify(self)
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }
        if (!change) {
            [self messageFirstLoad];
            return;
        }
        if (change.modifications.count>0) {
            NSArray<NSIndexPath *> *changes = [change modificationsInSection:0];
            NSMutableArray *messageArray = [[NSMutableArray alloc] init];
            for (int i=0; i<changes.count; i++) {
                JRMessageObject *message = [self.messageList objectAtIndex:changes[i].row];
                [messageArray addObject:message];
            }
            [self messageUpdated:messageArray];
        }
        if (change.insertions.count>0) {
            NSArray<NSIndexPath *> *changes = [change insertionsInSection:0];
            NSMutableArray *messageArray = [[NSMutableArray alloc] init];
            for (int i=0; i<changes.count; i++) {
                JRMessageObject *message = [self.messageList objectAtIndex:changes[i].row];
                [messageArray addObject:message];
            }
            [self messageInserted:messageArray];
        }
        if (change.deletions.count>0) {
            if (self.messageList.count) {
                NSArray<NSIndexPath *> *changes = [change deletionsInSection:0];
                NSMutableArray *messageArray = [[NSMutableArray alloc] init];
                for (int i=0; i<changes.count; i++) {
                    JRMessageObject *message = [self.messageList objectAtIndex:changes[i].row];
                    [messageArray addObject:message];
                }
                [self messageDeleted:messageArray];
            } else {
                [self messageDeletedAll];
            }
        }
    }];
    if (self.group) {
        self.groupToken = [self.group addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
            @strongify(self)
            if (!deleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = self.group.name;
                });
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"GROUP_NOT_EXIST", nil)];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    
    self.currentCount = 10;
    if (self.currentCount > self.messageList.count) {
        self.currentCount = self.messageList.count;
    }
}

- (void)setMJRefresh {
    __weak typeof(self) weakSelf = self;
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        NSInteger lastCount = weakSelf.currentCount;
        if (weakSelf.currentCount == weakSelf.messageList.count) {
            [weakSelf.tableView.mj_header endRefreshingWithCompletionBlock:^{
            }];
        } else if (weakSelf.currentCount+20 > weakSelf.messageList.count) {
            NSIndexPath *indexPath= [NSIndexPath indexPathForRow:weakSelf.messageList.count-weakSelf.currentCount-1 inSection:0];
            weakSelf.currentCount = weakSelf.messageList.count;
            for (NSInteger i=0; i<weakSelf.messageList.count-lastCount; i++) {
                JRMessageObject *message = weakSelf.messageList[i];
                [[JRMessageLayoutManager shareInstance] creatLayoutWithMessage:message showTime:[weakSelf shouldShowTime:message]];
            }
            [weakSelf.tableView.mj_header endRefreshingWithCompletionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                });
            }];
        } else {
            NSIndexPath *indexPath= [NSIndexPath indexPathForRow:19 inSection:0];
            weakSelf.currentCount+=20;
            for (NSInteger i=(weakSelf.messageList.count-weakSelf.currentCount); i<weakSelf.messageList.count-lastCount; i++) {
                JRMessageObject *message = weakSelf.messageList[i];
                [[JRMessageLayoutManager shareInstance] creatLayoutWithMessage:message showTime:[weakSelf shouldShowTime:message]];
            }
            [weakSelf.tableView.mj_header endRefreshingWithCompletionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                });
            }];
        }
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setTitle:NSLocalizedString(@"MJ_LOAD_MORE", nil) forState:MJRefreshStateIdle];
    [header setTitle:NSLocalizedString(@"MJ_LOADING", nil) forState:MJRefreshStatePulling];
    [header setTitle:NSLocalizedString(@"MJ_LOAD_COMPLETE", nil) forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
}

#pragma mark - Views

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[JRTextMessageCell class] forCellReuseIdentifier:TextCell];
        [_tableView registerClass:[JRLocationMessageCell class] forCellReuseIdentifier:LocationCell];
        [_tableView registerClass:[JRAudioMessageCell class] forCellReuseIdentifier:AudioCell];
        [_tableView registerClass:[JRThumbImageMessageCell class] forCellReuseIdentifier:ThumbImgCell];
        [_tableView registerClass:[JRVCardMessageCell class] forCellReuseIdentifier:VCardCell];
        [_tableView registerClass:[JROtherFileMessageCell class] forCellReuseIdentifier:OtherFileCell];
        [_tableView registerClass:[JRGroupNotifyCell class] forCellReuseIdentifier:NotifyCell];
        [_tableView registerClass:[JRRevokeMessageCell class] forCellReuseIdentifier:RevokeCell];
        [_tableView registerClass:[JRExVCardMessageCell class] forCellReuseIdentifier:ExchangeCell];
        _tableView.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    }
    return _tableView;
}

- (JRInputView *)commentView {
    if (!_commentView) {
        _commentView = [[JRInputView alloc] initWithFrame:CGRectZero];
        [_commentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        [_commentView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
        _commentView.delegate = self;
    }
    return _commentView;
}

#pragma mark - Key-value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.commentView && ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"center"])) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

- (void)layoutAndAnimateMessageInputTextView:(UIView *)textView {
    CGRect frame = self.tableView.frame;
    frame.size.height = textView.frame.origin.y;
    self.tableView.frame = frame;
    [self scrollToBottomWithAnimated:NO];
}

- (void)keypadChanged:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    CGRect rectOfStatusbar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect rectOfNavigationbar = self.navigationController.navigationBar.frame;
    CGFloat height = rectOfStatusbar.size.height+rectOfNavigationbar.size.height;
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.commentView.center = CGPointMake(self.commentView.center.x, keyBoardEndY+(self.commentView.headHeight+InputMenuViewHeight)/2-self.commentView.headHeight-height);
    }];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = self.messageList.count - self.currentCount + indexPath.row;
    if (index >= self.messageList.count || index < 0) {
        return [[UITableViewCell alloc] init];
    }
    JRMessageObject *message = self.messageList[index];
    if (message.state == JRMessageItemStateRevoked) {
        JRRevokeMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:RevokeCell forIndexPath:indexPath];
        [cell configWithLayout:[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.imdnId]];
        return cell;
    } else {
        JRBaseBubbleMessageCell *cell;
        switch (message.type) {
            case JRMessageItemTypeText: {
                if (message.contentType == JRTextMessageContentTypeDefault) {
                    cell = [tableView dequeueReusableCellWithIdentifier:TextCell forIndexPath:indexPath];
                    [(JRTextMessageCell *)cell configWithLayout:[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.imdnId]];
                } else {
                    cell = [tableView dequeueReusableCellWithIdentifier:ExchangeCell forIndexPath:indexPath];
                    [(JRExVCardMessageCell *)cell configWithLayout:[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.imdnId]];
                }
                break;
            }
            case JRMessageItemTypeImage:
            case JRMessageItemTypeVideo: {
                cell = [tableView dequeueReusableCellWithIdentifier:ThumbImgCell forIndexPath:indexPath];
                [(JRThumbImageMessageCell *)cell configWithLayout:[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.transId]];
                break;
            }
            case JRMessageItemTypeAudio: {
                cell = [tableView dequeueReusableCellWithIdentifier:AudioCell forIndexPath:indexPath];
                JRAudioLayout *layout = [[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.transId];
                [(JRAudioMessageCell *)cell configWithLayout:layout];
                // 如果是正在播放的音频消息，则播放动画
                if ([[JRAudioPlayHelper shareInstance].filePath isEqualToString:[JRFileUtil getAbsolutePathWithFileRelativePath:layout.message.filePath]] && [JRAudioPlayHelper shareInstance].isPlaying) {
                    [(JRAudioMessageCell *)cell startAniamtion];
                } else {
                    [(JRAudioMessageCell *)cell stopAniamtion];
                }
                break;
            }
            case JRMessageItemTypeVcard: {
                cell = [tableView dequeueReusableCellWithIdentifier:VCardCell forIndexPath:indexPath];
                [(JRVCardMessageCell *)cell configWithLayout:[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.transId]];
                break;
            }
            case JRMessageItemTypeGeo: {
                cell = [tableView dequeueReusableCellWithIdentifier:LocationCell forIndexPath:indexPath];
                [(JRLocationMessageCell *)cell configWithLayout:[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.transId]];
                break;
            }
            case JRMessageItemTypeOtherFile: {
                cell = [tableView dequeueReusableCellWithIdentifier:OtherFileCell forIndexPath:indexPath];
                [(JROtherFileMessageCell *)cell configWithLayout:[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.transId]];
                break;
            }
            case JRMessageItemTypeNotify: {
                JRGroupNotifyCell *notifyCell = [tableView dequeueReusableCellWithIdentifier:NotifyCell forIndexPath:indexPath];
                [notifyCell configWithLayout:[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.imdnId]];
                return notifyCell;
            }
            case JRMessageItemTypeUnknow:
            default:
                cell = [[JRBaseBubbleMessageCell alloc] init];
                break;
        }
        [cell setDelegate:self tableView:self.tableView];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = self.messageList.count - self.currentCount + indexPath.row;
    if (index >= self.messageList.count || index < 0) {
        return 0;
    }
    JRMessageObject *message = self.messageList[index];
    if (message.state == JRMessageItemStateRevoked) {
        return [((JRRevokeLayout *)[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.imdnId]) calculateCellHeight];
    }
    if (message.type == JRMessageItemTypeText) {
        return [((JRBaseBubbleLayout *)[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.imdnId]) calculateCellHeight];
    } else if (message.type == JRMessageItemTypeNotify) {
        return [((JRGroupNotifyLayout *)[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.imdnId]) calculateCellHeight];
    } else {
        return [((JRBaseBubbleLayout *)[[JRMessageLayoutManager shareInstance].layoutDic objectForKey:message.transId]) calculateCellHeight];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self tap:nil];
}

- (BOOL)shouldShowTime:(JRMessageObject *)message {
    NSInteger index = [self.messageList indexOfObject:message];
    if (index == 0) {
        return YES;
    }
    NSString *currentTime = self.messageList[index].timestamp;
    NSString *previousTime = self.messageList[index-1].timestamp;
    return [currentTime longLongValue]-[previousTime longLongValue] > 180000 || index%9==1;
}

- (void)scrollToBottomWithAnimated:(BOOL)animated {
    if (self.currentCount > 0) {
        NSIndexPath *indexPath= [NSIndexPath indexPathForRow:self.currentCount-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)tap:(UITapGestureRecognizer *)tapGes {
    [self.view endEditing:YES];
    [self menuViewHide];
}

#pragma mark - JRMessageCell Delegate

- (void)tableView:(UITableView *)tableView tapMessageCellContent:(JRMessageObject *)message {
    if (message.type == JRMessageItemTypeVideo || message.type == JRMessageItemTypeImage || message.type == JRMessageItemTypeOtherFile) {
        JRMediaPlayViewController *view = [[JRMediaPlayViewController alloc] init];
        view.message = message;
        [self.navigationController pushViewController:view animated:YES];
    } else if (message.type == JRMessageItemTypeGeo) {
        if (message.state == JRMessageItemStateReceiveFailed || message.state == JRMessageItemStateReceivingPause) {
            [[JRMessageManager shareInstance] fetchGeo:[JRMessageDBHelper converGeoMessage:message]];
        } else if (message.state == JRMessageItemStateReceiveOK || message.direction == JRMessageItemDirectionSend) {
            JRDisplayLocationViewController *view = [[JRDisplayLocationViewController alloc] init];
            view.latitude = [message.geoLatitude floatValue];
            view.longitude = [message.geoLongitude floatValue];
            view.radius = [message.geoRadius floatValue];
            view.address = message.geoFreeText;
            view.isShowMessageLocation = YES;
            [self.navigationController pushViewController:view animated:YES];
        }
    } else if (message.type == JRMessageItemTypeAudio) {
        if (message.state == JRMessageItemStateReceiveFailed || message.state == JRMessageItemStateReceivingPause) {
            [[JRMessageManager shareInstance] transferFile:[JRMessageDBHelper converFileMessage:message]];
        }
    } else if (message.type == JRMessageItemTypeVcard) {
        if (message.state == JRMessageItemStateReceiveFailed || message.state == JRMessageItemStateReceivingPause) {
            [[JRMessageManager shareInstance] transferFile:[JRMessageDBHelper converFileMessage:message]];
        } else if (message.state == JRMessageItemStateReceiveOK || message.direction == JRMessageItemDirectionSend) {
            // 存通讯录
        }
    }
}

- (void)tableView:(UITableView *)tableView tapMessageCellState:(JRMessageObject *)message {
    if (message.state == JRMessageItemStateSendFailed || message.state == JRMessageItemStateSendingPause) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"RESEND_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (![[JRMessageManager shareInstance] resendMessage:message]) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView tapMessageCellAvator:(JRMessageObject *)message {

}

- (void)tableView:(UITableView *)tableView revokeMessage:(JRMessageObject *)message {
    if (([[NSDate date] timeIntervalSince1970] - [message.timestamp longLongValue]/1000) / 60 > 2) {
        [SVProgressHUD showErrorWithStatus:@"超出两分钟无法撤回"];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    [[JRMessageManager shareInstance] sendCommand:message command:JRMessageCommandTypeRevoke group:self.group];
}

- (void)tableView:(UITableView *)tableView acceptExchangeVCard:(JRMessageObject *)message {
    NSString *content = JRCreateVCardContent(nil, [JRClient sharedInstance].currentNumber, nil, nil, [NSString stringWithFormat:@"我的号码是%@，我同意与你交换名片", [JRClient sharedInstance].currentNumber]);
    [[JRMessageManager shareInstance] sendTextMessage:content number:self.peerNumber contentType:JRTextMessageContentTypeAgreeExchangeVCard convId:message.conversationId];
}

#pragma mark - Input View Delegate

- (void)didBeginEditing {
    [self scrollToBottomWithAnimated:NO];
}

- (void)didAtMemberInGroupChat {
    if (self.group) {
        [JRAtMemberViewController presentWithNavigationController:^(JRAtMemberViewController *atViewController) {
            atViewController.atDelegate = self;
        } group:self.group presentingViewController:self];
    }
}

- (void)sendMessage:(NSString *)message {
    NSString *str = [message stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([str isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"CANNOT_SEND_EMPTY_MESSAGE", nil)];
        return;
    }
    BOOL ret;
    if (self.group) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(.*?) " options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *result = [regex matchesInString:message options:NSMatchingReportProgress range:NSMakeRange(0, message.length)];
        BOOL atAll = NO;
        NSMutableArray<JRGroupMemberObject *> * atMembers = [[NSMutableArray alloc] init];
        if (result.count) {
            for (NSTextCheckingResult *match in result) {
                NSString *displayName = [message substringWithRange:match.range];
                displayName = [displayName substringWithRange:NSMakeRange(1, displayName.length - 2)];
                if ([displayName isEqualToString:@"所有群成员"]) {
                    atAll = YES;
                    break;
                } else {
                    [atMembers addObject:[JRGroupDBManager getGroupMemberWithIdentity:self.group.identity displayName:displayName]];
                }
            }
        }
        
        ret = [[JRMessageManager shareInstance] sendTextMessage:message group:self.group members:atMembers atAll:atAll];
    } else {
        ret = [[JRMessageManager shareInstance] sendTextMessage:message number:self.peerNumber contentType:JRTextMessageContentTypeDefault convId:nil];
    }
    if (!ret) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
    }
}

- (void)menuViewShow {
    if (!self.commentView.isMenuViewShow) {
        [UIView animateWithDuration:0.3f animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            self.commentView.center = CGPointMake(self.commentView.center.x, self.view.frame.size.height-self.commentView.bounds.size.height/2.0);
        } completion:^(BOOL finished) {
            self.commentView.isMenuViewShow = YES;
        }];
    }
}

- (void)menuViewHide {
    if (self.commentView.isMenuViewShow) {
        [UIView animateWithDuration:0.3f animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            self.commentView.center = CGPointMake(self.commentView.center.x, self.view.frame.size.height+(self.commentView.headHeight+InputMenuViewHeight)/2-self.commentView.headHeight);
        } completion:^(BOOL finished) {
            self.commentView.isMenuViewShow = NO;
        }];
    }
}

- (void)photoBtnClicked {
    JRAlbumViewController *view = [[JRAlbumViewController alloc] init];
    view.delegate = self;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)cameraBtnClicked {
    [self.view endEditing:YES];
    [JRCameraHelper sharedInstance].delegate = self;
    [[JRCameraHelper sharedInstance] showCameraViewControllerCameraType:CameraTypeBoth onViewController:self];
}

- (void)locationBtnClicked {
    JRDisplayLocationViewController *view = [[JRDisplayLocationViewController alloc] init];
    @weakify(self)
    view.compledBlock = ^(double latitude, double longitude, float radius, NSString *geoLocation) {
        @strongify(self)
        if (self.group) {
            [[JRMessageManager shareInstance] sendGeo:geoLocation latitude:latitude longitude:longitude radius:radius group:self.group];
        } else {
            [[JRMessageManager shareInstance] sendGeo:geoLocation latitude:latitude longitude:longitude radius:radius number:self.peerNumber];
        }
    };
    [self.navigationController pushViewController:view animated:YES];
}

- (void)cardBtnClicked {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)otherFilesBtnClicked {
    JRFilesViewController *view = [[JRFilesViewController alloc] init];
    view.delegate = self;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)didVoiceRecordBeginRecord:(XHBVoiceRecordButton *)button {
    [[JRAudioPlayHelper shareInstance] stopAudio];
    self.tableView.userInteractionEnabled = NO;
    [[XHBVoiceRecordProgressView shareButton] setVoiceRecord];
    [[XHBVoiceRecordProgressView shareButton] show];
    [JRRecordHelper sharedRecordTool].peerNumber = self.peerNumber;
    [[JRRecordHelper sharedRecordTool] startRecordingWithStartCompleteBlock:nil];
}

- (void)didVoiceRecordEndRecord:(XHBVoiceRecordButton *)button timeDuration:(int)duration {
    self.tableView.userInteractionEnabled = YES;
    [[XHBVoiceRecordProgressView shareButton] hide];
    [[JRRecordHelper sharedRecordTool] stopRecordingWithStopCompleteBlock:^(NSString *filePath) {
        if (self.group) {
            [[JRMessageManager shareInstance] sendFile:filePath thumbPath:nil type:[JRFileUtil getFileTypeWithPath:filePath] group:self.group];
        } else {
            [[JRMessageManager shareInstance] sendFile:filePath thumbPath:nil type:[JRFileUtil getFileTypeWithPath:filePath] number:self.peerNumber];
        }
    }];
}

- (void)didVoiceRecordCancelRecord:(XHBVoiceRecordButton *)button {
    self.tableView.userInteractionEnabled = YES;
    [[XHBVoiceRecordProgressView shareButton] hide];
    [[JRRecordHelper sharedRecordTool] cancelRecordingWithCancelCompleteBlock:nil];
}

- (void)didVoiceRecordContinueRecord:(XHBVoiceRecordButton *)button {
    [[XHBVoiceRecordProgressView shareButton] reShow];
}

- (void)didVoiceRecordWillCancelRecord:(XHBVoiceRecordButton *)button {
    [[XHBVoiceRecordProgressView shareButton] willHide];
}

- (void)didVoiceRecordRecordTimeSmall:(XHBVoiceRecordButton *)button {
    self.tableView.userInteractionEnabled = YES;
    [[XHBVoiceRecordProgressView shareButton] recordTimeSmall];
    [[JRRecordHelper sharedRecordTool] cancelRecordingWithCancelCompleteBlock:nil];
}

- (void)didVoiceRecordRecordTimeBig:(XHBVoiceRecordButton *)button {
    self.tableView.userInteractionEnabled = YES;
    [[XHBVoiceRecordProgressView shareButton] hide];
    [[JRRecordHelper sharedRecordTool] stopRecordingWithStopCompleteBlock:^(NSString *filePath) {
        if (self.group) {
            [[JRMessageManager shareInstance] sendFile:filePath thumbPath:nil type:[JRFileUtil getFileTypeWithPath:filePath] group:self.group];
        } else {
            [[JRMessageManager shareInstance] sendFile:filePath thumbPath:nil type:[JRFileUtil getFileTypeWithPath:filePath] number:self.peerNumber];
        }
    }];
}

#pragma mark - Message Update Delegate

- (void)messageFirstLoad {
    for (NSInteger i = self.messageList.count - self.currentCount; i < self.messageList.count; i ++) {
        JRMessageObject *message = self.messageList[i];
        [[JRMessageLayoutManager shareInstance] creatLayoutWithMessage:message showTime:[self shouldShowTime:message]];
    }
    [self.tableView reloadData];
    [self scrollToBottomWithAnimated:NO];
}

- (void)messageUpdated:(NSArray<JRMessageObject *> *)messages {
    for (JRMessageObject *message in messages) {
        [[JRMessageLayoutManager shareInstance] creatLayoutWithMessage:message showTime:[self shouldShowTime:message]];
    }
    [self.tableView reloadData];
}

- (void)messageDeleted:(NSArray<JRMessageObject *> *)messages {
    self.currentCount -= messages.count;
    [self.tableView reloadData];
}

- (void)messageDeletedAll {
    
}

- (void)messageInserted:(NSArray<JRMessageObject *> *)messages {
    self.currentCount += messages.count;
    for (JRMessageObject *message in messages) {
        [[JRMessageLayoutManager shareInstance] creatLayoutWithMessage:message showTime:[self shouldShowTime:message]];
    }
    [self.tableView reloadData];
    [self scrollToBottomWithAnimated:YES];
}

#pragma mark - ABPeoplePickerNavigationController Delegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    CFStringRef name = ABRecordCopyCompositeName(person);
    NSString *stringName = (__bridge_transfer NSString *)name;
    stringName = stringName?stringName:@"Anonymous";
    
    NSArray *array = [NSArray arrayWithObject:(__bridge id)(person)];
    NSData *data = (__bridge_transfer NSData *)ABPersonCreateVCardRepresentationWithPeople((__bridge CFArrayRef)array);;
    
    NSString *fileRelativePath = [JRFileUtil createFilePathWithFileName:[JRFileUtil getFileNameWithType:@"vcf"] folderName:@"vcard" peerUserName:self.peerNumber];
    NSString *filePath = [JRFileUtil getAbsolutePathWithFileRelativePath:fileRelativePath];
    if ([data writeToFile:filePath atomically:YES]) {
        BOOL ret;
        if (self.group) {
            ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:filePath peerUserName:self.peerNumber] type:MessageTypeVCard group:self.group];
        } else {
            ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:filePath peerUserName:self.peerNumber] type:MessageTypeVCard number:self.peerNumber];
        }
        if (!ret) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
        } else {
            [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Camera Delegate

- (void)cameraPrintImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSString *fileRelativePath = [JRFileUtil createFilePathWithFileName:[JRFileUtil getFileNameWithType:@"png"] folderName:@"image" peerUserName:self.peerNumber];
    if ([imageData writeToFile:[JRFileUtil getAbsolutePathWithFileRelativePath:fileRelativePath] atomically:YES]) {
        BOOL ret;
        if (self.group) {
            ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:fileRelativePath peerUserName:self.peerNumber] type:MessageTypeImagePNG group:self.group];
        } else {
            ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:fileRelativePath peerUserName:self.peerNumber] type:MessageTypeImagePNG number:self.peerNumber];
        }
        if (!ret) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
        }
    }
}

- (void)cameraPrintVideo:(NSURL *)videoUrl {
    [JRFileUtil convertVideoFormat:[videoUrl path] peerUserName:self.peerNumber completionHandler:^(NSError *error, NSString *fileRelativePath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && fileRelativePath.length) {
                BOOL ret;
                if (self.group) {
                    ret =  [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:fileRelativePath peerUserName:self.peerNumber] type:MessageTypeVideoMP4 group:self.group];
                } else {
                    ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:fileRelativePath peerUserName:self.peerNumber] type:MessageTypeVideoMP4 number:self.peerNumber];
                }
                if (!ret) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
                }
            }
        });
    }];
}

#pragma mark - JRFilesViewControllerDelegate

- (void)fileSelected:(NSString *)filePath {
    if (filePath.length) {
        NSString *fileName = filePath.lastPathComponent;
        NSString *rPath = [JRFileUtil createFilePathWithFileName:fileName folderName:@"otherfile" peerUserName:self.peerNumber];
        if ([[NSFileManager defaultManager] copyItemAtPath:[JRFileUtil getAbsolutePathWithFileRelativePath:filePath] toPath:[JRFileUtil getAbsolutePathWithFileRelativePath:rPath] error:nil]) {
            BOOL ret;
            if (self.group) {
                ret = [[JRMessageManager shareInstance] sendFile:rPath thumbPath:nil type:MessageTypeAPPOSTRM group:self.group];
            } else {
                ret = [[JRMessageManager shareInstance] sendFile:rPath thumbPath:nil type:MessageTypeAPPOSTRM number:self.peerNumber];
            }
            if (!ret) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
            }
        } else {
            // 如拷贝失败则直接根据路径发送，可能导致删除一会话后有关联的文件全部无法查看
            BOOL ret;
            if (self.group) {
                ret = [[JRMessageManager shareInstance] sendFile:filePath thumbPath:nil type:MessageTypeAPPOSTRM group:self.group];
            } else {
                ret = [[JRMessageManager shareInstance] sendFile:filePath thumbPath:nil type:MessageTypeAPPOSTRM number:self.peerNumber];
            }
            if (!ret) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
            }
        }
    }
}

#pragma mark - JRAlbumViewControllerDelegate

- (void)fileSelected:(NSArray<NSData *> *)dataArray isVideo:(BOOL)video {
    if (dataArray.count) {
        if (video) {
            for (NSData *videoData in dataArray) {
                NSString *fileRelativePath = [JRFileUtil createFilePathWithFileName:[JRFileUtil getFileNameWithType:@"mp4"] folderName:@"video" peerUserName:self.peerNumber];
                if ([videoData writeToFile:[JRFileUtil getAbsolutePathWithFileRelativePath:fileRelativePath] atomically:YES]) {
                    BOOL ret;
                    if (self.group) {
                        ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:fileRelativePath peerUserName:self.peerNumber] type:MessageTypeVideoMP4 group:self.group];
                    } else {
                        ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:fileRelativePath peerUserName:self.peerNumber] type:MessageTypeVideoMP4 number:self.peerNumber];
                    }
                    if (!ret) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
                    }
                }
            }
        } else {
            for (NSData *imageData in dataArray) {
                NSString *fileRelativePath = [JRFileUtil createFilePathWithFileName:[JRFileUtil getFileNameWithType:@"png"] folderName:@"image" peerUserName:self.peerNumber];
                if ([imageData writeToFile:[JRFileUtil getAbsolutePathWithFileRelativePath:fileRelativePath] atomically:YES]) {
                    BOOL ret;
                    if (self.group) {
                        ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:fileRelativePath peerUserName:self.peerNumber] type:MessageTypeImagePNG group:self.group];
                    } else {
                        ret = [[JRMessageManager shareInstance] sendFile:fileRelativePath thumbPath:[JRFileUtil getThumbPathWithFilePath:fileRelativePath peerUserName:self.peerNumber] type:MessageTypeImagePNG number:self.peerNumber];
                    }
                    if (!ret) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
                    }
                }
            }
        }
    }
}

#pragma mark - JRAtMemberViewControllerDelegate

- (void)atAllMembers:(JRAtMemberViewController *)ViewController {
    [self.commentView addContent:@"所有群成员 "];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [self.commentView beginEditing];
    });
}

- (void)atGroupMembers:(NSArray<JRGroupMemberObject *> *)members viewController:(JRAtMemberViewController *)ViewController {
    if (members.count > 0) {
        NSMutableString *content = [[NSMutableString alloc] init];
        for (int i = 0; i < members.count; i ++) {
            if (i == 0) {
                [content appendString:members[i].displayName];
            } else {
                [content appendString:[NSString stringWithFormat:@" @%@", members[i].displayName]];
            }
        }
        [content appendString:@" "];
        [self.commentView addContent:content];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.commentView beginEditing];
        });
    }
}

@end
