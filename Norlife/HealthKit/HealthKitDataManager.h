//
//  HealthKitDataManager.h
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

#import "Constants.h"

@interface HealthKitDataManager : NSObject

+ (instancetype) instance;

- (void) calculateHeartRate;


@end
