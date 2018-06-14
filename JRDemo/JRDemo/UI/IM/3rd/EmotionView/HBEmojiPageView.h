//
//  HBEmojiPageView.h
//  MyTest
//
//  Created by weqia on 13-7-26.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HBEmojiPageViewDelegate;

@interface HBEmojiPageView : UIView<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIScrollView * _scrollView;
    UIPageControl * _pageControl;
    NSDictionary * _dic;
}
@property(nonatomic,assign) id<HBEmojiPageViewDelegate> delegate;

@property(nonatomic,readonly) UIButton * sendButton;
@property(nonatomic,readonly) UIButton * deleteButton;

@property(nonatomic,strong) NSArray *faces;

-(void) showInView:(UIView *)view;

-(void)showInView:(UIView *)view withFrame:(CGRect)frame1;

-(void) hide;

-(void)canSend;

-(void)cannotSend;

@end


@protocol HBEmojiPageViewDelegate <NSObject>
@optional
/*
 * 当点击图标调用
 *@param  iconString   图标的内容
 */
-(void)emojiPageView:(HBEmojiPageView*)emojiPageView  iconClick:(NSString*)iconString;
/*
 *点击删除图标调用
 */
-(void)emojiPageViewDeleteClick:(HBEmojiPageView*)emojiPageView actionBlock:(NSString*(^)(NSString* string))block;
/*
 *发送
 */
-(void)emojiPageViewSendClick:(HBEmojiPageView*)emojiPageView;
@end


