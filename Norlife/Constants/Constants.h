//
//  Constants.h
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>

#import "SOMotionDetector.h"
#import "SOStepDetector.h"
#import "SOLocationManager.h"
#import "ObjCMongoDB.h"

#import "UIColor+Norlife.h"

#import "HealthKitDataManager.h"
#import "LocationDataManager.h"

#import "DailyScoreViewController.h"
#import "TrendsScoreViewController.h"

static const NSString *MONGO_DB_CONNECTION_STRING = @"138.197.36.15:27017";
static const NSString *MONGO_DB_USERS_COLLECTION_NAME = @"norlife.users";

static const NSString *NORDEA_BASE_URL = @"https://api.hackathon.developer.nordeaopenbanking.com/v1/";

@interface Constants : NSObject

+ (instancetype) instance;

+ (NSString*) NORDEA_CLIENT_SECRET;
+ (NSString*) NORDEA_CLIENT_ID;
+ (NSString*) NORDEA_ACCESS_TOKEN;

+ (NSString*) mongoDBUserID;
+ (NSDictionary*) userProperties;

+ (CLLocationManager*) getLocationManager;
+ (double) hoursBetween:(NSDate*)firstDate and:(NSDate*)secondDate;

+ (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (void) addUserToDB;

@end
