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
 @brief Classifies the image and saves the results to the database
 */
- (void) classifyImage;

@end
