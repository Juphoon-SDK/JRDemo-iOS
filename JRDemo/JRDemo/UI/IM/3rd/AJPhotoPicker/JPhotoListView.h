//
//  JPhotoListView.h
//  JPhotoPicker
//
//  Created by Ginger on 2017/5/24.
//  Copyright © 2017年 Ginger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class JPhotoListView;
@protocol JPhotoPickerProtocol <NSObject>
@optional

//点击选中
- (void)photoPicker:(JPhotoListView *)picker didSelectAsset:(ALAsset*)asset;
//取消选中
- (void)photoPicker:(JPhotoListView *)picker didDeselectAsset:(ALAsset*)asset;
//超过最大选择项时
- (void)photoPickerDidMaximum:(JPhotoListView *)picker;
//低于最低选择项时
- (void)photoPickerDidMinimum:(JPhotoListView *)picker;
//选择过滤
- (void)photoPickerDidSelectionFilter:(JPhotoListView *)picker;
//选择了多类型的文件
- (void)photoPicker:(JPhotoListView *)picker didSelectUnexpectedAsset:(ALAsset*)asset;

- (void)presentDetailView;

@end

@interface JPhotoListView : UIView 

@property (nonatomic, weak) id<JPhotoPickerProtocol> delegate;
@property (nonatomic, strong) UIButton *detailBtn;

- (void)reloadCollectionView;

@end
