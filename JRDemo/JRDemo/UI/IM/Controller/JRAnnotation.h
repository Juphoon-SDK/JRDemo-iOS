#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JRAnnotation : NSObject <MKAnnotation>

/**
 *  实现MKAnnotation协议必须要定义这个属性
 */
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  子标题
 */
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) CLCircularRegion *region;

@property (nonatomic, readwrite) CLLocationDistance radius;

- (instancetype)initWithCLRegion:(CLCircularRegion *)newRegion title:(NSString *)title subtitle:(NSString *)subtitle;

@end
