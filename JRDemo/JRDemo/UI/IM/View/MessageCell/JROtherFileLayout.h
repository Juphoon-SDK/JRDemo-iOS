//
//  JROtherFileLayout.h
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRBaseBubbleLayout.h"

@interface JROtherFileLayout : JRBaseBubbleLayout

@property (nonatomic, strong) UIImage *fileThumbImage;
@property (nonatomic, assign) CGRect fileThumbFram;

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) CGRect fileNameFram;

@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, assign) CGRect fileSizeFram;

@end
