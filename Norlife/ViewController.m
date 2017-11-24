//
//  ViewController.m
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
    [[SOMotionDetector sharedInstance] startDetection];
    [[SOStepDetector sharedInstance] startDetectionWithUpdateBlock:^(NSError *error) {
        //...
        
    }];
    
    [SOMotionDetector sharedInstance].accelerationChangedBlock = ^(CMAcceleration acceleration) {

        NSLog(@"ACCELERATION: %@", acceleration);
    };
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


@end
