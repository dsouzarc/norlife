//
//  FoodViewController.m
//  Norlife
//
//  Created by Ryan D'souza on 11/26/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "FoodViewController.h"

@interface FoodViewController ()

@property (weak, nonatomic) IBOutlet UIView *mainViewForGraph;

@property (strong, nonatomic) ScrollableGraphView *graphView;

@property (strong, nonatomic) BarPlot *mealBarPlot;

@property (strong, nonatomic) NSMutableArray *foodScores;

@property (strong, nonatomic) NSMutableDictionary *totalPerCategory;
@property (strong, nonatomic) NSMutableDictionary *allItems;

@end

@implementation FoodViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil
                      foodScores:(NSMutableArray *)foodScores
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.foodScores = foodScores;
        
        //Key: category like 'calories'. Value: 500 (total sum of all foods' calories)
        self.totalPerCategory = [[NSMutableDictionary alloc] init];
        
        //Key: category like 'calories'. Value: NSMutableArray of NSDictionary where each key is foodName and value is nutrition info for this category.
        self.allItems = [[NSMutableDictionary alloc] init];
        
        NSSet *relevantKeys = [NSSet setWithObjects:@"nf_calories", @"nf_saturated_fat", @"nf_protein",
                                                        @"nf_sodium",
                                                        @"nf_total_fat", @"nf_cholesterol", @"nf_sugars", nil];
        
        for(NSDictionary *foodScore in foodScores) {
            
            for(NSString *key in [foodScore allKeys]) {
                
                if([relevantKeys containsObject:key]) {
                    
                    //Total amount for this type (i.e.: calories)
                    if(![self.totalPerCategory objectForKey:key]) {
                        [self.totalPerCategory setObject:[foodScore objectForKey:key] forKey:key];
                    } else {
                        double newTotal = [[self.totalPerCategory objectForKey:key] doubleValue];
                        newTotal += [[foodScore objectForKey:key] doubleValue];
                        [self.totalPerCategory setObject:@(newTotal) forKey:key];
                    }
                    
                    //'nf_sugars': ['apple': 30, 'potato': 50]
                    NSDictionary *tempValue = @{[foodScore objectForKey:@"food_name"]: [foodScore objectForKey:key]};
                    if(![self.allItems objectForKey:key]) {
                        NSMutableArray *foodNameValue = [[NSMutableArray alloc] init];
                        [foodNameValue addObject:tempValue];
                        [self.allItems setObject:foodNameValue forKey:key];
                    } else {
                        NSMutableArray *foodNameValue = [self.allItems objectForKey:key];
                        [foodNameValue addObject:tempValue];
                    }
                }
            }
        }
        
        for(NSString *key in [self.totalPerCategory allKeys]) {
            //NSLog(@"KEY: %@\tVAL: %@", key, [self.totalPerCategory objectForKey:key]);
        }
        //NSLog(@"DONE HERE");
        
        for(NSString *foodGroup in [self.allItems allKeys]) {
            NSMutableArray *item = [self.allItems objectForKey:foodGroup];
            for(NSDictionary *it in item) {
                //NSLog(@"SUBGROUPS %@", it);
            }
            //NSLog(@"\n\n");
        }
    }
    
    return self;
}


- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) initializeBarPlot:(BarPlot*)barPlot
{
    barPlot.barWidth = 25;
    barPlot.barLineWidth = 1;
    barPlot.barLineColor = [UIColor lightNordeaBlue]; //colorFromHexCode:@"#777777"];
    barPlot.barColor = [UIColor lightNordeaBlue]; //colorFromHexCode:@"#555555"];
    
    barPlot.adaptAnimationType = ScrollableGraphViewAnimationTypeElastic;
    barPlot.animationDuration = 1.5;
    
    // Setup the reference lines
    ReferenceLines *referenceLines = [[ReferenceLines alloc] init];
    
    referenceLines.referenceLineLabelFont = [UIFont boldSystemFontOfSize:8.0];
    referenceLines.referenceLineColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    referenceLines.referenceLineLabelColor = [UIColor blackColor];
    referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePositionLeft;
    referenceLines.positionType = ReferenceLinePositioningTypeRelative;
    referenceLines.shouldAddLabelsToIntermediateReferenceLines = YES;
    referenceLines.dataPointLabelsSparsity = 1;
    referenceLines.dataPointLabelColor = [UIColor blackColor];
    referenceLines.shouldShowReferenceLineUnits = YES;
    referenceLines.shouldShowLabels = YES;
    [referenceLines setShouldShowReferenceLines:YES];
    [referenceLines setReferenceLineUnits:@"%%"];
    referenceLines.dataPointLabelColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    [self.graphView addReferenceLinesWithReferenceLines:referenceLines];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.graphView = [[ScrollableGraphView alloc] initWithFrame:self.mainViewForGraph.frame dataSource:self];
    [self.mainViewForGraph setBackgroundColor:[UIColor whiteColor]];
    
    self.mealBarPlot = [[BarPlot alloc] initWithIdentifier:@"mealBarPlot"];
    [self initializeBarPlot:self.mealBarPlot];
    
    self.graphView.backgroundFillColor = [UIColor whiteColor]; //colorFromHexCode:@"#333333"];
    self.graphView.shouldAnimateOnStartup = YES;
    self.graphView.showsHorizontalScrollIndicator = YES;
    self.graphView.showsVerticalScrollIndicator = YES;
    self.graphView.rangeMax = 100;
    self.graphView.rangeMin = 0;
    
    self.graphView.dataPointSpacing = 70;
    
    // Add everything
    [self.graphView addPlotWithPlot:self.mealBarPlot];
    //[self.graphView addPlotWithPlot:self.recommendedConsumptionBarPlot];
    
    [self.view addSubview:self.graphView];
}

- (double) valueForPlot:(Plot * _Nonnull)plot atIndex:(NSInteger)pointIndex
{
    static NSDictionary *userProperties;
    if(!userProperties) {
        userProperties = [Constants userProperties];
    }
    
    NSString *recommendedKey = @"";
    NSString *relevantKey = [[self.totalPerCategory allKeys] objectAtIndex:pointIndex];
    
    if([relevantKey isEqualToString:@"nf_cholesterol"]) {
        recommendedKey = @"recommended_cholesterol_per_day";
    } else if([relevantKey isEqualToString:@"nf_sugars"]) {
        recommendedKey = @"recommended_sugar_per_day";
    } else if([relevantKey isEqualToString:@"nf_saturated_fat"]) {
        recommendedKey = @"recommended_saturated_fat_per_day";
    } else if([relevantKey isEqualToString:@"nf_sodium"]) {
        recommendedKey = @"recommended_sodium_per_day";
    } else if([relevantKey isEqualToString:@"nf_total_fat"]) {
        recommendedKey = @"recommended_grams_of_fat_per_day";
    } else if([relevantKey isEqualToString:@"nf_protein"]) {
        recommendedKey = @"recommended_protein_per_day";
    } else if([relevantKey isEqualToString:@"nf_calories"]) {
        recommendedKey = @"recommended_calories_per_day";
    }
    
    double eatenValue = [[self.totalPerCategory objectForKey:relevantKey] doubleValue];
    double recommendedValue = [[userProperties objectForKey:recommendedKey] doubleValue];
    double result = (eatenValue / recommendedValue) * 100.0;
    
    if(result >= 100.0) {
        result = 90.0;
    }
    
    if(result < 10.0) {
        result = 13.0;
    }
    
    return result;
}

- (NSString * _Nonnull) labelAtIndex:(NSInteger)pointIndex
{
    
    NSString *relevantKey = [[self.totalPerCategory allKeys] objectAtIndex:pointIndex];
    return [relevantKey stringByReplacingOccurrencesOfString:@"nf_" withString:@""];
}

- (NSInteger) numberOfPoints
{
    //Number of food categories
    return [self.totalPerCategory count];
}
@end
