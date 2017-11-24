//
//  Constants.m
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "Constants.h"

static Constants *constants;


@implementation Constants

# pragma mark - CONSTRUCTORS

+ (instancetype) instance
{
    @synchronized(self) {
        if(!constants) {
            constants = [[self alloc] init];
        }
    }
    return constants;
}

- (instancetype) init
{
    self = [super init];
    
    if(self) {

    }
    return self;
}

+ (CLLocationManager*) getLocationManager
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    switch([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            [locationManager requestAlwaysAuthorization];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [locationManager requestAlwaysAuthorization];
            break;
        case kCLAuthorizationStatusRestricted:
            break;
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            break;
    }
    
    return locationManager;
}

+ (double) hoursBetween:(NSDate*)firstDate and:(NSDate*)secondDate
{
    NSTimeInterval timeBetweenDates = [secondDate timeIntervalSinceDate:firstDate];
    double secondsInAnHour = 3600.0;
    double hoursBetweenDates = timeBetweenDates / secondsInAnHour;
    return hoursBetweenDates;
}

@end
