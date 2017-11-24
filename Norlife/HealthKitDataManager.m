//
//  HealthKitDataManager.m
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "HealthKitDataManager.h"

static HealthKitDataManager *dataManager;

@interface HealthKitDataManager ()

@property (strong, nonatomic) HKHealthStore *healthStore;

@end

@implementation HealthKitDataManager

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
        self.healthStore = [[HKHealthStore alloc] init];
    }
    
    return self;
}

+ (HKUnit*) heartBeatsPerMinuteUnit
{
    return [[HKUnit countUnit]unitDividedByUnit:[HKUnit minuteUnit]];
}

- (void) calculateHeartRate
{
    NSSet *shareObjectTypes = [[NSSet alloc] init];
    
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount], nil];
    
    // Request access
    [self.healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                        readTypes:readObjectTypes
                                       completion:^(BOOL success, NSError *error) {
                                           if(success) {
                                               NSLog(@"GRANTED");
                                               [self readHeartRateWithCompletion:^(NSArray *results, NSError *error) {
                                                   NSString *items = [results componentsJoinedByString:@"\n"];
                                                   NSLog(@"%@", items);
                                                   NSLog(@"WE IN");
                                               }];
                                           }
                                           else {
                                               NSLog(@"NOT ALLOWED TO ACCESS");
                                           }
                                       }
     ];
}

- (void)readHeartRateWithCompletion:(void (^)(NSArray *results, NSError *error))completion
{
    
    //get the heart rates
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:now];
    components.hour = 0;
    components.minute = 0;
    components.year = 2016;
    components.second = 0;
    
    NSDate *beginOfDay = [calendar dateFromComponents:components];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:beginOfDay endDate:now options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSSortDescriptor *lastDateDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate
                                                                       ascending:YES
                                                                        selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = @[lastDateDescriptor];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                           predicate:predicate
                                                               limit:HKObjectQueryNoLimit
                                                     sortDescriptors:sortDescriptors
                                                      resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error){
        if (!results) {
            NSLog(@"An error occured fetching the user's heartrate. The error was: %@.", error);
            abort();
        }
                                                          
                                                          NSLog(@"STILL HERE");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableArray *arrayHeartRate = [[NSMutableArray alloc]init];
            
            for (HKQuantitySample *sample in results) {
                NSLog(@"SOME RESULTS");
                double hbpm = [sample.quantity doubleValueForUnit:[HealthKitDataManager heartBeatsPerMinuteUnit]];
                [arrayHeartRate addObject:[NSNumber numberWithDouble:hbpm]];
            }
            
            if (completion) {
                NSLog(@"COMPLETED");
                completion(arrayHeartRate, error);
            }
        });
    }];
    [[[HKHealthStore alloc] init] executeQuery:query];
    NSLog(@"QUERY DONE");
    
}

@end
