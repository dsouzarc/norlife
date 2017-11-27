//
//  ViewController.m
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CBZSplashView *splashView;

@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    CBZSplashView *splashView = [CBZSplashView splashViewWithIcon:[UIImage imageNamed:@"main_icon.png"]
                                                  backgroundColor:[UIColor lightNordeaBlue]];
    splashView.animationDuration = 1.4;
    [self.view addSubview:splashView];
    self.splashView = splashView;

    self.locationManager = [Constants getLocationManager];
    self.locationManager.delegate = self;
    
    [Constants addUserToDB];
}

- (void) viewDidAppear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.splashView startAnimation];
    });
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [[LocationDataManager instance] beginLocationTracking];
    }
    
    [[HealthKitDataManager instance] calculateHeartRate];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
