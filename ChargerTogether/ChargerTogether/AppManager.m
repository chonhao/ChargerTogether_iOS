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
	int filterValue = 0;
	if (_battery == YES)  {filterValue |= 1;}
	if (_cable == YES)  {filterValue |= 2;}
	NSString *filterString = [NSString stringWithFormat:@"%d", filterValue];
	NSLog(@"filterString: %@", filterString);

	NSString *urlString = @"http://home.puiching.edu.mo/ChargerTogether/NeedHelp2.php";
	NSDictionary *dictionary = @{
								 @"no": @"86",
								 @"GPSx": [NSString stringWithFormat:@"%.2f", _locationManager.location.coordinate.latitude],
								 @"GPSy": [NSString stringWithFormat:@"%.2f", _locationManager.location.coordinate.longitude],
								 @"filter": filterString,
								 @"providerItem": @"0",
								 @"distance":@"0.01",
								 };
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager POST:urlString parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		//  JSON arrived, parse it now
		if (![responseObject isKindOfClass:[NSDictionary class]])  {
			NSLog(@"### Invalid object...");
			return;
		}

		NSDictionary *responseDictionary = (NSDictionary *)responseObject;
		int status = [[responseDictionary objectForKey:@"status"] intValue];
		if (status != 0)  {
			NSLog(@"### Status: %d", status);
			return;
		}

		NSArray *array = [responseDictionary objectForKey:@"dataArray"];
		NSDictionary *dictionary = @{@"array": array};
		[[NSNotificationCenter defaultCenter] postNotificationName:APPMANAGER_NOTIFICATION_GPSUPDATED object:nil userInfo:dictionary];
		_array = array;
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

- (void)updateBatteryFilter:(BOOL)enabled  {
	_battery = enabled;
}

- (void)updateCableFilter:(BOOL)enabled  {
	_cable = enabled;
}

- (NSDictionary *)getDictFromIndex:(int)index  {
	NSDictionary *dictionary = _array[index];
	return dictionary;
}

@end
