//
//  JRAdvancedCodecViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/12.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAdvancedCodecViewController.h"
#import "JRSwitchCell.h"

static NSString * const SwitchCellId = @"SwitchCellId";

@interface JRAdvancedCodecViewController ()

@property (nonatomic, strong) NSMutableArray *mEnableCodecArray;
@property (nonatomic, strong) NSMutableArray *mAllCodecArray;
@property (nonatomic, strong) NSMutableArray *mDisableCodecArray;

@end

@implementation JRAdvancedCodecViewController

- (JRSwitchCell *)switchCell:(NSString *)textLabel isSwitchOn:(BOOL)isOn atIndex:(NSInteger)index isEnable:(BOOL)enable {
    JRSwitchCell *switchCell = [self.tableView dequeueReusableCellWithIdentifier:SwitchCellId];
    switchCell.switchView.enabled = enable;
    switchCell.switchView.on = isOn;
    switchCell.titleLabel.text = textLabel;
    switchCell.switchView.tag = index;
    [switchCell.switchView addTarget:self action:@selector(switchViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    return switchCell;
}

- (void)switchViewValueChanged:(UISwitch *)switchView {
    NSString *codec = [NSString string];
    BOOL enable = switchView.isOn;
    if (enable) {
        codec = [self.mDisableCodecArray objectAtIndex:switchView.tag];
        [self.mEnableCodecArray addObject:codec];
        [self.mDisableCodecArray removeObject:codec];
    } else {
        if (self.mEnableCodecArray.count == 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NO_CODEC_DESCRIPTION", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        codec = [self.mEnableCodecArray objectAtIndex:switchView.tag];
        [self.mEnableCodecArray removeObject:codec];
        [self.mDisableCodecArray addObject:codec];
    }
    
    [self.tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"JRSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SwitchCellId];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.codecType == JRAccountConfigKeyAudioCodec) {
        self.mAllCodecArray = [NSMutableArray arrayWithObjects:@"PCMU", @"PCMA", @"G729", @"G722", @"opus", @"AMR", @"AMR-WB", @"iLBC", nil];
        self.mEnableCodecArray = [NSMutableArray arrayWithArray:[[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyAudioCodec].stringParam componentsSeparatedByString:@","]];
        self.title = NSLocalizedString(@"AUDIO_CODEC", nil);
    } else if (self.codecType == JRAccountConfigKeyVideoCodec) {
        self.mAllCodecArray = [NSMutableArray arrayWithObjects:@"H264", @"H264-SVC", nil];
        self.mEnableCodecArray = [NSMutableArray arrayWithArray:[[JRAccount getAccountConfig:self.account forKey:JRAccountConfigKeyVideoCodec].stringParam componentsSeparatedByString:@","]];
        self.title = NSLocalizedString(@"VIDEO_CODEC", nil);
    }
    self.mDisableCodecArray = [[NSMutableArray alloc] init];
    for (NSString *codec in self.mAllCodecArray) {
        if (![self.mEnableCodecArray containsObject:codec]) {
            [self.mDisableCodecArray addObject:codec];
        }
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

- (void)save {
    if (!self.mEnableCodecArray.count) {
        [SVProgressHUD showErrorWithStatus:@"未选择编解码，将采用默认编解码"];
    }
    JRAccountConfigParam *codecParam = [[JRAccountConfigParam alloc] init];
    codecParam.stringParam = [self.mEnableCodecArray componentsJoinedByString:@","];
    if (self.codecType == JRAccountConfigKeyAudioCodec) {
        [JRAccount setAccount:self.account config:codecParam forKey:JRAccountConfigKeyAudioCodec];
    } else if (self.codecType == JRAccountConfigKeyVideoCodec) {
        [JRAccount setAccount:self.account config:codecParam forKey:JRAccountConfigKeyVideoCodec];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isEditing) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.mEnableCodecArray.count;
    } else {
        return self.mDisableCodecArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL enable = YES;
    BOOL isOn = (indexPath.section == 0);
    NSString *codec = @"";
    
    if (indexPath.section == 0) {
        codec = [self.mEnableCodecArray objectAtIndex:indexPath.row];
    } else {
        codec = [self.mDisableCodecArray objectAtIndex:indexPath.row];
    }
    
    JRSwitchCell *cell = [self switchCell:codec isSwitchOn:isOn atIndex:indexPath.row isEnable:enable];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSString *element = [self.mEnableCodecArray objectAtIndex:fromIndexPath.row];
    [self.mEnableCodecArray removeObjectAtIndex:fromIndexPath.row];
    [self.mEnableCodecArray insertObject:element atIndex:toIndexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
