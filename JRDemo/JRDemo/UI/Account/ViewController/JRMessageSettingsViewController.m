//
//  JRMessageSettingsViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/7/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRMessageSettingsViewController.h"
#import "JRSwitchCell.h"

typedef NS_ENUM(NSInteger, MessageSettingSection) {
    MessageSettingSectionImdn,
    MessageSettingSectionCount,
};

typedef NS_ENUM(NSInteger, ImdnSettingRow) {
    ImdnSettingRowDeliSucc,
    ImdnSettingRowDeliFail,
    ImdnSettingRowDeliForward,
    ImdnSettingRowDisp,
    ImdnSettingRowCount,
};

static NSString * const SwitchCellId = @"SwitchCellId";

@interface JRMessageSettingsViewController ()

@property (nonatomic, strong) JRSwitchCell *mMessageDeliSuccCell;
@property (nonatomic, strong) JRSwitchCell *mMessageDeliFailCell;
@property (nonatomic, strong) JRSwitchCell *mMessageDeliForwardCell;
@property (nonatomic, strong) JRSwitchCell *mMessageDispCell;

@end

@implementation JRMessageSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息设置";
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

#pragma mark - Table view data source

- (void)initCell {
    self.mMessageDeliSuccCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mMessageDeliSuccCell.titleLabel.text = @"送达成功回执";
    self.mMessageDeliSuccCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyImdnDeliSuccRptSupt].boolParam;
    
    self.mMessageDeliFailCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mMessageDeliFailCell.titleLabel.text = @"送达失败回执";
    self.mMessageDeliFailCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyImdnDeliFailRptSupt].boolParam;
    
    self.mMessageDeliForwardCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mMessageDeliForwardCell.titleLabel.text = @"短信送达成功回执";
    self.mMessageDeliForwardCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyImdnDeliForwardRptSupt].boolParam;
    
    self.mMessageDispCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    self.mMessageDispCell.titleLabel.text = @"已读回执";
    self.mMessageDispCell.switchView.on = [JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyImdnSendDispReqEnable].boolParam;
}

- (void)save {
    JRAccountConfigParam *deliSuccParam = [[JRAccountConfigParam alloc] init];
    deliSuccParam.boolParam = self.mMessageDeliSuccCell.switchView.isOn;
    [JRAccount setAccount:self.account config:deliSuccParam forKey:JRAccountConfigKeyImdnDeliSuccRptSupt];
    
    JRAccountConfigParam *deliFailParam = [[JRAccountConfigParam alloc] init];
    deliFailParam.boolParam = self.mMessageDeliFailCell.switchView.isOn;
    [JRAccount setAccount:self.account config:deliFailParam forKey:JRAccountConfigKeyImdnDeliFailRptSupt];
    
    JRAccountConfigParam *deliForwardParam = [[JRAccountConfigParam alloc] init];
    deliForwardParam.boolParam = self.mMessageDeliForwardCell.switchView.isOn;
    [JRAccount setAccount:self.account config:deliForwardParam forKey:JRAccountConfigKeyImdnDeliForwardRptSupt];
    
    JRAccountConfigParam *dispParam = [[JRAccountConfigParam alloc] init];
    dispParam.boolParam = self.mMessageDispCell.switchView.isOn;
    [JRAccount setAccount:self.account config:dispParam forKey:JRAccountConfigKeyImdnSendDispReqEnable];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MessageSettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == MessageSettingSectionImdn) {
        return ImdnSettingRowCount;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == MessageSettingSectionImdn) {
        return @"IMDN";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MessageSettingSectionImdn) {
        switch (indexPath.row) {
            case ImdnSettingRowDeliSucc:
                return self.mMessageDeliSuccCell;
            case ImdnSettingRowDeliFail:
                return self.mMessageDeliFailCell;
            case ImdnSettingRowDeliForward:
                return self.mMessageDeliForwardCell;
            case ImdnSettingRowDisp:
                return self.mMessageDispCell;
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
@end
