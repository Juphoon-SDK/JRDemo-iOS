//
//  JRCameraHelper.m
//  JRDemo
//
//  Created by Ginger on 2018/2/24.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRCameraHelper.h"

@interface JRCameraHelper () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSDictionary *editInfo;

@end

@implementation JRCameraHelper

+ (JRCameraHelper *)sharedInstance {
    static JRCameraHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JRCameraHelper alloc] init];
    });
    return instance;
}

- (void)showCameraViewControllerCameraType:(CameraType)type onViewController:(UIViewController *)viewController {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    if (!self.imagePickerController) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.editing = YES;
        self.imagePickerController.delegate = self;
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        switch (type) {
            case CameraTypePhoto:
                self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                break;
            case CameraTypeVideo:
                self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
                self.imagePickerController.videoMaximumDuration = 60;
                break;
            case CameraTypeBoth:
                self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
                self.imagePickerController.videoMaximumDuration = 60;
                break;
            default:
                break;
        }
    }
    [viewController presentViewController:_imagePickerController animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    [self callDelegate:editingInfo];
    [self dismissPickerViewController:self.imagePickerController];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self callDelegate:info];
    [self dismissPickerViewController:self.imagePickerController];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerViewController:picker];
}

- (void)dismissPickerViewController:(UIImagePickerController *)picker
{
    self.editInfo = nil;
    self.imagePickerController = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)callDelegate:(NSDictionary *)info {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            NSURL *fileUrl = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
            UISaveVideoAtPathToSavedPhotosAlbum([fileUrl path], nil, nil, nil);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(cameraPrintVideo:)]) {
                    [self.delegate cameraPrintVideo:fileUrl];
                }
            });
        } else {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(cameraPrintImage:)]) {
                    [self.delegate cameraPrintImage:image];
                }
            });
        }
    });
}

@end
