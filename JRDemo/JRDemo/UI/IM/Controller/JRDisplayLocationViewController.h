//
//  JRDisplayLocationViewController.h
//

#import <UIKit/UIKit.h>

typedef void(^DidFinishLocationCompledBlock)(double latitude, double longitude, float radius, NSString *geoLocation);

@interface JRDisplayLocationViewController : UIViewController

/**
 位置选择完毕
 */
@property (nonatomic, copy) DidFinishLocationCompledBlock compledBlock;

/**
 是否显示消息的位置
 */
@property (nonatomic, assign) BOOL isShowMessageLocation;

/**
 纬度
 */
@property (nonatomic, assign) double latitude;

/**
 经度
 */
@property (nonatomic, assign) double longitude;

/**
 半径
 */
@property (nonatomic, assign) float radius;

/**
 描述
 */
@property (nonatomic, copy) NSString *address;
    
@end
