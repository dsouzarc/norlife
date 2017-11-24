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
#import "ObjCMongoDB.h"

#import "HealthKitDataManager.h"
#import "LocationDataManager.h"

static const double DANGEROUS_DRIVING_SPEED_THRESHOLD = 0.01;
static const NSString *MONGO_DB_CONNECTION_STRING = @"207.154.232.139:27017";

@interface Constants : NSObject

+ (instancetype) instance;

+ (CLLocationManager*) getLocationManager;
+ (double) hoursBetween:(NSDate*)firstDate and:(NSDate*)secondDate;

@end
