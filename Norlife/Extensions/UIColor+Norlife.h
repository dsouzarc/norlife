//
//  UIColor+Norlife.h
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(Norlife)

/*!
 @brief Returns the default dark Nordea blue color
*/
+ (UIColor*) darkNordeaBlue;

/*!
 @brief Convenience method to return UIColor when given the RGB values out of 255 (0 to 255)
*/
+ (UIColor*) red:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

@end
