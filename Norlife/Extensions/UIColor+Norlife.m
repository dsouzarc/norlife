//
//  UIColor+Norlife.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "UIColor+Norlife.h"

@implementation UIColor(Norlife)

+(UIColor*) darkNordeaBlue
{
    return [UIColor red:0 green:1 blue:151 alpha:1];
}

+ (UIColor*) red:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@end
