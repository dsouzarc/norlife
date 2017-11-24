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

- (void) initializeSOLocationManager
{
    [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
    [[SOMotionDetector sharedInstance] startDetection];

    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {

        static double lastSpeed = -1.0;
        if([SOMotionDetector sharedInstance].motionType == MotionTypeAutomotive) {
            
            //First time - initialize to current speed
            if(lastSpeed == -1.0) {
                lastSpeed = location.speed;
            } else {
                double speedDifference = fabs(lastSpeed - location.speed);
                if(speedDifference/lastSpeed >= DANGEROUS_DRIVING_SPEED_THRESHOLD) {
                    //NSLog(@"DANGEROUS");
                }
                
                lastSpeed = location.speed;
            }
            //NSLog(@"Here: %@", location);
        }
    };
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [Constants getLocationManager];
    self.locationManager.delegate = self;
    [self initializeSOLocationManager];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self initializeSOLocationManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
