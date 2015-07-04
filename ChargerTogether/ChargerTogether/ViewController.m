//
//  ViewController.m
//  ChargerTogether
//
//  Created by testing on 6/6/2015.
//  Copyright (c) 2015年 pcms.invonationTeam. All rights reserved.
//

#import "ViewController.h"
#import "AppManager.h"

#define MENU_WIDTH (1024/3)

@interface ViewController ()

@end

@implementation ViewController

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  {
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)  {
		[self setPortraitMenu];
		return;
	}
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[self setLandscapeMenu];
		return;
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:APPMANAGER_NOTIFICATION_GPSUPDATED object:nil];

	[[AppManager sharedManager] setupGPS];
	[[AppManager sharedManager] updateGPS];
	
	[_mapView setDelegate:self];

	int height = 0;
	int width = 0;
	int y = 0;
	int x = 0;
	_menuView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
	[_menuView setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:_menuView];

	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))  {
		[self setPortraitMenu];
	}
	else  {
		[self setLandscapeMenu];
	}
	
	_menuView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
	_menuView.layer.shadowOffset = CGSizeMake(-5, 0);
	_menuView.layer.shadowRadius = 2.0f;
	_menuView.layer.shadowOpacity = 0.5f;

	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[recognizer setMaximumNumberOfTouches:1];
	[recognizer setDelegate:self];
	[_menuView addGestureRecognizer:recognizer];
	
	UISwitch *batterySwitch = [[UISwitch alloc]initWithFrame:CGRectMake(10,20, 100, 100)];
	[batterySwitch setTag:1];
	[batterySwitch addTarget:self action:@selector(toggleBatterySwitch:) forControlEvents:UIControlEventTouchUpInside];
	[_menuView addSubview:batterySwitch];

	UILabel *batteryText = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 30)];
	batteryText.text = @"Battery";
	[_menuView addSubview:batteryText];
	
	UISwitch *cableSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(10+150,20, 100, 100)];
	[cableSwitch setTag:2];
	[cableSwitch addTarget:self action:@selector(toggleBatterySwitch:) forControlEvents:UIControlEventTouchUpInside];
	[_menuView addSubview:cableSwitch];
	
	UILabel *cableText = [[UILabel alloc] initWithFrame:CGRectMake(70+150, 20, 100, 30)];
	cableText.text = @"Cable";
	[_menuView addSubview:cableText];

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
		int index = 0;
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
			point.title = [NSString stringWithFormat:@"%d %@", index, username];
			[_mapView addAnnotation:point];

			index++;
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view  {
	MKPointAnnotation *resultPin = (MKPointAnnotation *)view.annotation;
	NSLog(@"%@", resultPin.title);
	NSArray *array = [resultPin.title componentsSeparatedByString:@" "];
	int index = [[array objectAtIndex:0] intValue];
	NSDictionary *dictionary = [[AppManager sharedManager] getDictFromIndex:index];
	NSLog(@"%@", [dictionary objectForKey:@"name"]);
	// TODO: not yet finish here...
}

- (void)pan:(UIPanGestureRecognizer *)recognizer  {
	CGPoint location = [recognizer locationInView:self.view];
	if (recognizer.state != UIGestureRecognizerStateEnded)  {
		int x = location.x;
		if (x < _menuViewLimitationMin)  {x = _menuViewLimitationMin;}
		if (x > _menuViewLimitationMax) {x = _menuViewLimitationMax;}
		[_menuView setFrame:CGRectMake(x, 0, _menuView.frame.size.width, _menuView.frame.size.height)];
	}
}

- (void)toggleBatterySwitch:(UISwitch *)switchObject  {
	switch (switchObject.tag)  {
		default:  break;

		case 1:  {
			//  Battery
			[[AppManager sharedManager] updateBatteryFilter:switchObject.isOn];
		}  break;
			
		case 2:  {
			//  Cable
			[[AppManager sharedManager] updateCableFilter:switchObject.isOn];
		}  break;
	}
}

- (void)setLandscapeMenu  {
	int height = self.view.frame.size.height;
	int width = MENU_WIDTH;
	int y = 0;
	int x = self.view.frame.size.height-100;
	_menuViewLimitationMax = self.view.frame.size.height-100;
	_menuViewLimitationMin = self.view.frame.size.height-MENU_WIDTH;
	[_menuView setFrame:CGRectMake(x, y, width, height)];
}

- (void)setPortraitMenu  {
	int height = self.view.frame.size.height;
	int width = MENU_WIDTH;
	int y = 0;
	int x = self.view.frame.size.width-100;
	_menuViewLimitationMax = x;
	_menuViewLimitationMin = self.view.frame.size.width-MENU_WIDTH;
	[_menuView setFrame:CGRectMake(x, y, width, height)];
}

@end
