//
//  AppManager.m
//  ChargerTogether
//
//  Created by testing on 7/6/2015.
//  Copyright (c) 2015年 pcms.invonationTeam. All rights reserved.
//

#import "AppManager.h"
#import "AFNetworking.h"

@implementation AppManager

static AppManager *_sharedManager = nil;

+ (AppManager *)sharedManager  {
	if (_sharedManager != nil)  {return _sharedManager;}

	//  Nil
	_sharedManager = [[AppManager alloc] init];
	return _sharedManager;
}

-(void)setupGPS{
	_locationManager = [[CLLocationManager alloc]init];
	_locationManager.distanceFilter = kCLDistanceFilterNone;
	_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	[_locationManager startUpdatingLocation];

	_timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(updateGPS) userInfo:nil repeats:YES];
}

-(void)updateGPS{
	NSString *urlString = @"http://home.puiching.edu.mo/ChargerTogether/NeedHelp2.php";
	NSDictionary *dictionary = @{
								 @"no": @"86",
								 @"GPSx": [NSString stringWithFormat:@"%.2f", _locationManager.location.coordinate.latitude],
								 @"GPSy": [NSString stringWithFormat:@"%.2f", _locationManager.location.coordinate.longitude],
								 @"distance":@"0.01",
								 };
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager POST:urlString parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		//  JSON arrived, parse it now
		NSArray *array = (NSArray *)responseObject;
		NSDictionary *dictionary = @{@"array": array};
		[[NSNotificationCenter defaultCenter] postNotificationName:APPMANAGER_NOTIFICATION_GPSUPDATED object:nil userInfo:dictionary];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		//  Error
	}];
}

- (void)printGPS  {
	NSLog(@"%.2f %.2f", _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude);
}

-(CLLocationCoordinate2D)getMyCoordinate{
	CLLocationCoordinate2D coordinate = _locationManager.location.coordinate;
	return coordinate;
}

@end
