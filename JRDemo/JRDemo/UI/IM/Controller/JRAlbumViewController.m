//
//  JRAlbumViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/23.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAlbumViewController.h"
#import "JPhotoListView.h"
#import "JPhotoManger.h"

@interface JRAlbumViewController () <JPhotoPickerProtocol>

@property (weak, nonatomic) IBOutlet JPhotoListView *albumView;
@property (weak, nonatomic) IBOutlet UIButton *originalBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@end

@implementation JRAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"ALBUM", nil);
    self.albumView.delegate = self;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING_ASSET", nil)];
    [[JPhotoManger sharedInstance] laodAssetsWithCompleteBlock:^(bool succeed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (!succeed) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"LOADING_ASSET_FAILED", nil)];
            } else {
                [self.albumView reloadCollectionView];
            }
        });
    }];
    [self updateToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[JPhotoManger sharedInstance] clearAll];
}

- (void)updateToolBar {
    [self.sendBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"SEND_FILE", nil), (unsigned long)[JPhotoManger sharedInstance].indexPathsForSelectedItems.count, (long)[JPhotoManger sharedInstance].maximumNumberOfSelection] forState:UIControlStateNormal];
    [self.originalBtn setTitle:NSLocalizedString(@"ORIGINAL_IMAGE", nil) forState:UIControlStateNormal | UIControlStateSelected];
}

- (IBAction)original:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)send:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSArray<ALAsset *> *assets = [JPhotoManger sharedInstance].indexPathsForSelectedItems;
        BOOL isVideo = NO;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:assets.count];
        for (ALAsset *asset in assets) {
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            if ([type isEqualToString:ALAssetTypePhoto]) {
                // 图片
                UIImage *image;
                if (!self.originalBtn.isSelected) {
                    image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
                } else {
                    image = [UIImage imageWithCGImage:[representation fullScreenImage]];
                }
                NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
                [array addObject:imageData];
            } else if ([type isEqualToString:ALAssetTypeVideo]) {
                // 视频
                isVideo = YES;
                long long size = representation.size;
                NSMutableData* data = [[NSMutableData alloc] initWithCapacity:size];
                void* buffer = [data mutableBytes];
                [representation getBytes:buffer fromOffset:0 length:size error:nil];
                NSData *fileData = [[NSData alloc] initWithBytes:buffer length:size];
                [array addObject:fileData];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(fileSelected:isVideo:)] && array.count) {
                [self.delegate fileSelected:array isVideo:isVideo];
            }
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

// 点击选中
- (void)photoPicker:(JPhotoListView *)picker didSelectAsset:(ALAsset *)asset {
    [self updateToolBar];
}

// 取消选中
- (void)photoPicker:(JPhotoListView *)picker didDeselectAsset:(ALAsset *)asset {
    [self updateToolBar];
}

// 超过最大选择项时
- (void)photoPickerDidMaximum:(JPhotoListView *)picker {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ABOVE_THE_LIMIT", nil)];
}

// 低于最低选择项时
- (void)photoPickerDidMinimum:(JPhotoListView *)picker {
    
}

// 选择过滤
- (void)photoPickerDidSelectionFilter:(JPhotoListView *)picker {

}

// 选择了多类型的文件
- (void)photoPicker:(JPhotoListView *)picker didSelectUnexpectedAsset:(ALAsset *)asset {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"CAN_NOT_SELECT_MULTI_TYPE", nil)];
}

@end
