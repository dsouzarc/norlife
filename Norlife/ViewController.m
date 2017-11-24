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

@end

@implementation ViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [Constants getLocationManager];
    self.locationManager.delegate = self;
    
     [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
    [[SOMotionDetector sharedInstance] startDetection];
    [[SOStepDetector sharedInstance] startDetectionWithUpdateBlock:^(NSError *error) {
        //...
        NSLog(@"ERROR: %@", error);
    }];
    
    
    
    [SOMotionDetector sharedInstance].motionTypeChangedBlock = ^(SOMotionType motionType) {
        //...
        NSLog(@"Hey: %d", motionType);
    };
    
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        //...
        NSLog(@"Here: %@", location);
    };
    
    [SOMotionDetector sharedInstance].accelerationChangedBlock = ^(CMAcceleration acceleration) {
        //...
        NSLog(@"Acceleration: %@", acceleration);
    };
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
