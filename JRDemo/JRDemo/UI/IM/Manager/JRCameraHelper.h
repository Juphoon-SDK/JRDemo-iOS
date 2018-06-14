//
//  JRCameraHelper.h
//  JRDemo
//
//  Created by Ginger on 2018/2/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>


/**
 相机类型

 - CameraTypePhoto: 只拍摄图片
 - CameraTypeVideo: 只拍摄视频
 - CameraTypeBoth: 都支持
 */
typedef NS_ENUM(NSInteger, CameraType) {
    CameraTypePhoto,
    CameraTypeVideo,
    CameraTypeBoth,
};

@protocol JRCameraHelperDelegate <NSObject>
@optional

/**
 输出图片

 @param image 图片
 */
- (void)cameraPrintImage:(UIImage *)image;

/**
 输出视频

 @param videoUrl 视频url
 */
- (void)cameraPrintVideo:(NSURL *)videoUrl;

@end

@interface JRCameraHelper : NSObject

/**
 代理
 */
@property (nonatomic, weak) id<JRCameraHelperDelegate> delegate;

+ (JRCameraHelper *)sharedInstance;

/**
 展现viewcontroller

 @param type 相机类型
 @param viewController 父视图控制器
 */
- (void)showCameraViewControllerCameraType:(CameraType)type onViewController:(UIViewController *)viewController;


@end
