#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "bcon.h"
#import "bson.h"
#import "encoding.h"
#import "env.h"
#import "gridfs.h"
#import "md5.h"
#import "mongo.h"

FOUNDATION_EXPORT double mongo_c_driverVersionNumber;
FOUNDATION_EXPORT const unsigned char mongo_c_driverVersionString[];

