//
//  Constants.h
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

//Default libraries
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>

//3rd Party libraries
#import "SOMotionDetector.h"
#import "SOStepDetector.h"
#import "SOLocationManager.h"
#import "ObjCMongoDB.h"
#import "TGCameraViewController.h"
#import "ClarifaiApp.h"
#import "MKDropdownMenu.h"
#include "WMGaugeView.h"

//My libraries
#import "UIColor+Norlife.h"

#import "FoodClassifierHandler.h"
#import "HealthKitDataManager.h"
#import "LocationDataManager.h"
#import "DailyScoreViewController.h"
#import "TrendsScoreViewController.h"
#import "DailyScoreView.h"
#import "DailyFeedbackCollectionViewCell.h"
#import "FoodViewController.h"


static NSString *MONGO_DB_CONNECTION_STRING = @"138.197.36.15:27017";
static NSString *TODAYS_FEEDBACK_URL = @"http://138.197.36.15/today-review";
static NSString *PREDICTIONS_URL = @"http://138.197.36.15/make-prediction";

static NSString *MONGO_DB_USERS_COLLECTION_NAME = @"norlife.users";
static NSString *MONGO_DB_DAILY_REVIEWS_COLLECTION_NAME = @"norlife.daily_reviews";
static NSString *MONGO_DB_MONTHLY_REVIEWS_COLLECTION_NAME = @"norlife.monthly_reviews";

static const NSString *NORDEA_BASE_URL = @"https://api.hackathon.developer.nordeaopenbanking.com/v1/";


@interface Constants : NSObject

+ (instancetype) instance;

+ (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (NSDate *) beginningOfDay:(NSDate *)date;

+ (NSDictionary*) userProperties;

+ (NSString*) NUTRITIONIX_APP_ID;
+ (NSString*) NUTRITIONIX_APP_KEY;
+ (NSString*) NUTRITIONIX_REMOTE_USER_ID;
+ (NSString*) CLARIFAI_API_KEY;
+ (NSString*) MICROSOFT_COMPUTER_VISION_API_KEY;
+ (NSString*) NORDEA_CLIENT_SECRET;
+ (NSString*) NORDEA_CLIENT_ID;
+ (NSString*) NORDEA_ACCESS_TOKEN;

+ (NSString*) mongoDBUserID;

+ (double) yesterdayScore;
+ (double) todayScore;
+ (double) hoursBetween:(NSDate*)firstDate and:(NSDate*)secondDate;

+ (CLLocationManager*) getLocationManager;

+ (NSMutableAttributedString*) string:(NSString*)string color:(UIColor*)color;

+ (void) addUserToDB;

@end
