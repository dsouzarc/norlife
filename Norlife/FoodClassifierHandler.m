//
//  FoodClassifierHandler.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "FoodClassifierHandler.h"

static NSString *MICROSOFT_VISION_SERVICE_ANALYZE_URL = @"https://westeurope.api.cognitive.microsoft.com/vision/v1.0/analyze?visualFeatures=Tags,Categories,Description&language=en";

static ClarifaiApp *clarifaiApp;

@interface FoodClassifierHandler ()

@property (strong, nonatomic) ClarifaiImage *clarifaiFoodImage;

@end

@implementation FoodClassifierHandler

- (instancetype) initWithImageURL:(NSString*)imageURL
{
    self = [super init];
    
    if(self) {
        self.clarifaiFoodImage = [[ClarifaiImage alloc] initWithURL:imageURL];
    }
    
    return self;
}

- (instancetype) initWithImage:(UIImage*)image
{
    self = [super init];
    
    if(self) {
        self.clarifaiFoodImage = [[ClarifaiImage alloc] initWithImage:image];
    }
    return self;
}

- (NSDictionary*) classifyImage
{
    if(!clarifaiApp) {
        clarifaiApp = [[ClarifaiApp alloc] initWithApiKey:[Constants CLARIFAI_API_KEY]];
    }
    
    [clarifaiApp getModelByName:@"general-v1.3" completion:^(ClarifaiModel *model, NSError *error) {

        [model predictOnImages:@[self.clarifaiFoodImage]
                    completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                        if (!error) {
                            
                            ClarifaiOutput *output = outputs[0];
                            NSMutableArray *allTags = [[NSMutableArray alloc] init];
                            
                            for (ClarifaiConcept *concept in output.concepts) {
                                [allTags addObject:concept.conceptName];
                            }
                            
                            NSLog(@"%@", [NSString stringWithFormat:@"Tags:\n%@", [allTags componentsJoinedByString:@", "]]);
                        }
                        else {
                            NSLog(@"ERROR USING CLARIFAI API: %@", [error description]);
                        }
                    }
         ];
    }];
    
    //Array of dictionaries. Key: food. Value: weight 
    NSMutableArray *relevantEntries = [[NSMutableArray alloc] init];
    
    return nil; //responseDictionary;
}

@end


/**
OLD MICROSOFT CODE
 
 /*[self.classifyURLRequest setURL:[NSURL URLWithString:MICROSOFT_VISION_SERVICE_ANALYZE_URL]];
 [self.classifyURLRequest setHTTPMethod:@"POST"];
 [self.classifyURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 [self.classifyURLRequest setValue:[Constants MICROSOFT_COMPUTER_VISION_API_KEY] forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
 
 NSDictionary *postValues = @{ @"url": imageURL };
 NSData *postData = [NSJSONSerialization dataWithJSONObject:postValues options:0 error:&error];
 [self.classifyURLRequest setHTTPBody:postData];*/

/*NSError *error;
 NSData *responseData = [NSURLConnection sendSynchronousRequest:self.classifyURLRequest returningResponse:nil error:&error];
 NSMutableDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
 options: NSJSONReadingMutableContainers
 error: &error];*/

/*[self.classifyURLRequest setURL:[NSURL URLWithString:MICROSOFT_VISION_SERVICE_ANALYZE_URL]];
 [self.classifyURLRequest setHTTPMethod:@"POST"];
 [self.classifyURLRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
 [self.classifyURLRequest setValue:[Constants MICROSOFT_COMPUTER_VISION_API_KEY] forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
 
 NSData *postData = UIImageJPEGRepresentation(image, 1.0);
 [self.classifyURLRequest setHTTPBody:postData]; */
