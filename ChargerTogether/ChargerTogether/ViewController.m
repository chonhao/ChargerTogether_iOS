//
//  ViewController.m
//  ChargerTogether
//
//  Created by testing on 6/6/2015.
//  Copyright (c) 2015年 pcms.invonationTeam. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	locationManager = [[CLLocationManager alloc]init];
	locationManager.distanceFilter = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	[locationManager startUpdatingLocation];
	
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
- (IBAction)btnClicked:(id)sender {
	NSLog(@"%.2f %.2f",locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
}

@end
