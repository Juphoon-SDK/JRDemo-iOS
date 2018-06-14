//
//  JRRecentCallViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/4/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRRecentCallViewController.h"
#import "JRCallDBManager.h"
#import "JRNumberUtil.h"
#import "MHPrettyDate.h"
#import "UIImage+Tint.h"
#import "JRRecentDetailViewController.h"

static NSString * const RecentCellId = @"RecentCellId";

@interface WrapCall : NSObject

@property (nonatomic, strong) NSMutableArray<JRCallObject *> *callLog;

@end

@implementation WrapCall

- (instancetype)init {
    if ([super init]) {
        self.callLog = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

@interface JRRecentCallViewController ()

@property (nonatomic, strong) RLMResults<JRCallObject *> *mCalls;
@property (nonatomic, strong) RLMNotificationToken *mCallsNotificationToken;

@property (nonatomic, strong) RLMResults<JRCallObject *> *mMissCalls;
@property (nonatomic, strong) RLMNotificationToken *mMissCallsNotificationToken;

@property (nonatomic, strong) UIBarButtonItem *mEditBarButton;
@property (nonatomic, strong) UIBarButtonItem *mDoneBarButton;
@property (nonatomic, strong) UIBarButtonItem *mClearBarButton;
@property (nonatomic, strong) UIBarButtonItem *mCancelBarButton;

@property (nonatomic, strong) UISegmentedControl *mSegmented;

@property (nonatomic, strong) NSMutableArray<WrapCall *> *mWrapCalls;
@property (nonatomic, assign) NSInteger mMaxRecentShow;

@end

@implementation JRRecentCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mMaxRecentShow = 100;
    
    self.mWrapCalls = [[NSMutableArray alloc] init];
    self.tableView.tableFooterView = [UIView new];

    self.mSegmented = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 180.0f, 34.0f) ];
    [self.mSegmented insertSegmentWithTitle:@"所有通话" atIndex:0 animated:YES];
    [self.mSegmented insertSegmentWithTitle:@"未接来电" atIndex:1 animated:YES];
    [self.mSegmented addTarget:self action:@selector(tableChange:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.mSegmented;
    self.mSegmented.selectedSegmentIndex = 0;
    
    self.mEditBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
    self.mDoneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.mClearBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear)];
    self.mCancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancle)];
    
    self.mCalls = [JRCallDBManager getAllCalls];
    @weakify(self)
    self.mCallsNotificationToken = [self.mCalls addNotificationBlock:^(RLMResults<JRCallObject *> * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        @strongify(self)
        [self.mWrapCalls removeAllObjects];
        WrapCall *wrapCall = nil;
        for (JRCallObject *call in self.mCalls) {
            if (!wrapCall) {
                wrapCall = [[WrapCall alloc] init];
                [wrapCall.callLog addObject:call];
                [self.mWrapCalls addObject:wrapCall];
            } else {
                if ([JRNumberUtil isNumberEqual:call.number secondNumber:wrapCall.callLog.firstObject.number]) {
                    [wrapCall.callLog addObject:call];
                } else {
                    wrapCall = [[WrapCall alloc] init];
                    [wrapCall.callLog addObject:call];
                    [self.mWrapCalls addObject:wrapCall];
                }
            }
            if (self.mWrapCalls.count > self.mMaxRecentShow) {
                break;
            }
            if (self.mSegmented.selectedSegmentIndex == 0) {
                [self updateUI:self.editing];
                [self.tableView reloadData];
            }
        }
    }];
    self.mMissCalls = [JRCallDBManager getMissCalls];
    self.mMissCallsNotificationToken = [self.mMissCalls addNotificationBlock:^(RLMResults<JRCallObject *> * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        @strongify(self)
        if (self.mSegmented.selectedSegmentIndex == 0) {
            [self updateUI:self.editing];
            [self.tableView reloadData];
        }
    }];
    
    [self updateUI:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.mCallsNotificationToken invalidate];
    [self.mMissCallsNotificationToken invalidate];
}

- (void)edit {
    [self updateUI:YES];
}

- (void)done {
    [self updateUI:NO];
}

- (void)cancle {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clear {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"DELETE_ALL_CALLS", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (self.mSegmented.selectedSegmentIndex == 0) {
            [JRCallDBManager deleteAllCalls];
        } else {
            [JRCallDBManager deleteMissCalls];
        }
        [self updateUI:NO];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)tableChange:(UISegmentedControl *)sender {
    [self.tableView reloadData];
    [self updateUI:NO];
}

- (void)updateUI:(BOOL)editing {
    int count;
    if (self.mSegmented.selectedSegmentIndex == 0) {
        count = (int)self.mWrapCalls.count;
    } else {
        count = (int)self.mMissCalls.count;
    }
    [self setEditing:editing animated:YES];
    self.navigationItem.leftBarButtonItem = editing ? self.mClearBarButton : self.mCancelBarButton;
    if (count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = editing ? self.mDoneBarButton : self.mEditBarButton;
    }
    [self.tableView setEditing:editing animated:YES];
}

- (UIImage *)getImage:(JRCallObject *)call {
    NSString *imageName;
    UIColor *color;
    if (call.type == JRCallTypeMultiAudio || call.type == JRCallTypeOneOnOneAudio) {
        if (call.direction == JRCallDirectionIn) {
            imageName = @"recents-voice-incoming";
        } else {
            imageName = @"recents-voice-outgoing";
        }
    } else {
        if (call.direction == JRCallDirectionIn) {
            imageName = @"recents-video-incoming";
        } else {
            imageName = @"recents-video-outgoing";
        }
    }
    if (call.state > JRCallStateOk) {
        color = [UIColor redColor];
    } else {
        color = [UIColor blackColor];
    }
    return [[UIImage imageNamed:imageName] imageWithColor:color];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mSegmented.selectedSegmentIndex == 0) {
        return self.mWrapCalls.count;
    } else {
        return self.mMissCalls.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecentCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RecentCellId];
    }
    JRCallObject *call;
    if (self.mSegmented.selectedSegmentIndex == 0) {
        WrapCall *wrapCall = self.mWrapCalls[indexPath.row];
        call = wrapCall.callLog.firstObject;
        if (wrapCall.callLog.count == 1) {
            cell.textLabel.text = call.number;
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", call.number, (int)wrapCall.callLog.count];
        }
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    } else {
        call = self.mMissCalls[indexPath.row];
        cell.textLabel.text = call.number;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.detailTextLabel.text = [MHPrettyDate prettyDateFromDate:[NSDate dateWithTimeIntervalSince1970:[call.beginTime longLongValue]] withFormat:MHPrettyDateFormatTodayTimeOnly];
    cell.imageView.image = [self getImage:call];
    if (call.state > JRCallStateOk) {
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.mWrapCalls.count == 1) {
            [self updateUI:NO];
        }
        WrapCall *wrapCall = self.mWrapCalls[indexPath.row];
        [JRCallDBManager deleteCalls:wrapCall.callLog];
    } else {
        if (self.mMissCalls.count == 1) {
            [self updateUI:NO];
        }
        [JRCallDBManager deleteCall:self.mMissCalls[indexPath.row].beginTime];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath {
    NSArray<JRCallObject *> *logs;
    if (self.mSegmented.selectedSegmentIndex == 0) {
        WrapCall *wrapCall = self.mWrapCalls[indexPath.row];
        logs = wrapCall.callLog;
    } else {
        logs = @[self.mMissCalls[indexPath.row]];
    }
    JRRecentDetailViewController *view = [[JRRecentDetailViewController alloc] initWithLog:logs];
    [self.navigationController pushViewController:view animated:YES];
}

@end
