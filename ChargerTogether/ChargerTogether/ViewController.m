//
//  ViewController.m
//  ChargerTogether
//
//  Created by testing on 6/6/2015.
//  Copyright (c) 2015年 pcms.invonationTeam. All rights reserved.
//

#import "ViewController.h"
#import "AppManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:APPMANAGER_NOTIFICATION_GPSUPDATED object:nil];

	[[AppManager sharedManager] setupGPS];
	[[AppManager sharedManager] updateGPS];
	
	[_mapView setDelegate:self];

	int width = self.view.frame.size.height;
	int height = 300;
	int x = 0;
	int y = self.view.frame.size.width-100;
	_menuView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
	[_menuView setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:_menuView];

	_menuView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
	_menuView.layer.shadowOffset = CGSizeMake(0, -5);
	_menuView.layer.shadowRadius = 2.0f;
	_menuView.layer.shadowOpacity = 0.5f;

	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[recognizer setMaximumNumberOfTouches:1];
	[recognizer setDelegate:self];
	[_menuView addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
- (IBAction)btnClicked:(id)sender {
	[[AppManager sharedManager] printGPS];
	
	[_mapView setVisibleMapRect:MKMapRectMake(256, 192, 512, 384) animated:YES];
}

- (void)handleNotification:(NSNotification *)notification  {
	NSLog(@"%@", notification.name);

	if ([notification.name isEqualToString:APPMANAGER_NOTIFICATION_GPSUPDATED] == YES)  {

		NSDictionary *dictionary = notification.userInfo;
		NSArray *array = [dictionary objectForKey:@"array"];

		[_mapView removeAnnotations:_mapView.annotations];

		//  Update map
		for (NSDictionary *rowDictionary in array)  {

			CGFloat GPSx = [[rowDictionary objectForKey:@"GPSx"] floatValue];
			CGFloat GPSy = [[rowDictionary objectForKey:@"GPSy"] floatValue];
			NSString *username = [rowDictionary objectForKey:@"name"];
			NSString *no = [rowDictionary objectForKey:@"no"];

			CLLocationCoordinate2D coordinate;
			coordinate.latitude = GPSx;
			coordinate.longitude = GPSy;
			
			MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
			point.coordinate = coordinate;
			point.title = [NSString stringWithFormat:@"%@ %@", no, username];
			[_mapView addAnnotation:point];
		}

		CLLocationCoordinate2D coordinate = [[AppManager sharedManager] getMyCoordinate];
		MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
		point.coordinate = coordinate;
		point.title = @"Me";
		[_mapView addAnnotation:point];
		_myPin = point;
		
		return;
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation  {
	static NSString *identifier = @"MyAnnotation";
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (annotationView == nil) {

		MKPointAnnotation *resultPin = (MKPointAnnotation *)annotation;
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:resultPin reuseIdentifier:identifier];
		annotationView.pinColor = MKPinAnnotationColorRed;
		annotationView.canShowCallout = YES;
	}

	if (annotation == _myPin)  {annotationView.pinColor = MKPinAnnotationColorGreen;}
	else  {annotationView.pinColor = MKPinAnnotationColorRed;}

	return annotationView;
}

- (void)pan:(UIPanGestureRecognizer *)recognizer  {
	CGPoint location = [recognizer locationInView:self.view];
	if (recognizer.state != UIGestureRecognizerStateEnded)  {
		int y = location.y;
		if (y < self.view.frame.size.width-300)  {y = self.view.frame.size.width-300;}
		if (y> self.view.frame.size.width-100) {y = self.view.frame.size.width-100;}
		[_menuView setFrame:CGRectMake(0, y, _menuView.frame.size.width, _menuView.frame.size.height)];
	}
}

@end
