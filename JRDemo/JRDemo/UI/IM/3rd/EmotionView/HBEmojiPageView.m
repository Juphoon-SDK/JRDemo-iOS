//
//  HBEmojiPageView.m
//  MyTest
//
//  Created by weqia on 13-7-26.
//  Copyright (c) 2013年 weqia. All rights reserved.
//

#import "HBEmojiPageView.h"
#import "EmojiEmoticons.h"
#import "EmojiMapSymbols.h"
#import "EmojiPictographs.h"
#import "EmojiTransport.h"
#import "EmojiCollectionViewCell.h"
#import "Emoji.h"
#import "UIColor+FlatUI.h"
#import "UIImage+Tint.h"

@interface HBEmojiPageView () {
    NSArray *_collectionViewArray;
}

@end

@implementation HBEmojiPageView
@synthesize delegate;

#pragma mark

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self){
        [self initView];
    }
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}
-(void)initView
{
    UIImageView * backView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 216)];
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 216)];
    _scrollView.pagingEnabled=YES;
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.delegate=self;
    [self addSubview:_scrollView];
    
    UIImageView * toolBar=[[UIImageView alloc]initWithFrame:CGRectMake(0, 216-38, [UIScreen mainScreen].bounds.size.width, 38)];
    toolBar.backgroundColor = [UIColor whiteColor];
    toolBar.userInteractionEnabled = YES;
    [self addSubview:toolBar];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 38)];
    [_pageControl setPageIndicatorTintColor:[UIColor colorFromHexCode:@"bbbbbb"]];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor colorFromHexCode:@"8b8b8b"]];
    _pageControl.userInteractionEnabled = NO;

    [toolBar addSubview:_pageControl];
    [self drawIcons];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 216-38, [UIScreen mainScreen].bounds.size.width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
    
    UIButton * sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor clearColor];
    [sendButton setTitleColor:[UIColor senderColor] forState:UIControlStateNormal];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-70, 0, 70, 38);
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:sendButton];
    _sendButton=sendButton;
    
    UIButton * deleteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.backgroundColor = [UIColor clearColor];
    deleteButton.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-140, 0, 70, 38);
    [deleteButton setImage:[[UIImage imageNamed:@"msg-delete.png"] imageWithColor:[UIColor senderColor]] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteClick)
           forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:deleteButton];
    _deleteButton=deleteButton;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [_scrollView setFrame:self.bounds];
}

#pragma -mark
-(CGRect)getFrameForIndex:(int) index
{
    int page,row,list;
    page=index/20;
    row=(index%20)%7;
    list=(index%20)/7;
    return CGRectMake(page*[UIScreen mainScreen].bounds.size.width+row*44+5,list*48+10, 44, 44);
}

-(CGRect)getFrameForIndexPath:(NSIndexPath *) indexPath
{
    int row,list;
    NSInteger index = indexPath.section*7+indexPath.row;
    row=(index%20)%7;
    list=(index%20)/7;
    return CGRectMake(row*44+5,list*48+10, 44, 44);
}

-(void)drawIcons
{
    self.faces = [[NSArray alloc] initWithObjects:[EmojiEmoticons allEmoticons], [EmojiMapSymbols allMapSymbols], [EmojiPictographs allPictographs], [EmojiTransport allTransport], nil];
    NSInteger pageCount = [self.faces count];
    for(int i=0;i<pageCount;i++)
    {
        UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*i+5,0, [UIScreen mainScreen].bounds.size.width-10, 179) collectionViewLayout:layout];
        collectionView.tag = i;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView registerClass:[EmojiCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:collectionView];
    }

    _scrollView.contentSize=CGSizeMake([UIScreen mainScreen].bounds.size.width*pageCount, self.frame.size.height);
    _pageControl.currentPage=1;
    _pageControl.numberOfPages=pageCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger i = collectionView.tag;
    return [self.faces[i] count]/7;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmojiCollectionViewCell *cell = (EmojiCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger i = collectionView.tag;
    NSArray *array = self.faces[i];
    cell.emojiLabel.text = [array objectAtIndex:(indexPath.section*7+indexPath.row)];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float rate = [UIScreen mainScreen].bounds.size.width/320;
    return CGSizeMake(rate*34, rate*34);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    NSInteger i =collectionView.tag;
    NSArray *array = self.faces[i];
    NSInteger index = indexPath.section*7 + indexPath.row;
    NSString * text=[array objectAtIndex:index];
    if(delegate&&[delegate respondsToSelector:@selector(emojiPageView:iconClick:)])
        [delegate emojiPageView:self iconClick:text];
}

#pragma -mark  响应方法

-(void)deleteClick
{
    if(delegate&&[delegate respondsToSelector:@selector(emojiPageViewDeleteClick:actionBlock:)]){
        [delegate emojiPageViewDeleteClick:self actionBlock:^NSString *(NSString *string) {
            if(![string hasSuffix:@"]"]){
                if ([string length]>1) {
                    return [string substringToIndex:[string length]-2];
                }else{
                    return nil;
                }
            }
            NSRange range=[string rangeOfString:@"[" options:NSBackwardsSearch];
            if(range.location==NSNotFound)
                if ([string length]>1) {
                    return [string substringToIndex:[string length]-2];
                }else{
                    return nil;
                }
            else{
                NSString * sub=[string substringToIndex:[string length]-2];
                sub=[sub substringFromIndex:range.location];
                NSRange  ran=[sub rangeOfString:@"]"];
                if(ran.location!=NSNotFound)
                    return string;
                else {
                    string=[string substringToIndex:range.location];
                    return string;
                }
            }
        }];
    }
}

-(void)sendButtonClick
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(emojiPageViewSendClick:)]) {
        [self.delegate emojiPageViewSendClick:self];
    }
}

#pragma -mark  委托方法实现

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    int page=scrollView1.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    [_pageControl setCurrentPage:page];
}

#pragma -mark 接口方法

-(void)canSend
{
    self.sendButton.enabled=YES;
    [self.sendButton setImage:[UIImage imageNamed:@"EmotionsSendBtnGrey_ios_sel@2x.png"] forState:UIControlStateNormal];
}

-(void)cannotSend
{
    self.sendButton.enabled=NO;
    [self.sendButton setImage:[UIImage imageNamed:@"EmotionsSendBtnGrey_ios7@2x.png"] forState:UIControlStateNormal];
}

-(void)showInView:(UIView *)view withFrame:(CGRect)frame1
{
    self.transform=CGAffineTransformIdentity;
    [view addSubview:self];
    CGRect frame=frame1;
    CGRect beginFrame=CGRectMake(0,view.frame.size.height, [UIScreen mainScreen].bounds.size.width, 0);
    self.frame=beginFrame;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame=frame;
    }];
}

-(void) showInView:(UIView *)view
{
    [self showInView:view withFrame:self.frame];
}

-(void)hide
{
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
           self.transform=CGAffineTransformMakeTranslation(0, 216);
    } completion:^(BOOL finished) {
        if(finished)
            [self removeFromSuperview];
    }];
}

@end
