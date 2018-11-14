//
//  JRGroupsListViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupsListViewController.h"
#import "JRGroupCell.h"
#import "JRGroupDetailViewController.h"
#import "JRGroupManager.h"
#import "JRGroupDBManager.h"
#import "JRChatViewController.h"

static NSString * const GroupCellId = @"GroupCellId";

@interface JRGroupsListViewController () <JRGroupCellDelegate>

@property (nonatomic, strong) RLMResults<JRGroupObject *> *groupList;
@property (nonatomic, strong) RLMNotificationToken *groupListToken;

@property (nonatomic, strong) RLMResults<JRGroupObject *> *pendingGroupList;
@property (nonatomic, strong) RLMNotificationToken *pendingGroupListToken;

@end

@implementation JRGroupsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithDB];
    [[JRGroupManager sharedInstance] subscribeGroupList];
    
    self.title = NSLocalizedString(@"GROUP_LIST", nil);
    self.tableView.rowHeight = 70.0f;
    [self.tableView registerNib:[UINib nibWithNibName:@"JRGroupCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:GroupCellId];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"friend_add"] style:UIBarButtonItemStyleDone target:self action:@selector(addGroup)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self.groupListToken invalidate];
}

- (void)initWithDB {
    RLMRealm *realm = [JRRealmWrapper getRealmInstance];
    if (realm) {
        @weakify(self)
        self.groupList = [JRGroupDBManager getGroupsWithState:JRGroupStatusStarted];
        self.groupListToken = [self.groupList addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
            @strongify(self)
            [self.tableView reloadData];
        }];
        self.pendingGroupList = [JRGroupDBManager getGroupsWithState:JRGroupStatusInvited];
        self.pendingGroupListToken = [self.pendingGroupList addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
            @strongify(self)
            [self.tableView reloadData];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"GET_GROUPS_FAILED", nil)];
    }
}

- (void)addGroup {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NEW_GROUP", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"INPUT_GROUP_NAME", nil);
        textField.text = nil;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"INPUT_PEER_NUMBER", nil);
        textField.text = nil;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alert.textFields.firstObject.text;
        NSString *number = alert.textFields.lastObject.text;
        if (number.length) {
            [[JRGroupManager sharedInstance] create:name numbers:[number componentsSeparatedByString:@","]];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.pendingGroupList.count;
    } else {
        return self.groupList.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.pendingGroupList.count) {
            return @"新邀请";
        }
    } else {
        if (self.groupList.count) {
            return @"群列表";
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRGroupObject *obj;
    if (indexPath.section == 0) {
        obj = [self.pendingGroupList objectAtIndex:indexPath.row];
    } else {
        obj = [self.groupList objectAtIndex:indexPath.row];
    }
    JRGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCellId];
    cell.groupNameLabel.text = obj.name;
    if (obj.type == JRGroupTypeGeneral) {
        cell.groupTypeLabel.text = @"普通群";
    } else if (obj.type == JRGroupTypeEnterprise) {
        cell.groupTypeLabel.text = @"企业群";
    } else if (obj.type == JRGroupTypeParty) {
        cell.groupTypeLabel.text = @"党群";
    } else {
        cell.groupTypeLabel.text = @"未知类型";
    }
    [cell setDelegate:self tableView:self.tableView pending:indexPath.section == 0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        JRChatViewController *view = [[JRChatViewController alloc] initWithGroup:[self.groupList objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:view animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView reject:(NSIndexPath *)indexPath {
    [[JRGroupManager sharedInstance] rejectInvite:[self.pendingGroupList objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView accept:(NSIndexPath *)indexPath {
    [[JRGroupManager sharedInstance] acceptInvite:[self.pendingGroupList objectAtIndex:indexPath.row]];
}

@end
