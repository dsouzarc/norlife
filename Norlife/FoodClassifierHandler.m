//
//  FoodClassifierHandler.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "FoodClassifierHandler.h"

static NSString *MICROSOFT_VISION_SERVICE_ANALYZE_URL = @"https://westeurope.api.cognitive.microsoft.com/vision/v1.0/analyze?visualFeatures=Tags,Categories,Description&language=en";

@interface FoodClassifierHandler ()

@property (strong, nonatomic) NSMutableURLRequest *classifyURLRequest;

@end

@implementation FoodClassifierHandler

- (instancetype) initWithImageURL:(NSString*)imageURL
{
    self = [super init];
    
    if(self) {
        NSError *error;
        self.classifyURLRequest = [[NSMutableURLRequest alloc] init];
        [self.classifyURLRequest setURL:[NSURL URLWithString:MICROSOFT_VISION_SERVICE_ANALYZE_URL]];
        [self.classifyURLRequest setHTTPMethod:@"POST"];
        [self.classifyURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.classifyURLRequest setValue:[Constants MICROSOFT_COMPUTER_VISION_API_KEY] forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
        
        NSDictionary *postValues = @{ @"url": imageURL };
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postValues options:0 error:&error];
        [self.classifyURLRequest setHTTPBody:postData];
    }
    
    return self;
}

- (instancetype) initWithImage:(UIImage*)image
{
    self = [super init];
    
    if(self) {
        self.classifyURLRequest = [[NSMutableURLRequest alloc] init];
        [self.classifyURLRequest setURL:[NSURL URLWithString:MICROSOFT_VISION_SERVICE_ANALYZE_URL]];
        [self.classifyURLRequest setHTTPMethod:@"POST"];
        [self.classifyURLRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
        [self.classifyURLRequest setValue:[Constants MICROSOFT_COMPUTER_VISION_API_KEY] forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
        
        NSData *postData = UIImageJPEGRepresentation(image, 1.0);
        [self.classifyURLRequest setHTTPBody:postData];
    }
    
    return self;
}

- (NSDictionary*) classifyImage
{
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:self.classifyURLRequest returningResponse:nil error:&error];
    NSMutableDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                              options: NSJSONReadingMutableContainers
                                                                                error: &error];
    return responseDictionary;
}

@end
