//
//  JRMediaPlayViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRMediaPlayViewController.h"
#import "JRMessageManager.h"
#import "JRMessageDBHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JRClientManager.h"

@interface JRMediaPlayViewController () <UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) RLMNotificationToken *token;

@end

@implementation JRMediaPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChanged:) name:kClientStateChangeNotification object:nil];
    
    if (self.message) {
        if (self.message.type == JRMessageItemTypeImage || self.message.type == JRMessageItemTypeVideo || self.message.type == JRMessageItemTypeOtherFile) {
            if (self.message.state != JRMessageItemStateReceiveOK && self.message.direction == JRMessageItemDirectionReceive) {
                JRFileMessageItem *message = [JRMessageDBHelper converFileMessage:self.message];
                if (!message.filePath.length) {
                    NSString *folderName;
                    if (self.message.type == JRMessageItemTypeImage) {
                        folderName = @"image";
                    } else if (self.message.type == JRMessageItemTypeVideo) {
                        folderName = @"video";
                    } else if (self.message.type == JRMessageItemTypeOtherFile) {
                        folderName = @"otherfile";
                    }
                    NSString *fileRelativePath = [JRFileUtil createFilePathWithFileName:message.fileName folderName:folderName peerUserName:self.message.peerNumber];
                    NSString *filePath = [JRFileUtil getAbsolutePathWithFileRelativePath:fileRelativePath];
                    message.filePath = filePath;
                }
                [[JRMessageManager shareInstance] transferFile:message];
                self.imageView.image = [UIImage imageWithContentsOfFile:[JRFileUtil getAbsolutePathWithFileRelativePath:self.message.fileThumbPath]];
            }
        }
        @weakify(self)
        self.token = [self.message addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
            @strongify(self)
            [self updateUI];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [SVProgressHUD dismiss];
    [self.token  invalidate];
    [self.moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stateChanged:(NSNotification *)notification {
    JRClientState state = [(NSNumber *)[notification.userInfo objectForKey:kClientStateKey] intValue];
    if (state != JRClientStateLogined) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LOGIN_FIRST", nil)];
    }
}

- (void)updateUI {
    if (self.message.state == JRMessageItemStateReceiveOK || self.message.direction == JRMessageItemDirectionSend) {
        [SVProgressHUD dismiss];
        if (self.message.type == JRMessageItemTypeImage) {
            self.imageView.image = [UIImage imageWithContentsOfFile:[JRFileUtil getAbsolutePathWithFileRelativePath:self.message.filePath]];
        } else if (self.message.type == JRMessageItemTypeVideo) {
            if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
                return;
            }
            self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[JRFileUtil getAbsolutePathWithFileRelativePath:self.message.filePath]]];
            self.moviePlayer.shouldAutoplay = YES;
            self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
            self.moviePlayer.controlStyle = MPMovieControlStyleNone;
            self.moviePlayer.view.frame = self.imageView.bounds;
            [self.imageView addSubview:self.moviePlayer.view];
            [self.moviePlayer play];
        } else if (self.message.type == JRMessageItemTypeOtherFile) {
            NSString *fileName = [self.message.fileName lowercaseString];
            if ([fileName hasSuffix:@"jpg"] || [fileName hasSuffix:@"jpeg"] || [fileName hasSuffix:@"png"] || [fileName hasSuffix:@"bmp"] || [fileName hasSuffix:@"gif"]) {
                            self.imageView.image = [UIImage imageWithContentsOfFile:[JRFileUtil getAbsolutePathWithFileRelativePath:self.message.filePath]];
            } else if ([fileName hasSuffix:@"mp4"] || [fileName hasSuffix:@"mov"] || [fileName hasSuffix:@"3gp"]) {
                if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
                    return;
                }
                self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[JRFileUtil getAbsolutePathWithFileRelativePath:self.message.filePath]]];
                self.moviePlayer.shouldAutoplay = YES;
                self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
                self.moviePlayer.controlStyle = MPMovieControlStyleNone;
                self.moviePlayer.view.frame = self.imageView.bounds;
                [self.imageView addSubview:self.moviePlayer.view];
                [self.moviePlayer play];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NOT_SUPPORT", nil)];
            }
        }
    } else {
        float progress = [self.message.fileTransSize floatValue] / [self.message.fileSize floatValue];
        [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"%d%%", (int)(progress*100)]];
    }
}

- (IBAction)dismissSelf:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.moviePlayer) {
        self.moviePlayer.view.frame = self.imageView.bounds;
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:[viewController isKindOfClass:[self class]] animated:YES];
}

@end
