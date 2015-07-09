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
#define MENU_MIN_WIDTH 50
#define ANIMATION_SPEED 0.25f

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

	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))  { [self setPortraitMenu]; }
	else  { [self setLandscapeMenu]; }
	
	_menuView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
	_menuView.layer.shadowOffset = CGSizeMake(-5, 0);
	_menuView.layer.shadowRadius = 2.0f;
	_menuView.layer.shadowOpacity = 0.5f;

	// Swipe Motion Recognizer
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[recognizer setMaximumNumberOfTouches:1];
	[recognizer setDelegate:self];
	[_menuView addGestureRecognizer:recognizer];
	
	menuLabel = [[UIButton alloc] initWithFrame:CGRectMake(-130, self.view.frame.size.height/2, 300, 30)];
	[menuLabel setTitle:@"Swipe left for preference" forState:UIControlStateNormal];
	menuLabel.backgroundColor = [UIColor whiteColor];
	[menuLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[menuLabel addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
	[menuLabel setTag:10];
	menuLabel.transform=CGAffineTransformMakeRotation((90*M_PI)/180);
	[_menuView addSubview:menuLabel];
	
	//-------------------Switches-----------------------------------------------
	int UIx = 50; int UIy = 160;
	
	UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(UIx+180, UIy-80, 100, 30)];
	[shareLabel setText:@"Share"];
	[_menuView addSubview:shareLabel];
	
	UILabel *borrowLabel = [[UILabel alloc] initWithFrame:CGRectMake(UIx+25, UIy-80, 100, 30)];
	[borrowLabel setText:@"Borrow"];
	[_menuView addSubview:borrowLabel];
	
	UISwitch *modeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(UIx+100, UIy-80, 100, 150)];
	[modeSwitch setTag:3];
	[modeSwitch addTarget:self action:@selector(toggleBatterySwitch:) forControlEvents:UIControlEventTouchUpInside];
	[_menuView addSubview:modeSwitch];
	[modeSwitch setOnTintColor:[UIColor lightGrayColor]];
	
	statusIndicator = [[UILabel alloc] initWithFrame:CGRectMake(UIx, UIy-30, 200, 30)];
	[statusIndicator setText:@"I want to borrow:"];
	[_menuView addSubview:statusIndicator];
	
	UISwitch *batterySwitch = [[UISwitch alloc]initWithFrame:CGRectMake(UIx,UIy, 100, 150)];
	[batterySwitch setTag:1];
	[batterySwitch addTarget:self action:@selector(toggleBatterySwitch:) forControlEvents:UIControlEventTouchUpInside];
	[_menuView addSubview:batterySwitch];
	[batterySwitch setOnTintColor:[UIColor brownColor]];

	UILabel *batteryText = [[UILabel alloc] initWithFrame:CGRectMake(UIx+60, UIy, 100, 30)];
	batteryText.text = @"Battery";
	[_menuView addSubview:batteryText];
	
	UISwitch *cableSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(UIx+150, UIy, 100, 150)];
	[cableSwitch setTag:2];
	[cableSwitch addTarget:self action:@selector(toggleBatterySwitch:) forControlEvents:UIControlEventTouchUpInside];
	[_menuView addSubview:cableSwitch];
	[cableSwitch setOnTintColor:[UIColor brownColor]];
	
	UILabel *cableText = [[UILabel alloc] initWithFrame:CGRectMake(UIx+210, UIy, 100, 30)];
	cableText.text = @"Cable";
	[_menuView addSubview:cableText];
	//-------------------Switches ended--------------------------------------------
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
- (IBAction)btnClicked:(UIButton*)sender {
	[[AppManager sharedManager] printGPS];
//	[_mapView setVisibleMapRect:MKMapRectMake(256, 192, 512, 384) animated:YES];
	switch (sender.tag) {
			case 10:
					{
						[self toggleMenuView];
					}
					break;
			
			default:{
						[self toggleMenuView];
					}
					break;
	}

	
}

- (void)toggleMenuView{
	if (_menuView.frame.origin.x != _menuViewLimitationMin) {
		[UIView animateWithDuration:ANIMATION_SPEED animations:^{
			CGRect rect = _menuView.frame;
			rect.origin.x =_menuViewLimitationMin;
			_menuView.frame = rect;
		}];
	}else{
		[UIView animateWithDuration:ANIMATION_SPEED animations:^{
			CGRect rect = _menuView.frame;
			rect.origin.x =_menuViewLimitationMax;
			_menuView.frame = rect;
		}];
	}
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
	NSLog(@"%@", [dictionary objectForKey:@"no"]);
	// TODO: not yet finish here...
}

- (void)pan:(UIPanGestureRecognizer *)recognizer  {
	CGPoint location = [recognizer velocityInView:self.view];
	CGPoint fingerLocation = [recognizer locationInView:self.view];
	if(recognizer.state == UIGestureRecognizerStateBegan){
		differences = _menuView.frame.origin.x-fingerLocation.x;
		NSLog(@"data %f %f %f",differences,_menuView.frame.origin.x,fingerLocation.x);
	}
	if(recognizer.state == UIGestureRecognizerStateChanged){
		[_menuView setFrame:CGRectMake(fingerLocation.x+differences, 0, _menuView.frame.size.width, _menuView.frame.size.height)];
	}
	if (recognizer.state == UIGestureRecognizerStateEnded)  {
		int x = location.x;
		if (x<0) {
				[UIView animateWithDuration:ANIMATION_SPEED animations:^{
				CGRect rect = _menuView.frame;
				rect.origin.x =_menuViewLimitationMin;
				_menuView.frame = rect;
			}];
		}else if(x>0){
				[UIView animateWithDuration:ANIMATION_SPEED animations:^{
				CGRect rect = _menuView.frame;
				rect.origin.x =_menuViewLimitationMax;
				_menuView.frame = rect;
			}];
		}
	}
}

- (void)toggleBatterySwitch:(UISwitch *)switchObject  {
	switch (switchObject.tag)  {
		default:  break;
			
		case 3:	{
			// Mode
			[[AppManager sharedManager] updateMode:switchObject.isOn];
			if(switchObject.isOn){
				[statusIndicator setText:@"I want to share:"];
			}else{
				[statusIndicator setText:@"I want to borrow:"];
			}
		} break;

		case 1:  {
			//  Battery
			[[AppManager sharedManager] updateBatteryFilter:switchObject.isOn];
		}  break;
			
		case 2:  {
			//  Cable
			[[AppManager sharedManager] updateCableFilter:switchObject.isOn];
		}  break;
	}
	[[AppManager sharedManager] updateGPS];
}

- (void)setLandscapeMenu  {
	int height = self.view.frame.size.height;
	int width = MENU_WIDTH*10;
	int y = 0;
	int x = self.view.frame.size.height-MENU_MIN_WIDTH;
	_menuViewLimitationMax = self.view.frame.size.height-MENU_MIN_WIDTH;
	_menuViewLimitationMin = self.view.frame.size.height-MENU_WIDTH;
	[_menuView setFrame:CGRectMake(x, y, width, height)];
//	[menuLabel setCenter:CGPointMake(-130, self.view.frame.size.height/2)];
}

- (void)setPortraitMenu  {
	int height = self.view.frame.size.height;
	int width = MENU_WIDTH*10;
	int y = 0;
	int x = self.view.frame.size.width-MENU_MIN_WIDTH;
	_menuViewLimitationMax = x;
	_menuViewLimitationMin = self.view.frame.size.width-MENU_WIDTH;
	[_menuView setFrame:CGRectMake(x, y, width, height)];
//	[menuLabel setCenter:CGPointMake(-130, self.view.frame.size.height/2)];
}

@end
