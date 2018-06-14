//
//  JROtherFileMessageCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JROtherFileMessageCell.h"
#import "JROtherFileLayout.h"

@implementation JROtherFileMessageCell

- (void)configWithLayout:(JRBaseBubbleLayout *)layout {
    [super configWithLayout:layout];
    if (!_fileThumbImageView) {
        _fileThumbImageView = [[UIImageView alloc] init];
        [self.msgContentView addSubview:_fileThumbImageView];
    }
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.textColor = [UIColor blackColor];
        _fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.msgContentView addSubview:_fileNameLabel];
    }
    if (!_fileSizeLabel) {
        _fileSizeLabel = [[UILabel alloc] init];
        _fileSizeLabel.textColor = [UIColor grayColor];
        [self.msgContentView addSubview:_fileSizeLabel];
    }
    
    JROtherFileLayout *tempLayout = (JROtherFileLayout *)layout;
    _fileThumbImageView.image = tempLayout.fileThumbImage;
    _fileNameLabel.text = tempLayout.fileName;
    _fileSizeLabel.text = tempLayout.fileSize;
    self.bubbleView.backgroundColor = layout.bubbleViewBackgroupColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    JROtherFileLayout *tempLayout = (JROtherFileLayout *)self.layout;
    _fileThumbImageView.frame = tempLayout.fileThumbFram;
    _fileNameLabel.frame = tempLayout.fileNameFram;
    _fileSizeLabel.frame = tempLayout.fileSizeFram;
}

@end
