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
    
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        
        static double lastSpeed = -1.0;
        if([SOMotionDetector sharedInstance].motionType == MotionTypeAutomotive) {
            
            //First time - initialize to current speed
            if(lastSpeed == -1.0) {
                lastSpeed = location.speed;
            } else {
                double speedDifference = fabs(lastSpeed - location.speed);
                
                if(!self.drivingCollection) {

                }
                
                double speedPercentDifference = speedDifference / lastSpeed;
                
                NSString *classification = @"";
                double influence = 0.0;
                
                if(speedPercentDifference <= 0.02) {
                    classification = @"good";
                    influence = 0.001;
                } else if(speedPercentDifference <= 0.1) {
                    classification = @"mild";
                    influence = -0.001;
                } else if(speedPercentDifference <= 0.25) {
                    classification = @"moderate";
                    influence = -0.0020;
                } else if(speedPercentDifference <= 0.35) {
                    classification = @"severe";
                    influence = -0.0050;
                } else if(speedPercentDifference <= 0.45) {
                    classification = @"drastic";
                    influence = -0.008;
                } else {
                    classification = @"reckless";
                    influence = -0.015;
                }
                
                NSDictionary *relevantData = @{
                                               @"date": [NSDate date],
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
