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

#import "BSONCoding.h"
#import "BSONDecoder.h"
#import "BSONDocument.h"
#import "BSONEncoder.h"
#import "BSONIterator.h"
#import "BSONTypes.h"
#import "NSData+BSONAdditions.h"
#import "NSDictionary+BSONAdditions.h"
#import "NSManagedObject+BSONCoding.h"
#import "NSString+BSONAdditions.h"
#import "ObjCBSON.h"
#import "MongoConnection+Diagnostics.h"
#import "MongoConnection.h"
#import "MongoCursor.h"
#import "MongoDBCollection.h"
#import "MongoFindRequest.h"
#import "MongoKeyedPredicate.h"
#import "MongoPredicate.h"
#import "MongoTypes.h"
#import "MongoUpdateRequest.h"
#import "MongoWriteConcern.h"
#import "NSArray+MongoAdditions.h"
#import "ObjCMongoDB.h"
#import "OrderedDictionary.h"

FOUNDATION_EXPORT double ObjCMongoDBVersionNumber;
FOUNDATION_EXPORT const unsigned char ObjCMongoDBVersionString[];

