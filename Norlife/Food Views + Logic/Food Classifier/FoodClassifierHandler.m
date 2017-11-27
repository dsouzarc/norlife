//
//  FoodClassifierHandler.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "FoodClassifierHandler.h"

static NSString *NUTRIONIX_NUTRIENTS_URL = @"https://trackapi.nutritionix.com/v2/natural/nutrients";

static ClarifaiApp *clarifaiApp;
static MongoDBCollection *foodCollection;


@interface FoodClassifierHandler ()

@property (strong, nonatomic) NSDate *foodDate;
@property (strong, nonatomic) ClarifaiImage *clarifaiFoodImage;

@end


@implementation FoodClassifierHandler


/****************************************************************
 *
 *              Constructor
 *
 *****************************************************************/

# pragma mark - Constructor

- (instancetype) initWithImageURL:(NSString*)imageURL forDate:(NSDate *)date
{
    self = [self initWithDate:date];
    
    if(self) {
        self.foodDate = date;
        self.clarifaiFoodImage = [[ClarifaiImage alloc] initWithURL:imageURL];
    }
    
    return self;
}

- (instancetype) initWithImage:(UIImage*)image forDate:(NSDate *)date
{
    self = [self initWithDate:date];
    
    if(self) {
        self.clarifaiFoodImage = [[ClarifaiImage alloc] initWithImage:image];
    }
    return self;
}

- (instancetype) initWithDate:(NSDate*)date
{
    self = [super init];
    if(self) {
        self.foodDate = date;
        
        NSError *error = nil;
        
        if(!foodCollection) {
            MongoConnection *connection = [MongoConnection connectionForServer:MONGO_DB_CONNECTION_STRING error:&error];
            if(error) {
                NSLog(@"ERROR GETTING MONGO CONNECTION: %@", [error description]);
            }
        
            foodCollection = [connection collectionWithName:FOOD_COLLECTION_NAME];
        }
    }
    
    return self;
}


/****************************************************************
 *
 *              Computation-Specific
 *
 *****************************************************************/

# pragma mark - Computation-Specific

- (NSMutableArray*) computeFoodScores:(NSMutableArray*)foodItems
{
    NSError *error;
    NSString *queryString = [foodItems componentsJoinedByString:@", "];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:NUTRIONIX_NUTRIENTS_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[Constants NUTRITIONIX_APP_KEY] forHTTPHeaderField:@"x-app-key"];
    [request setValue:[Constants NUTRITIONIX_APP_ID] forHTTPHeaderField:@"x-app-id"];
    [request setValue:@"0" forHTTPHeaderField:@"x-remote-user-id"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *requestBody = @{ @"query": queryString};
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&error];
    [request setHTTPBody:requestBodyData];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSMutableDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                              options: NSJSONReadingMutableContainers
                                                                                error: &error];
    
    NSArray *relevantFoodKeys = @[@"food_name", @"serving_unit", @"serving_weight_grams", @"nf_calories",
                                  @"nf_total_fat", @"nf_saturated_fat", @"nf_cholesterol", @"nf_sodium",
                                  @"nf_total_carbohydrate", @"nf_dietary_fiber", @"nf_sugars", @"nf_protein",
                                  @"nf_potassium", @"nf_p"];
    
    //Array of dictionaries where each item contains relevant food information.
    NSMutableArray *relevantFoodItems = [[NSMutableArray alloc] init];
    
    NSDictionary *user = [Constants userProperties];
    
    if([responseDictionary objectForKey:@"foods"]) {
        for(NSDictionary *foodDictionary in [responseDictionary objectForKey:@"foods"]) {
            NSMutableDictionary *relevantFoodValues = [[NSMutableDictionary alloc] init];

            for(NSString *relevantFoodKey in relevantFoodKeys) {
                if(![foodDictionary objectForKey:relevantFoodKey] || [[foodDictionary objectForKey:relevantFoodKey] isKindOfClass:[NSNull class]]) {
                    [relevantFoodValues setObject:@(0.0) forKey:relevantFoodKey];
                } else {
                    [relevantFoodValues setObject:[foodDictionary objectForKey:relevantFoodKey] forKey:relevantFoodKey];
                }
            }
            
            double raw_food_score = 0.0;
            double influence = 0.0;

            raw_food_score += [[relevantFoodValues objectForKey:@"nf_calories"] doubleValue] / [user[@"recommended_calories_per_day"] doubleValue];
            raw_food_score += [[relevantFoodValues objectForKey:@"nf_total_fat"] doubleValue] / [user[@"recommended_grams_of_fat_per_day"] doubleValue];
            raw_food_score += [[relevantFoodValues objectForKey:@"nf_saturated_fat"] doubleValue] / [user[@"recommended_saturated_fat_per_day"] doubleValue];
            raw_food_score += [[relevantFoodValues objectForKey:@"nf_sodium"] doubleValue] / [user[@"recommended_sodium_per_day"] doubleValue];
            raw_food_score += [[relevantFoodValues objectForKey:@"nf_cholesterol"] doubleValue] / [user[@"recommended_cholesterol_per_day"] doubleValue];
            raw_food_score += [[relevantFoodValues objectForKey:@"nf_sugars"] doubleValue] / [user[@"recommended_sugar_per_day"] doubleValue];
            
            NSLog(@"%@\t%.2f", [relevantFoodValues objectForKey:@"food_name"], raw_food_score);
            
            if(raw_food_score < 0.20) {
                influence = -0.005;
            } else if(raw_food_score < 0.4) {
                influence = -0.01;
            } else if(raw_food_score < 0.6) {
                influence = 0.005;
            } else if(raw_food_score < 0.8) {
                influence = 0.00105;
            } else if(raw_food_score < 1.0) {
                influence = 0.002;
            }
            
            [relevantFoodValues setObject:@(raw_food_score) forKey:@"raw_food_score"];
            [relevantFoodValues setObject:@(influence) forKey:@"influence"];
            [relevantFoodItems addObject:relevantFoodValues];
        }
    }
 
    return relevantFoodItems;
}

- (void) classifyImage
{
    if(!clarifaiApp) {
        clarifaiApp = [[ClarifaiApp alloc] initWithApiKey:[Constants CLARIFAI_API_KEY]];
    }
    
    [clarifaiApp getModelByName:@"general-v1.3" completion:^(ClarifaiModel *model, NSError *error) {

        [model predictOnImages:@[self.clarifaiFoodImage]
                    completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
                        if (!error) {
                            
                            ClarifaiOutput *output = outputs[0];
                            NSMutableArray *relevantTags = [[NSMutableArray alloc] init];
                            
                            for (ClarifaiConcept *concept in output.concepts) {
                                if(concept.score >= 0.4) {
                                    [relevantTags addObject:concept.conceptName];
                                }
                            }
                            
                            NSLog(@"%@", [NSString stringWithFormat:@"Tags:\n%@", [relevantTags componentsJoinedByString:@", "]]);
                            
                            NSMutableArray *relevantFoodScores = [self computeFoodScores:relevantTags];
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
                                
                                NSError *error;
                                
                                MongoConnection *connection = [MongoConnection connectionForServer:MONGO_DB_CONNECTION_STRING error:&error];
                                if(error) {
                                    NSLog(@"ERROR GETTING MONGO CONNECTION: %@", [error description]);
                                }
                                
                                MongoDBCollection *foodCollection = [connection collectionWithName:FOOD_COLLECTION_NAME];
                                
                                for(NSMutableDictionary *relevantFoodScore in relevantFoodScores) {
                                    [relevantFoodScore setObject:[Constants mongoDBUserID] forKey:@"user_id"];
                                    [relevantFoodScore setObject:self.foodDate forKey:@"date_consumed"];
                                    
                                    NSLog(@"INSERTING: %@", relevantFoodScore);
                                    [foodCollection insertDictionary:relevantFoodScore writeConcern:nil error:&error];
                                    if(error) {
                                        NSLog(@"ERROR WRITING TO MONGO IN DRIVING: %@", [error description]);
                                    }
                                }
                            });
                            
                            [self.delegate finishedWithFoodScores:relevantFoodScores];
                        }
                        else {
                            NSLog(@"ERROR USING CLARIFAI API: %@", [error description]);
                        }
                    }
         ];
    }];
    
    //Also used in testing
    NSMutableArray *relevantTags = [NSMutableArray arrayWithArray:[@"breakfast, no person, food, delicious, dawn, plate, lunch, homemade, nutrition, bread, egg, meal, pancake, cooking, butter, dinner, dish, toast, traditional, baking" componentsSeparatedByString:@", "]];
    
    NSMutableArray *foodScores = [self computeFoodScores:relevantTags];
    
    [self.delegate finishedWithFoodScores:foodScores];
}

@end

/**
OLD MICROSOFT CODE
 static NSString *MICROSOFT_VISION_SERVICE_ANALYZE_URL = @"https://westeurope.api.cognitive.microsoft.com/vision/v1.0/analyze?visualFeatures=Tags,Categories,Description&language=en";
 
 [self.classifyURLRequest setURL:[NSURL URLWithString:MICROSOFT_VISION_SERVICE_ANALYZE_URL]];
 [self.classifyURLRequest setHTTPMethod:@"POST"];
 [self.classifyURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 [self.classifyURLRequest setValue:[Constants MICROSOFT_COMPUTER_VISION_API_KEY] forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
 
 NSDictionary *postValues = @{ @"url": imageURL };
 NSData *postData = [NSJSONSerialization dataWithJSONObject:postValues options:0 error:&error];
 [self.classifyURLRequest setHTTPBody:postData];

 NSError *error;
 NSData *responseData = [NSURLConnection sendSynchronousRequest:self.classifyURLRequest returningResponse:nil error:&error];
 NSMutableDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
 options: NSJSONReadingMutableContainers
 error: &error];

 [self.classifyURLRequest setURL:[NSURL URLWithString:MICROSOFT_VISION_SERVICE_ANALYZE_URL]];
 [self.classifyURLRequest setHTTPMethod:@"POST"];
 [self.classifyURLRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
 [self.classifyURLRequest setValue:[Constants MICROSOFT_COMPUTER_VISION_API_KEY] forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
 
 NSData *postData = UIImageJPEGRepresentation(image, 1.0);
 [self.classifyURLRequest setHTTPBody:postData]; */
