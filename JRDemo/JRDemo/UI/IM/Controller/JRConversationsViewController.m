//
//  JRConversationsViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/6.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRConversationsViewController.h"
#import "JRChatViewController.h"
#import "JRRealmWrapper.h"
#import "JRConversationCell.h"
#import "JRMessageDBHelper.h"
#import "JRNumberUtil.h"
#import "JRGroupDBManager.h"

#define ConversationCellStr @"ConversationCell"

@interface JRConversationsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RLMResults<JRConversationObject *> *conversationsArray;
@property (nonatomic, strong) RLMNotificationToken *token;

@end

@implementation JRConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"MESSAGE", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(newChat)];
    
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        self.conversationsArray = [[JRConversationObject allObjectsInRealm:realm] sortedResultsUsingKeyPath:@"updateTime" ascending:NO];
        @weakify(self)
        self.token = [self.conversationsArray addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
            @strongify(self)
            [self.tableView reloadData];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"GET_CONVERSATIONS_FAILED", nil)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.conversationsArray.count) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NO_CONVERSATION", nil)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self.token invalidate];
}

- (void)newChat {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NEW_CONVERSATION", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"INPUT_PEER_NUMBER", nil);
        textField.text = nil;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *number = alert.textFields.firstObject.text;
        if (number.length) {
            JRChatViewController *view = [[JRChatViewController alloc] initWithPhone:[JRNumberUtil numberWithChineseCountryCode:number]];
            [self.navigationController pushViewController:view animated:YES];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Views

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect viewRect = self.view.frame;
        viewRect.size.height -= self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height;
        _tableView = [[UITableView alloc] initWithFrame:viewRect style:UITableViewStylePlain];
        //        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70.0;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerNib:[UINib nibWithNibName:@"JRConversationCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:ConversationCellStr];
    }
    return _tableView;
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:ConversationCellStr];
    [cell configWithConversation:self.conversationsArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JRConversationObject *conversation = self.conversationsArray[indexPath.row];
    JRChatViewController *view;
    if (conversation.isGroup) {
        view = [[JRChatViewController alloc] initWithGroup:[JRGroupDBManager getGroupWithIdentity:conversation.peerNumber]];
    } else {
         view = [[JRChatViewController alloc] initWithPhone:conversation.peerNumber];
    }
    [self.navigationController pushViewController:view animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"DELETE_CONVERSATION", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        JRConversationObject *conversation = self.conversationsArray[indexPath.row];
        if (conversation.peerNumber.length) {
            [JRMessageDBHelper deleteConversationWithNumber:conversation.peerNumber group:conversation.isGroup];
        }
    }
}

@end
