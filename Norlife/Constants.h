//
//  Constants.h
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "SOMotionDetector.h"
#import "SOStepDetector.h"
#import "SOLocationManager.h"

static const double DANGEROUS_DRIVING_SPEED_THRESHOLD = 0.01;

@interface Constants : NSObject

+ (instancetype) instance;

+ (CLLocationManager*) getLocationManager;


@end
