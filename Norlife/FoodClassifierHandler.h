//
//  FoodClassifierHandler.h
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constants.h"

@interface FoodClassifierHandler : NSObject

- (instancetype) initWithImageURL:(NSString*)imageURL;
- (instancetype) initWithImage:(UIImage*)image;

/*!
 @brief Executes the URL Request and returns the JSON response. IS SYNCHRONOUS
 */
- (NSDictionary*) getImageClassification;

@end
