//
//  JPhotoListView.m
//  JPhotoPicker
//
//  Created by Ginger on 2017/5/24.
//  Copyright © 2017年 Ginger. All rights reserved.
//

#import "JPhotoListView.h"
#import "AJPhotoListCell.h"
#import "JPhotoManger.h"

@interface JPhotoListView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation JPhotoListView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 5;
        layout.itemSize = CGSizeMake((self.frame.size.width - 25)/4, (self.frame.size.width - 25)/4);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[AJPhotoListCell class] forCellWithReuseIdentifier:@"JPhotoListViewCellIdentifier"];
        [self addSubview:_collectionView];
        
        _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_detailBtn setImage:[UIImage imageNamed:@"message_photo_more"] forState:UIControlStateNormal];
        _detailBtn.frame = CGRectMake(10, frame.size.height - 60, 50, 50);
        [_detailBtn addTarget:self action:@selector(detail) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_detailBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 5;
        layout.itemSize = CGSizeMake((self.frame.size.width - 25)/4, (self.frame.size.width - 25)/4);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[AJPhotoListCell class] forCellWithReuseIdentifier:@"JPhotoListViewCellIdentifier"];
        [self addSubview:_collectionView];
    }
}

#pragma mark - uicollectionDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [JPhotoManger sharedInstance].assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPhotoManger *manager = [JPhotoManger sharedInstance];
    static NSString *cellIdentifer = @"JPhotoListViewCellIdentifier";
    AJPhotoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifer forIndexPath:indexPath];

    ALAsset *result = [manager.assets objectAtIndex:indexPath.row];
    ALAsset *first = [manager.indexPathsForSelectedItems firstObject];
    if (manager.indexPathsForSelectedItems.count > 0 && ![[first valueForProperty:ALAssetPropertyType] isEqualToString:[result valueForProperty:ALAssetPropertyType]]) {
        manager.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return NO;
        }];
    } else {
        manager.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return YES;
        }];
    }
    BOOL isSelected = [manager.indexPathsForSelectedItems containsObject:result];
    [cell bind:manager.assets[indexPath.row] selectionFilter:manager.selectionFilter isSelected:isSelected];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat wh = (collectionView.bounds.size.width - 25)/4.0;
    return CGSizeMake(wh, wh);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    JPhotoManger *manager = [JPhotoManger sharedInstance];
    AJPhotoListCell *cell = (AJPhotoListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    ALAsset *asset = manager.assets[indexPath.row];

    //超出最大限制
    if (manager.indexPathsForSelectedItems.count >= manager.maximumNumberOfSelection && ![manager.indexPathsForSelectedItems containsObject:asset]) {
        if (_delegate && [_delegate respondsToSelector:@selector(photoPickerDidMaximum:)]) {
            [_delegate photoPickerDidMaximum:self];
        }
        return;
    }

    //取消选中
    if ([manager.indexPathsForSelectedItems containsObject:asset]) {
        [manager.indexPathsForSelectedItems removeObject:asset];
        [cell isSelected:NO];
        if (_delegate && [_delegate respondsToSelector:@selector(photoPicker:didDeselectAsset:)]) {
            [_delegate photoPicker:self didDeselectAsset:asset];
        }
        if (manager.indexPathsForSelectedItems.count == 0) {
            [self.collectionView reloadData];
        }
        return;
    }
    
    //选择过滤
    BOOL selectable = [manager.selectionFilter evaluateWithObject:asset];
    if (!selectable) {
        if (_delegate && [_delegate respondsToSelector:@selector(photoPickerDidSelectionFilter:)]) {
            [_delegate photoPickerDidSelectionFilter:self];
        }
        return;
    }
    
    //选中
    ALAsset *result = [manager.indexPathsForSelectedItems firstObject];
    if (manager.indexPathsForSelectedItems.count == 0 || [[result valueForProperty:ALAssetPropertyType] isEqualToString:[asset valueForProperty:ALAssetPropertyType]]) {
        [manager.indexPathsForSelectedItems addObject:asset];
        [cell isSelected:YES];
        ALAsset *first = [manager.indexPathsForSelectedItems firstObject];
        if ([[first valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            manager.maximumNumberOfSelection = 9;
        } else {
            manager.maximumNumberOfSelection = 1;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(photoPicker:didSelectAsset:)]) {
            [_delegate photoPicker:self didSelectAsset:asset];
        }
        if (manager.indexPathsForSelectedItems.count == 1) {
            [self.collectionView reloadData];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(photoPicker:didSelectUnexpectedAsset:)]) {
            [_delegate photoPicker:self didSelectUnexpectedAsset:asset];
        }
    }
}

- (void)detail
{
    if ([_delegate respondsToSelector:@selector(presentDetailView)]) {
        [_delegate presentDetailView];
    }
}

- (void)reloadCollectionView
{
    [self.collectionView reloadData];
}

@end
