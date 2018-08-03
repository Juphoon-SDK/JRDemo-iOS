//
//  JRGroupMembersViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/4/19.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRGroupMembersViewController.h"
#import "JRGroupMemberCell.h"
#import "JRGroupDBManager.h"
#import "JRNumberUtil.h"
#import "JRGroupManager.h"
#import "JRMessageManager.h"

static NSString * const GroupMemberCellId = @"GroupMemberCellId";

@interface JRGroupMembersViewController ()

@property (nonatomic, strong) JRGroupObject *group;
@property (nonatomic, strong) RLMNotificationToken *groupToken;

@property (nonatomic, strong) RLMResults<JRGroupMemberObject *> *members;
@property (nonatomic, strong) RLMNotificationToken *membersToken;

@end

@implementation JRGroupMembersViewController

- (instancetype)initWithGroup:(JRGroupObject *)group {
    if ([super initWithStyle:UITableViewStyleGrouped]) {
        self.group = group;
        self.members = [JRGroupDBManager getGroupMemberWithIdentity:group.identity];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"JRGroupMemberCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:GroupMemberCellId];
    self.tableView.rowHeight = 70.0f;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"friend_add"] style:UIBarButtonItemStyleDone target:self action:@selector(addMember)];
    
    @weakify(self)
    self.groupToken = [self.group addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
        @strongify(self)
        if (deleted) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
        
        [self.tableView reloadData];
    }];
    
    self.membersToken = [self.members addNotificationBlock:^(RLMResults<JRGroupMemberObject *> * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addMember {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NEW_CONVERSATION", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"INPUT_PEER_NUMBER", nil);
        textField.text = nil;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *number = alert.textFields.firstObject.text;
        if (number.length) {
            [[JRGroupManager sharedInstance] invite:self.group newMembers:@[[JRNumberUtil numberWithChineseCountryCode:number]]];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupMemberCellId];
    JRGroupMemberObject *member = [self.members objectAtIndex:indexPath.row];
    cell.nameLabel.text = member.displayName.length ? member.displayName : member.number;
    cell.markLabel.hidden = ![JRNumberUtil isNumberEqual:member.number secondNumber:self.group.chairMan];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JRGroupMemberObject *member = [self.members objectAtIndex:indexPath.row];
    if ([JRNumberUtil isNumberEqual:member.number secondNumber:[JRClient sharedInstance].currentNumber]) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *change = [UIAlertAction actionWithTitle:@"转让群主" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[JRGroupManager sharedInstance] modifyChairman:self.group newChairman:[self.members objectAtIndex:indexPath.row].number];
    }];
    UIAlertAction *kick = [UIAlertAction actionWithTitle:@"踢出群聊" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[JRGroupManager sharedInstance] kick:self.group members:@[[self.members objectAtIndex:indexPath.row].number]];
    }];
    UIAlertAction *exchange = [UIAlertAction actionWithTitle:@"交换名片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        JRGroupMemberObject *selfMember = [JRGroupDBManager getGroupMemberWithIdentity:self.group.identity number:[JRClient sharedInstance].currentNumber];
        NSString *content = JRCreateVCardContent(selfMember.displayName, selfMember.number, @"", @"", [NSString stringWithFormat:@"我是群聊%@里的%@，希望可以和你交换名片", self.group.name, selfMember.displayName]);
        if ([[JRMessageManager shareInstance] sendTextMessage:content number:[self.members objectAtIndex:indexPath.row].number contentType:JRTextMessageContentTypeExchangeVCard convId:nil]) {
            [SVProgressHUD showSuccessWithStatus:@"交换请求已发送"];
            [SVProgressHUD dismissWithDelay:1.5];
        };
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    if ([self isChairman]) {
        [alert addAction:change];
        [alert addAction:kick];
        [alert addAction:exchange];
        [alert addAction:cancel];
    } else {
        [alert addAction:exchange];
        [alert addAction:cancel];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isChairman {
    return [JRNumberUtil isNumberEqual:[JRClient sharedInstance].currentNumber secondNumber:self.group.chairMan];
}

@end
