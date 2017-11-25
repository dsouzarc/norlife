//
//  LocationDataManager.m
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "LocationDataManager.h"

static LocationDataManager *dataManager;

@interface LocationDataManager ()

@property (strong, nonatomic) MongoDBCollection *drivingCollection;
@property (strong, nonatomic) MongoDBCollection *sittingCollection;

@end

@implementation LocationDataManager

+ (instancetype) instance
{
    @synchronized(self) {
        if(!dataManager) {
            dataManager = [[self alloc] init];
        }
    }

    return dataManager;
}

- (instancetype) init
{
    self = [super init];
    if(self) {
        
        NSError *error = nil;
        MongoConnection *connection = [MongoConnection connectionForServer:MONGO_DB_CONNECTION_STRING error:&error];
        
        if(error) {
            NSLog(@"ERROR GETTING MONGO CONNECTION: %@", [error description]);
        }
        self.drivingCollection = [connection collectionWithName:DRIVING_COLLECTION_NAME];
        self.sittingCollection = [connection collectionWithName:SITTING_COLLECTION_NAME];
    }
    
    return self;
}

- (void) beginLocationTracking
{
    [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
    [[SOMotionDetector sharedInstance] startDetection];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    __block NSDate *locationDate = [dateFormatter dateFromString:@"24/11/2000"];
    __block NSDate *endDate = [dateFormatter dateFromString:@"24/11/2017"];
    __block int numEntriesPerDay = 5;
    __block int counter = 0;
    BOOL toContinue = YES;
    
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        
        if(counter == numEntriesPerDay) {
            counter = 0;
            NSCalendar *cal = [NSCalendar currentCalendar];
            locationDate = [cal dateByAddingUnit:NSCalendarUnitDay
                                               value:1
                                              toDate:locationDate
                                             options:0];
        }
        
        if([locationDate isEqualToDate:endDate]) {
            exit(1);
        }
        
        static double lastSpeed = -1.0;
        if([SOMotionDetector sharedInstance].motionType == MotionTypeAutomotive) {
            
            //First time - initialize to current speed
            if(lastSpeed == -1.0) {
                lastSpeed = location.speed;
            } else {
                
                double speedDifference = fabs(lastSpeed - location.speed);
                double speedPercentDifference = speedDifference / lastSpeed;
                
                NSString *classification = @"";
                double influence = 0.0;
                
                NSArray *speedThresholds = @[
                                             @[@(0.001), @"excellent", @(-0.001)],
                                             @[@(0.005), @"very good", @(-0.0005)],
                                             @[@(0.055), @"fairly good", @(-0.00015)],
                                             @[@(0.06), @"pretty good", @(-0.0001)],
                                             @[@(0.08), @"good", @(-0.00005)],
                                             @[@(0.1), @"mildest", @(0.001)],
                                             @[@(0.15), @"milder", @(0.00105)],
                                             @[@(0.2), @"mild", @(0.00155)],
                                             @[@(0.25), @"more moderate", @(0.0020)],
                                             @[@(0.30), @"moderate", @(0.0025)],
                                             @[@(0.45), @"severe", @(0.0050)],
                                             @[@(1.00), @"reckless", @(0.015)]];
                
                for(NSArray *threshold in speedThresholds) {
                    
                    //If we meet the threshold
                    if(speedPercentDifference < [threshold[0] doubleValue]) {
                        classification = threshold[1];
                        influence = [threshold[2] doubleValue];
                        break;
                    }
                }
                
                NSDictionary *relevantData = @{
                                               @"date": locationDate,
                                               @"last_speed": [NSNumber numberWithDouble:lastSpeed],
                                               @"current_speed": [NSNumber numberWithDouble:location.speed],
                                               @"speed_difference": [NSNumber numberWithDouble:speedDifference],
                                               @"user_id": [Constants mongoDBUserID],
                                               @"classification": classification,
                                               @"influence": [NSNumber numberWithDouble:influence],
                                               @"location": location
                                               };
                NSError *error = nil;
                [self.drivingCollection insertDictionary:relevantData writeConcern:nil error:&error];
                
                if(error) {
                    NSLog(@"ERROR WRITING TO MONGO IN DRIVING: %@", [error description]);
                }
                
                lastSpeed = location.speed;
            }
            counter += 1;
            //NSLog(@"Here: %@", location);
        }
    };
    
    [SOMotionDetector sharedInstance].motionTypeChangedBlock = ^(SOMotionType currentMotionType) {
        static SOMotionType lastMotionType = MotionTypeNotMoving;
        static NSDate *lastMotionTypeDate = nil;
        static int numHoursWithoutStanding = 0;
        static int numActiveHours = 0;
        static NSSet *movementMotionTypes = nil;
        static NSSet *noMovementMotionTypes = nil;
        
        if(!movementMotionTypes) {
            movementMotionTypes = [NSSet setWithObjects:@(MotionTypeRunning), @(MotionTypeWalking), nil];
        }
        if(!noMovementMotionTypes) {
            noMovementMotionTypes = [NSSet setWithObjects:@(MotionTypeAutomotive), @(MotionTypeNotMoving), nil];
        }
        
        
        //First time - initialize
        if(!lastMotionTypeDate) {
            lastMotionTypeDate = [NSDate date];
            lastMotionType = currentMotionType;
        }
        
        else {
            
            double hoursBetween = [Constants hoursBetween:[NSDate date] and:lastMotionTypeDate];
            
            //TODO: Double check logic here. If we changed from non-moving to moving within the past hour
            if([movementMotionTypes containsObject:@(currentMotionType)]
               && [noMovementMotionTypes containsObject:@(lastMotionType)]
               && hoursBetween > 1) {
                numHoursWithoutStanding += 1;
            }
            
            //If we're still moving for more than an hour
            else if([movementMotionTypes containsObject:@(currentMotionType)]
                    && [movementMotionTypes containsObject:@(lastMotionType)]
                    && hoursBetween >= 1) {
                numActiveHours += (int) hoursBetween;
            }
            
            //If we changed from moving to non-moving
            lastMotionType = currentMotionType;
            lastMotionTypeDate = [NSDate date];
        }
    };
}

@end
