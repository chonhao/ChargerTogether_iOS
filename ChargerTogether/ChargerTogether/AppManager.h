//
//  AppManager.h
//  ChargerTogether
//
//  Created by testing on 7/6/2015.
//  Copyright (c) 2015年 pcms.invonationTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define APPMANAGER_NOTIFICATION_GPSUPDATED			@"gpsUpdated"

@interface AppManager : NSObject{
	CLLocationManager *_locationManager;
	NSTimer *_timer;
	
	BOOL _battery;
	BOOL _cable;
	NSArray *_array;
}

+ (AppManager *)sharedManager;

-(void)setupGPS;
-(void)updateGPS;
- (void)printGPS;
-(CLLocationCoordinate2D)getMyCoordinate;

- (void)updateBatteryFilter:(BOOL)enabled;
- (void)updateCableFilter:(BOOL)enabled;

- (NSDictionary *)getDictFromIndex:(int)index;

@end