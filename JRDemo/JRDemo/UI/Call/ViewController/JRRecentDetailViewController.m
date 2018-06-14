//
//  JRRecentDetailViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/4/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRRecentDetailViewController.h"
#import "UIImage+Tint.h"
#import "MHPrettyDate.h"

static NSString * const LogCellId = @"LogCellId";

@interface JRRecentDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray<JRCallObject *> *logs;

@end

@implementation JRRecentDetailViewController

- (instancetype)initWithLog:(NSArray<JRCallObject *> *)calls {
    if ([super initWithNibName:@"JRRecentDetailViewController" bundle:[NSBundle mainBundle]]) {
        self.logs = calls;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.logs.firstObject.number;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LogCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:LogCellId];
    }
    JRCallObject *call = [self.logs objectAtIndex:indexPath.row];
    cell.imageView.image = [self getImage:call];
    cell.textLabel.text = [MHPrettyDate prettyDateFromDate:[NSDate dateWithTimeIntervalSince1970:[call.beginTime longLongValue]] withFormat:MHPrettyDateFormatTodayTimeOnly];
    if (call.state == JRCallStateOk) {
        cell.detailTextLabel.text = [self formatTime:(int)([call.endTime longLongValue] - [call.talkingBeginTime longLongValue])];
    } else {
        switch (call.state) {
            case JRCallStateCancel:
            case JRCallStateMissed:
                cell.detailTextLabel.text = @"未接来电";
                break;
            default:
                cell.detailTextLabel.text = @"拒接";
                break;
        }
        
    }
    return cell;
}

- (NSString *)formatTime:(int)timeStamp {
    int s = timeStamp % 60;
    int m = (timeStamp - s) / 60 % 60;
    int h = ((timeStamp - s) / 60 - m) / 60 % 24;
    if (h > 0) {
        return [NSString stringWithFormat:@"%d:%d:%d", h, m, s];
    } else {
        if (m > 0) {
            return [NSString stringWithFormat:@"%d:%d", m, s];
        } else {
            return [NSString stringWithFormat:@"%d秒", s];
        }
    }
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


@end
