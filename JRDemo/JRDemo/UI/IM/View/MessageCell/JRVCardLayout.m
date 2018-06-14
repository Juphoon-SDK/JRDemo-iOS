//
//  JRVCardLayout.m
//  JRDemo
//
//  Created by Ginger on 2018/2/26.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRVCardLayout.h"
#import "JRFileUtil.h"
#import <AddressBook/AddressBook.h>

#define VCardMargin 5
#define VIconSize 40
#define VLabelHeight 20

@implementation JRVCardLayout

- (void)configWithMessage:(JRMessageObject *)message shouldShowTime:(BOOL)showTime shouldShowName:(BOOL)showName {
    [super configWithMessage:message shouldShowTime:showTime shouldShowName:showName];
    
    NSArray *contactArray = [JRFileUtil addressBookRecordsWithRelativePath:self.message.filePath error:nil];
    if (contactArray.count > 0) {
        ABRecordRef record = (__bridge_retained ABRecordRef)[contactArray objectAtIndex:0];
        _vIconImage = [self ContactsGetPersonThumb:record];
        _vName = [self ContactsGetPersonName:record];
        _vNumber = [self ContactsGetPersonPhone:record];
    }
    self.bubbleViewBackgroupColor = [UIColor whiteColor];
    _vIconFrame = CGRectMake(VCardSize.width/2 - VIconSize/2, VCardMargin, VIconSize, VIconSize);
    _vNameLabelFrame = CGRectMake(0, CGRectGetMaxY(_vIconFrame) + VCardMargin, VCardSize.width, VLabelHeight);
    _vNumberLabelFrame = CGRectMake(0, CGRectGetMaxY(_vNameLabelFrame) + VCardMargin, VCardSize.width, VLabelHeight);
}

#warning 联系人相关方法，暂时放这

- (NSString *)ContactsGetPersonPhone:(ABRecordRef)record
{
    NSString *phone = nil;
    ABMultiValueRef phones = ABRecordCopyValue(record, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phones)) {
        phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, 0);
    }
    if (phones) CFRelease(phones);
    
    return phone;
}

- (UIImage *)ContactsGetPersonThumb:(ABRecordRef)record
{
    if (!record) return nil;
    UIImage *thumb = nil;
    NSData *imageData = ((__bridge_transfer NSData *)(ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail)));
    if (imageData) {
        thumb = [[UIImage alloc] initWithData:imageData];
    } else {
        thumb = [UIImage imageNamed:@"img_blueman_nor"];
    }
    
    return thumb;
}

- (NSString *)ContactsGetPersonName:(ABRecordRef)record
{
    CFStringRef name = ABRecordCopyCompositeName(record);
    if (name) {
        return (__bridge_transfer NSString *)name;
    } else {
        NSString *text;
        ABMultiValueRef phones = ABRecordCopyValue(record, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phones)) {
            CFStringRef phone = ABMultiValueCopyValueAtIndex(phones, 0);
            text = (__bridge_transfer NSString *)phone;
        }
        if (phones) CFRelease(phones);
        return text;
    }
}

@end
