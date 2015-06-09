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
}

+ (AppManager *)sharedManager;

-(void)setupGPS;
-(void)updateGPS;
- (void)printGPS;
-(CLLocationCoordinate2D)getMyCoordinate;

@end