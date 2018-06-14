//
//  JREditCell.m
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JREditCell.h"

@interface JREditCell () <UITextFieldDelegate>

@property (nonatomic, weak) id <JREditCellDelegate> delegate;
@property (nonatomic, weak) UITableView *wTableView;

@end

@implementation JREditCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textField.delegate = self;
    self.mMaxNumber = 0x7FFFFFFF;
    self.mMinNumber = 0x80000000;
    self.mOnlyNumber = false;
    self.delegate = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setEnabled:(BOOL)enabled {
    self.textField.enabled = enabled;
    if (enabled) {
        self.textField.textColor = [UIColor blackColor];
    } else {
        self.textField.textColor = [UIColor grayColor];
    }
}

- (void)setDelegate:(id<JREditCellDelegate>)delegate tableView:(UITableView *)tableView {
    self.delegate = delegate;
    self.wTableView = tableView;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (!textField.text.length) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:invalididValue:)]) {
            [self.delegate tableView:self.wTableView invalididValue:self];
        }
        return false;
    }
    if ((textField.text.length && self.mOnlyNumber)) {
        if (![self isPureInt:textField.text]) {
            if (self.mMinNumber != 0x80000000) {
                textField.text = [NSString stringWithFormat:@"%d", self.mMinNumber];
            } else {
                textField.text = @"0";
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:invalididValue:)]) {
                [self.delegate tableView:self.wTableView invalididValue:self];
            }
            return false;
        }
    }
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.mMaxNumber != 0x7FFFFFFF && self.mMinNumber != 0x80000000 && textField.text.length && self.mOnlyNumber) {
        int textNumber = [textField.text intValue];
        if (textNumber > self.mMaxNumber) {
            textField.text = [NSString stringWithFormat:@"%d", self.mMaxNumber];
            if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:outMax:cell:)]) {
                [self.delegate tableView:self.wTableView outMax:self.mMaxNumber cell:self];
            }
        } else if (textNumber < self.mMinNumber) {
            textField.text = [NSString stringWithFormat:@"%d", self.mMinNumber];
            if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:outMin:cell:)]) {
                [self.delegate tableView:self.wTableView outMin:self.mMaxNumber cell:self];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

#pragma mark - Private Function

// 判断是否纯数字
- (BOOL)isPureInt:(NSString *)string{
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

@end
