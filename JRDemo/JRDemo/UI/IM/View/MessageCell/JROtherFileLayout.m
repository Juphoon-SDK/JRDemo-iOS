//
//  JROtherFileLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JROtherFileLayout.h"
#import "JRFileUtil.h"

#define ThumbSize 50
#define LabelHeight 20
#define OtherFileMargin 10

@implementation JROtherFileLayout

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName {
    [super configWithMessage:message shouldShowTime:showTime shouldShowName:showName];
    
    if (self.message.fileThumbPath.length) {
        _fileThumbImage = [UIImage imageWithContentsOfFile:[JRFileUtil getAbsolutePathWithFileRelativePath:self.message.fileThumbPath]];
    } else {
        _fileThumbImage = [UIImage imageNamed:@"ic_default_file"];
    }
    _fileThumbFram = CGRectMake(OtherFileMargin, OtherFileSize.height/2 - ThumbSize/2, ThumbSize, ThumbSize);
    _fileName = self.message.fileName;
    _fileNameFram = CGRectMake(CGRectGetMaxX(_fileThumbFram) + OtherFileMargin, _fileThumbFram.origin.y, OtherFileSize.width - 3 * OtherFileMargin - ThumbSize, LabelHeight);
    NSInteger mb = [message.fileSize floatValue] / 1024.0 / 1024.0;
    if (mb) {
        _fileSize = [NSString stringWithFormat:@"%.1fMB", [message.fileSize floatValue] / 1024.0 / 1024.0];
    } else {
        _fileSize = [NSString stringWithFormat:@"%.1fKB", [message.fileSize floatValue] / 1024.0];
    }
    _fileSizeFram = CGRectMake(_fileNameFram.origin.x, CGRectGetMaxY(_fileNameFram) + OtherFileMargin, _fileNameFram.size.width, LabelHeight);
    self.bubbleViewBackgroupColor = [UIColor whiteColor];
}

@end
