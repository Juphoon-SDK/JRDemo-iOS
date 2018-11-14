//
//  JRAtMemberViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/7/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAtMemberViewController.h"
#import "JRGroupDBManager.h"
#import "JRGroupMemberCell.h"
#import "JRNumberUtil.h"

static NSString * const GroupMemberCellId = @"GroupMemberCellId";

@interface JRAtMemberViewController ()

@property (nonatomic, strong) RLMNotificationToken *groupToken;

@property (nonatomic, strong) RLMResults<JRGroupMemberObject *> *members;
@property (nonatomic, strong) RLMNotificationToken *membersToken;

@end

@implementation JRAtMemberViewController

+ (void)presentWithNavigationController:(void (^)(JRAtMemberViewController *))configBlock group:(JRGroupObject *)group presentingViewController:(UIViewController *)viewController {
    JRAtMemberViewController *vc = [[JRAtMemberViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.group = group;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    if (configBlock) {
        configBlock(vc);
    }
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.members = [JRGroupDBManager getGroupMemberWithIdentity:self.group.identity];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"OK", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftBarItemAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"所有成员", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemAction)];
    
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"JRGroupMemberCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:GroupMemberCellId];
    self.tableView.rowHeight = 70.0f;
    self.tableView.editing = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarItemAction {
    if (self.atDelegate && [self.atDelegate respondsToSelector:@selector(atGroupMembers:viewController:)]) {
        NSArray<NSIndexPath *> *select = self.tableView.indexPathsForSelectedRows;
        NSMutableArray<JRGroupMemberObject *> *selectMembers = [NSMutableArray arrayWithCapacity:select.count];
        for (NSIndexPath *indexPath in select) {
            [selectMembers addObject:[self.members objectAtIndex:indexPath.row]];
        }
        [self.atDelegate atGroupMembers:selectMembers viewController:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBarItemAction {
    if (self.atDelegate && [self.atDelegate respondsToSelector:@selector(atAllMembers:)]) {
        [self.atDelegate atAllMembers:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupMemberCellId];
    JRGroupMemberObject *member = [self.members objectAtIndex:indexPath.row];
    cell.nameLabel.text = member.displayName.length ? member.displayName : member.number;
    cell.markLabel.hidden = ![JRNumberUtil isNumberEqual:member.number secondNumber:self.group.chairMan];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JRGroupMemberObject *member = [self.members objectAtIndex:indexPath.row];
    if ([JRNumberUtil isNumberEqual:member.number secondNumber:[JRClient sharedInstance].currentNumber]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
