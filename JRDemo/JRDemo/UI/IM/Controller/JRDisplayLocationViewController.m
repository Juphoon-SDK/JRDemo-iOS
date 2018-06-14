//
//  JRDisplayLocationViewController.h
//

#import "JRDisplayLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "JRAnnotation.h"

@interface JRDisplayLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
{
    BOOL _isFirstUserLocation;
    BOOL _isFinishGeocodeLocation;
    
    JRAnnotation *_myRegionAnnotation;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *pinImage;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation JRDisplayLocationViewController

- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
                     locationString:(NSString *)locationString
{
    CLCircularRegion *newRegion = [[CLCircularRegion alloc] initWithCenter:coordinate radius:10.0 identifier:[NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude]];
    JRAnnotation *myRegionAnnotation = [[JRAnnotation alloc] initWithCLRegion:newRegion
                                                                          title:@"消息的位置"
                                                                       subtitle:locationString];
    myRegionAnnotation.coordinate = newRegion.center;
    myRegionAnnotation.radius = newRegion.radius;
    
    [self.mapView addAnnotation:myRegionAnnotation];
    _myRegionAnnotation = myRegionAnnotation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LOCATION", nil);
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestWhenInUseAuthorization];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    _addressLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _addressLabel.textColor = [UIColor darkGrayColor];
    _addressLabel.font = [UIFont systemFontOfSize:14];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    if (self.address.length && self.latitude && self.longitude) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude,
                                                                       self.longitude);
        
        [self addAnnotationWithCoordinate:coordinate locationString:self.address];
        
        //放大到标注的位置
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
        [self.mapView setRegion:region animated:NO];
        _addressLabel.text = self.address;
        self.pinImage.hidden = YES;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SEND", nil) style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation)];
        _addressLabel.text = NSLocalizedString(@"LOADING_LOCATION", nil);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isShowMessageLocation) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate];
    }
}

- (void)sendLocation
{
    [self.navigationController popViewControllerAnimated:YES];
    if (_compledBlock) {
        _compledBlock(_latitude, _longitude, 10.0, _address);
    }
}

- (void)reverseGeocodeLocation
{
    float centerLatitude = _mapView.centerCoordinate.latitude;
    float centerLongitude = _mapView.centerCoordinate.longitude;
    
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:centerLatitude longitude:centerLongitude];
    
    [_mapView removeAnnotation:_myRegionAnnotation];
    
    [geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray* placemarks, NSError* error) {
         CLPlacemark *placemark = [placemarks lastObject];
         if (placemark) {
             NSMutableString *geoLocations = [NSMutableString string];
             if ([placemark locality].length) {
                 [geoLocations appendString:[placemark locality]];
             }
             if ([placemark subLocality].length) {
                 [geoLocations appendString:[placemark subLocality]];
             }
             if ([placemark thoroughfare].length) {
                 [geoLocations appendString:[placemark thoroughfare]];
             }
             if ([placemark subThoroughfare].length) {
                 [geoLocations appendString:[placemark subThoroughfare]];
             }
             _addressLabel.text = geoLocations;
      
             _latitude = centerLatitude;//coordinate.latitude;
             _longitude = centerLongitude;//coordinate.longitude;
             _radius = 10.0;
             _address = geoLocations;
         }
         
         _isFinishGeocodeLocation = YES;
         [self.navigationItem.rightBarButtonItem setEnabled:YES];
     }];
}
- (IBAction)backToMyPlace:(id)sender
{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* userLocation = [locations objectAtIndex:0];
    if (!_isShowMessageLocation && !_isFirstUserLocation && userLocation.coordinate.longitude > 0)
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500);
        [self.mapView setRegion:region animated:NO];
        _isFirstUserLocation = YES;
        [self reverseGeocodeLocation];
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!_isShowMessageLocation && !_isFirstUserLocation && userLocation.coordinate.longitude > 0) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500);
        [self.mapView setRegion:region animated:NO];
        _isFirstUserLocation = YES;
        [self reverseGeocodeLocation];
    }
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (!_isShowMessageLocation) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        _addressLabel.text = NSLocalizedString(@"LOADING_LOCATION", nil);
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!_isFinishGeocodeLocation) return;
    
    if (!_isShowMessageLocation) {
        [self reverseGeocodeLocation];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.pinImage.center = CGPointMake(self.pinImage.center.x, self.pinImage.center.y - 30);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.pinImage.center = CGPointMake(self.pinImage.center.x, self.pinImage.center.y + 30);
            }];
        }];
    }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[JRAnnotation class]])
    {
        static NSString* identifier = @"identifier";
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pinView.image = [UIImage imageNamed:@"msg-location-place"];
        }
        return pinView;
    }
    return nil;
}

- (void)dealloc
{
    self.mapView = nil;
}

@end
