
//
//  Constants.m
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "Constants.h"

static Constants *constants;

@interface Constants ()

@end


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

+ (NSMutableAttributedString*) string:(NSString*)string color:(UIColor*)color
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:string];
    [result addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [string length])];
    return result;
}

/*!
 @brief Returns an NSDictionary with the contents of "constants.json"
*/
+ (NSDictionary*) constantsJSON
{
    static NSDictionary *constantsJson;
    
    if(!constantsJson) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"constants" ofType:@"json"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        constantsJson = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:nil];
    }
    
    return constantsJson;
}

+ (NSString*) NUTRITIONIX_APP_ID
{
    return [[[Constants constantsJSON] objectForKey:@"nutritionix"] objectForKey:@"x-app-id"];
}

+ (NSString*) NUTRITIONIX_APP_KEY
{
    return [[[Constants constantsJSON] objectForKey:@"nutritionix"] objectForKey:@"x-app-key"];
}

+ (NSString*) NUTRITIONIX_REMOTE_USER_ID
{
    return [[[Constants constantsJSON] objectForKey:@"nutritionix"] objectForKey:@"x-remote-user-id"];
}

+ (NSString*) NORDEA_CLIENT_ID
{
    return [[[Constants constantsJSON] objectForKey:@"nordea"] objectForKey:@"client_id"];
}

+ (NSString*) NORDEA_ACCESS_TOKEN
{
    return [[[Constants constantsJSON] objectForKey:@"nordea"] objectForKey:@"access_token"];
}

+ (NSString*) NORDEA_CLIENT_SECRET
{
    return [[[Constants constantsJSON] objectForKey:@"nordea"] objectForKey:@"client_secret"];
}

+ (NSString*) MICROSOFT_COMPUTER_VISION_API_KEY
{
    return [[Constants constantsJSON] objectForKey:@"microsoft_computer_vision_api_key"];
}

+ (NSString*) CLARIFAI_API_KEY
{
    return [[Constants constantsJSON] objectForKey:@"clarifai_api_key"];
}

+ (NSDictionary*) userProperties
{
    NSMutableDictionary *userProperties = [[NSMutableDictionary alloc] init];
    [userProperties setObject:@"Steve" forKey:@"first_name"];
    [userProperties setObject:@"Bhatia" forKey:@"last_name"];
    [userProperties setObject:@"dsouzarc@gmail.com" forKey:@"email_address"];
    [userProperties setObject:@"29/11/1996" forKey:@"birthday"];
    [userProperties setObject:@"1996" forKey:@"birth_year"];
    [userProperties setObject:@"Hack_junction2017" forKey:@"password"];
    [userProperties setObject:@"6e9c0f4d-4ec4-478a-95c9-cdfd97198f8d" forKey:@"user_id"];
    [userProperties setObject:@(0) forKey:@"num_kids"];
    [userProperties setObject:@"student" forKey:@"profession_type"];
    [userProperties setObject:@(70) forKey:@"weight"];
    [userProperties setObject:@(181) forKey:@"height"];
    [userProperties setObject:@(NO) forKey:@"overweight"];
    
    [userProperties setObject:@(135) forKey:@"original_monthly_premium"];
    [userProperties setObject:@(135) forKey:@"current_monthly_premium"];
    [userProperties setObject:@(2090) forKey:@"life_insurance_end"];
    [userProperties setObject:@(2000) forKey:@"recommended_calories_per_day"];
    [userProperties setObject:@(60) forKey:@"recommended_grams_of_fat_per_day"];
    [userProperties setObject:@(20) forKey:@"recommended_saturated_fat_per_day"];
    [userProperties setObject:@(200) forKey:@"recommended_cholesterol_per_day"];
    [userProperties setObject:@(2000) forKey:@"recommended_sodium_per_day"];
    [userProperties setObject:@(24) forKey:@"recommended_sugar_per_day"];
    [userProperties setObject:@(50) forKey:@"recommended_protein_per_day"];
    
    return [NSDictionary dictionaryWithDictionary:userProperties];
}

+ (NSString*) mongoDBUserID
{
    return [[Constants userProperties] objectForKey:@"user_id"];
}

+ (void) addUserToDB
{
    NSDictionary *userProperties = [Constants userProperties];

    NSError *error;
    MongoConnection *connection = [MongoConnection connectionForServer:MONGO_DB_CONNECTION_STRING error:&error];
    MongoDBCollection *usersCollection = [connection collectionWithName:MONGO_DB_USERS_COLLECTION_NAME];
    
    MongoKeyedPredicate *deletePredicate = [MongoKeyedPredicate predicate];
    [deletePredicate keyPath:@"user_id" matches:[userProperties objectForKey:@"user_id"]];
    [usersCollection removeWithPredicate:deletePredicate writeConcern:nil error:&error];
    
    [usersCollection insertDictionary:userProperties writeConcern:nil error:&error];
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

+ (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
