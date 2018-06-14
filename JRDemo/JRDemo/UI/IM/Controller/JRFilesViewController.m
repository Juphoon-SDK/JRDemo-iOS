//
//  JRFilesViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/27.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRFilesViewController.h"
#import "JRMessageDBHelper.h"
#import "JRFileCell.h"
#import "JRMediaPlayViewController.h"

#define FileCell @"filePath"

@interface JRFilesViewController () <JRFileCellDelegate>

@property (nonatomic, strong) NSArray<JRMessageObject *> *files;

@end

@implementation JRFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"OTHER_FILES", nil);
    
    self.files = [JRMessageDBHelper getOtherFileMessages];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"JRFileCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:FileCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.files.count) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NO_OTHER_FILES", nil)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRFileCell *cell = [tableView dequeueReusableCellWithIdentifier:FileCell];
    [cell setDelegate:self tableView:self.tableView];
    JRMessageObject *message = [self.files objectAtIndex:indexPath.row];
    cell.thumbView.image = [UIImage imageNamed:@"ic_default_file"];
    cell.nameLabel.text = message.fileName;
    NSInteger mb = [message.fileSize floatValue] / 1024.0 / 1024.0;
    if (mb) {
        cell.sizeLabel.text = [NSString stringWithFormat:@"%.1fMB", [message.fileSize floatValue] / 1024.0 / 1024.0];
    } else {
        cell.sizeLabel.text = [NSString stringWithFormat:@"%.1fKB", [message.fileSize floatValue] / 1024.0];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JRMediaPlayViewController *view = [[JRMediaPlayViewController alloc] init];
    view.message = [self.files objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - JRFileCell Delegate

- (void)tableView:(UITableView *)tableView sendMessage:(NSIndexPath *)index {
    JRMessageObject *message = [self.files objectAtIndex:index.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileSelected:)] && message.filePath.length) {
        [self.delegate fileSelected:message.filePath];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SEND_MESSAGE_FAILED", nil)];
    }
}

@end
